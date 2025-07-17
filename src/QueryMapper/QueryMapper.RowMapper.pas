unit QueryMapper.RowMapper;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  QueryMapper.Attributes,
  QueryMapper.Exceptions;

type
  TFieldMapping = record
  public
    field: TRttiField;
    constructor Create(field: TRttiField);
  end;

  TFieldMappings = TList<TFieldMapping>;

  TConstructorMethod = reference to function: TObject;

  TDatasetRowMapperOptions = record
  private
    const
      DEFAULT_CASE_SENSITIVE = false;
  public
    caseSensitive: boolean;
    constructor Create(caseSensitive: boolean);
    class function DefaultConfig(): TDatasetRowMapperOptions; static;
  end;

  TDatasetRowMapper<T: class> = class
  private
    constructorMethod: TConstructorMethod;
    fieldMappings: TFieldMappings;
    options: TDatasetRowMapperOptions;
    function getDatasetFieldName(field: TField): string;
    function getFieldName(field: TRttiField): string;
  public
    constructor Create(
      constructorMethod: TConstructorMethod;
      options: TDatasetRowMapperOptions
    ); reintroduce;
    function mapRow(dataset: TDataSet): T;
    destructor Destroy(); override;
  end;

  TDatasetRowMapperFactory = class
  private
    // global rttiContext, not thread safe
    class var rttiContext: TRttiContext;

    class var options: TDatasetRowMapperOptions;

    class function getConstructorMethod<T: class>(): TConstructorMethod;

    class procedure Initialize();
    class procedure Finalize();
  public
    class function createRowMapper<T: class>(): TDatasetRowMapper<T>;
  end;

implementation

{ TRowField }

constructor TFieldMapping.Create(field: TRttiField);
begin
  self.field := field;
end;

{ TDatasetRowMapper<T> }

constructor TDatasetRowMapper<T>.Create(
  constructorMethod: TConstructorMethod;
  options: TDatasetRowMapperOptions
);
begin
  inherited Create();
  self.constructorMethod := constructorMethod;
  self.options := options;

  self.fieldMappings := TFieldMappings.Create();
end;

function TDatasetRowMapper<T>.mapRow(dataset: TDataSet): T;
var
  field: TField;
  fieldName: string;
  fieldValue: TValue;
  fieldMapping: TFieldMapping;
  rowFieldName: string;
begin
  Result := constructorMethod() as T;
  try
    for fieldMapping in fieldMappings do begin
      rowFieldName := getFieldName(fieldMapping.field);

      for field in dataset.Fields do begin
        if fieldMapping.field.HasAttribute(FieldNameAttribute) then begin
          fieldName := field.DisplayName;
        end else begin
          fieldName := getDatasetFieldName(field);
        end;

        if (rowFieldName = fieldName) then begin
          fieldValue := TValue.FromVariant(field.Value);
          fieldMapping.field.SetValue(TObject(Result), fieldValue);
          break;
        end;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function TDatasetRowMapper<T>.getDatasetFieldName(field: TField): string;
begin
  if options.caseSensitive then begin
    exit(field.DisplayName);
  end;
  exit(LowerCase(field.DisplayName));
end;

function TDatasetRowMapper<T>.getFieldName(field: TRttiField): string;
begin
  if field.HasAttribute(FieldNameAttribute) then begin
    exit(FieldNameAttribute(field.GetAttribute(FieldNameAttribute)).fieldName);
  end;

  if options.caseSensitive then begin
    exit(field.Name);
  end;

  exit(LowerCase(field.Name));
end;

destructor TDatasetRowMapper<T>.Destroy();
begin
  fieldMappings.Free();
  inherited;
end;

{ TDatasetRowMapperOptions }

constructor TDatasetRowMapperOptions.Create(caseSensitive: boolean);
begin
  self.caseSensitive := caseSensitive;
end;

class function TDatasetRowMapperOptions.DefaultConfig(): TDatasetRowMapperOptions;
begin
  Result := TDatasetRowMapperOptions.Create(
    TDatasetRowMapperOptions.DEFAULT_CASE_SENSITIVE
  );
end;

{ TDatasetRowMapperFactory }

class function TDatasetRowMapperFactory.createRowMapper<T>(): TDatasetRowMapper<T>;
var
  rttiType: TRttiInstanceType;
  constructorMethod: TConstructorMethod;

  rowMapper: TDatasetRowMapper<T>;
  rttiField: TRttiField;
  fieldMapping: TFieldMapping;
begin
  constructorMethod := getConstructorMethod<T>();

  rowMapper := TDatasetRowMapper<T>.Create(constructorMethod, options);
  try
    rttiType := rttiContext.GetType(T) as TRttiInstanceType;
    for rttiField in rttiType.GetFields() do begin
      fieldMapping := TFieldMapping.Create(rttiField);
      rowMapper.fieldMappings.Add(fieldMapping);
    end;
  except
    rowMapper.Free();
    raise;
  end;

  Result := rowMapper;
end;

class function TDatasetRowMapperFactory.getConstructorMethod<T>(): TConstructorMethod;
var
  rttiType: TRttiInstanceType;
  rttiMethod: TRttiMethod;
  constructorMethod: TConstructorMethod;
begin
  constructorMethod := nil;

  rttiType := rttiContext.GetType(T) as TRttiInstanceType;
  for rttiMethod in rttiType.GetMethods() do begin
    if rttiMethod.IsConstructor then begin
      constructorMethod :=
        function(): TObject
        begin
          Result := rttiMethod.Invoke(rttiType.MetaclassType, []).AsObject();
        end;
      break;
    end;
  end;

  if not Assigned(constructorMethod) then begin
    raise EQueryMapper_NoEmptyConstructorFound.Create(rttiType.MetaclassType);
  end;

  Result := constructorMethod;
end;

class procedure TDatasetRowMapperFactory.Initialize();
begin
  rttiContext := TRttiContext.Create();
  options := TDatasetRowMapperOptions.DefaultConfig();
end;

class procedure TDatasetRowMapperFactory.Finalize();
begin
  rttiContext.Free();
end;

initialization
  TDatasetRowMapperFactory.Initialize();

finalization
  TDatasetRowMapperFactory.Finalize();

end.
