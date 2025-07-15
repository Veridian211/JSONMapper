unit QueryMapper.RowMapper;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  QueryMapper.Attributes;

type
  TRowField = record
  public
    fieldName: string;
    field: TRttiField;
    constructor Create(fieldName: string; field: TRttiField);
  end;

  TRowFields = TList<TRowField>;

  TConstructorMethod = reference to function: TObject;

  TDatasetRowMapper<T: class> = class
  private
    constructorMethod: TConstructorMethod;
    rowFields: TRowFields;
  public
    constructor Create(constructorMethod: TConstructorMethod); reintroduce;
    function mapRow(dataset: TDataSet): T;
    destructor Destroy(); override;
  end;


  TDatasetRowMapperFactory = class
  private
    class var rttiContext: TRttiContext;
    class procedure Initialize();
    class procedure Finalize();
  public
    class function createRowMapper<T: class>(): TDatasetRowMapper<T>;
  end;

  EQueryMapper_NoEmptyConstructorFound = class(Exception)
  public
    constructor Create(metaClassType: TClass); reintroduce;
  end;

implementation

{ TRowField }

constructor TRowField.Create(fieldName: string; field: TRttiField);
begin
  self.fieldName := fieldName;
  self.field := field;
end;

{ TDatasetRowMapper<T> }

constructor TDatasetRowMapper<T>.Create(constructorMethod: TConstructorMethod);
begin
  inherited Create();
  self.constructorMethod := constructorMethod;
  self.rowFields := TRowFields.Create();
end;

function TDatasetRowMapper<T>.mapRow(dataset: TDataSet): T;
var
  field: TField;
  fieldName: string;
  fieldValue: TValue;
  rowField: TRowField;
begin
  Result := constructorMethod() as T;
  try
    for field in dataset.Fields do begin
      fieldName := field.DisplayName;
      for rowField in rowFields do begin
        if (rowField.fieldName = fieldName) then begin
          fieldValue := TValue.FromVariant(field.Value);
          rowField.field.SetValue(TObject(Result), fieldValue);
        end;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

destructor TDatasetRowMapper<T>.Destroy();
begin
  rowFields.Free();
  inherited;
end;

{ TDatasetRowMapperFactory }

class function TDatasetRowMapperFactory.createRowMapper<T>(): TDatasetRowMapper<T>;
var
  rttiType: TRttiInstanceType;
  rttiMethod: TRttiMethod;
  rowMapperConstructor: TConstructorMethod;

  rttiField: TRttiField;
  fieldName: string;
  rowField: TRowField;
begin
  rowMapperConstructor := nil;

  rttiType := rttiContext.GetType(T) as TRttiInstanceType;
  for rttiMethod in rttiType.GetMethods() do begin
    if rttiMethod.IsConstructor then begin
      rowMapperConstructor :=
        function(): TObject
        begin
          Result := rttiMethod.Invoke(rttiType.MetaclassType, []).AsObject();
        end;
      break;
    end;
  end;

  if not Assigned(rowMapperConstructor) then begin
    raise EQueryMapper_NoEmptyConstructorFound.Create(rttiType.MetaclassType);
  end;

  Result := TDatasetRowMapper<T>.Create(rowMapperConstructor);
  try
    for rttiField in rttiType.GetFields() do begin
      if rttiField.HasAttribute(FieldNameAttribute) then begin
        fieldName := FieldNameAttribute(rttiField.GetAttribute(FieldNameAttribute)).fieldName;
      end else begin
        fieldName := rttiField.Name;
      end;

      rowField := TRowField.Create(fieldName, rttiField);
      Result.rowFields.Add(rowField);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TDatasetRowMapperFactory.Initialize();
begin
  rttiContext := TRttiContext.Create();
end;

class procedure TDatasetRowMapperFactory.Finalize();
begin
  rttiContext.Free();
end;

{ EQueryMapper_NoEmptyConstructorFound }

constructor EQueryMapper_NoEmptyConstructorFound.Create(metaClassType: TClass);
begin
  inherited CreateFmt('"%s" has no empty constructor.', [metaClassType.QualifiedClassName]);
end;

initialization
  TDatasetRowMapperFactory.Initialize();

finalization
  TDatasetRowMapperFactory.Finalize();

end.
