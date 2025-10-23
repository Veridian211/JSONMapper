unit QueryMapper.RowMapper;

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

interface

uses
  {$IF USE_ATTRIBUTE_HELPER}
  AttributeHelper,
  {$ENDIF}
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  QueryMapper.Attributes,
  QueryMapper.Exceptions;

type
  TFieldMappingType = (fmField, fmProperty);

  TFieldMapping = record
  public
    fieldName: string;
    constructor Create(fieldName: string; field: TRttiField); overload;
    constructor Create(fieldName: string; prop: TRttiProperty); overload;  
  case fieldType: TFieldMappingType of
    fmField: (field: TRttiField);
    fmProperty: (prop: TRttiProperty);
  end;

  TFieldMappings = TList<TFieldMapping>;

  TConstructorMethod = reference to function: TObject;

  TDatasetRowMapper<T: class> = class
  private
    constructorMethod: TConstructorMethod;
    fieldMappings: TFieldMappings;
  public
    constructor Create(constructorMethod: TConstructorMethod); reintroduce;
    function mapRow(dataset: TDataSet): T;
    destructor Destroy(); override;
  end;

  TDatasetRowMapperFactory = class
  private
    // global rttiContext, not thread safe ?
    class var rttiContext: TRttiContext;

    class function getConstructorMethod<T: class>(): TConstructorMethod;
    class function getFieldName(field: TRttiField): string; overload; static;
    class function getFieldName(prop: TRttiProperty): string; overload; static;

    class procedure Initialize();
    class procedure Finalize();
  public
    class function createRowMapper<T: class>(): TDatasetRowMapper<T>;
  end;

implementation

{ TFieldMapping }

constructor TFieldMapping.Create(fieldName: string; field: TRttiField);
begin
  self.fieldName := fieldName;
  self.field := field;
end;     

constructor TFieldMapping.Create(fieldName: string; prop: TRttiProperty);
begin
  self.fieldName := fieldName;
  self.prop := prop;
end;

{ TDatasetRowMapper<T> }

constructor TDatasetRowMapper<T>.Create(constructorMethod: TConstructorMethod);
begin
  inherited Create();
  self.constructorMethod := constructorMethod;

  self.fieldMappings := TFieldMappings.Create();
end;

function TDatasetRowMapper<T>.mapRow(dataset: TDataSet): T;
var
  field: TField;
  fieldValue: TValue;
  fieldMapping: TFieldMapping;
  rowFieldName: string;
begin
  Result := constructorMethod() as T;
  try
    for fieldMapping in fieldMappings do begin
      field := dataset.FindField(fieldMapping.fieldName);
      if field = nil then begin
        continue;
      end;

      fieldValue := TValue.FromVariant(field.Value);

      case fieldMapping.fieldType of
        fmField:
          fieldMapping.field.SetValue(TObject(Result), fieldValue);
        fmProperty: 
          fieldMapping.prop.SetValue(TObject(Result), fieldValue);
      end;
    end;
  except
    Result.Free();
    raise;
  end;
end;

destructor TDatasetRowMapper<T>.Destroy();
begin
  fieldMappings.Free();
  inherited;
end;

{ TDatasetRowMapperFactory }

class function TDatasetRowMapperFactory.createRowMapper<T>(): TDatasetRowMapper<T>;
var
  rttiType: TRttiInstanceType;
  constructorMethod: TConstructorMethod;

  rowMapper: TDatasetRowMapper<T>;
  field: TRttiField;
  fieldName: string;
  fieldMapping: TFieldMapping;

  prop: TRttiProperty;
begin
  constructorMethod := getConstructorMethod<T>();

  rowMapper := TDatasetRowMapper<T>.Create(constructorMethod);
  try
    rttiType := rttiContext.GetType(T) as TRttiInstanceType;
    for field in rttiType.GetFields() do begin
      fieldName := getFieldName(field);
      fieldMapping := TFieldMapping.Create(fieldName, field);
      rowMapper.fieldMappings.Add(fieldMapping);
    end;

    for prop in rttiType.GetProperties() do begin
      fieldName := getFieldName(prop);
      fieldMapping := TFieldMapping.Create(fieldName, prop);
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

class function TDatasetRowMapperFactory.getFieldName(field: TRttiField): string;
begin
  if field.HasAttribute(FieldNameAttribute) then begin
    exit(FieldNameAttribute(field.GetAttribute(FieldNameAttribute)).fieldName);
  end;

  exit(field.Name);
end;

class function TDatasetRowMapperFactory.getFieldName(prop: TRttiProperty): string;
begin
  if prop.HasAttribute(FieldNameAttribute) then begin
    exit(FieldNameAttribute(prop.GetAttribute(FieldNameAttribute)).fieldName);
  end;

  exit(prop.Name);
end;

class procedure TDatasetRowMapperFactory.Initialize();
begin
  rttiContext := TRttiContext.Create();
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
