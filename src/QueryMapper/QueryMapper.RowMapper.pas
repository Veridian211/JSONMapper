unit QueryMapper.RowMapper;

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

interface

uses
  {$IFDEF USE_ATTRIBUTE_HELPER}
  JSONMapper.AttributeHelper,
  {$ENDIF}
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  QueryMapper.Attributes,
  QueryMapper.Exceptions;

type
  TFieldMap = TDictionary<TRttiField, TField>;
  TPropertyMap = TDictionary<TRttiProperty, TField>;

  TDatasetRowMapper<T: class> = class
  private
    rttiContext: TRttiContext;
    constructorMethod: TRttiMethod;
    fieldMap: TFieldMap;
    propertyMap: TPropertyMap;
    procedure getFieldMappings(datasetFields: TFields);
    function getConstructor(): TRttiMethod;
    class function getFieldName(rttiField: TRttiField): string; overload; static;
    class function getFieldName(rttiProperty: TRttiProperty): string; overload; static;
  public
    constructor Create(datasetFields: TFields); reintroduce;
    function mapRow(dataset: TDataSet): T;
    destructor Destroy(); override;
  end;

implementation

{ TDatasetRowMapper<T> }

constructor TDatasetRowMapper<T>.Create(datasetFields: TFields);
begin
  inherited Create();
  rttiContext := TRttiContext.Create();
  fieldMap := TFieldMap.Create();
  propertyMap := TPropertyMap.Create();

  constructorMethod := getConstructor();

  getFieldMappings(datasetFields);
end;

procedure TDatasetRowMapper<T>.getFieldMappings(datasetFields: TFields);
var
  rttiType: TRttiInstanceType;
  rttiField: TRttiField;
  rttiProperty: TRttiProperty;
  fieldName: string;
  field: TField;
begin
  rttiType := rttiContext.GetType(TypeInfo(T)) as TRttiInstanceType;

  for rttiField in rttiType.GetFields() do begin
    fieldName := getFieldName(rttiField);
    field := datasetFields.FindField(fieldName);
    if field = nil then begin
      continue;
    end;

    fieldMap.Add(rttiField, field);
  end;

  for rttiProperty in rttiType.GetProperties() do begin
    fieldName := getFieldName(rttiProperty);
    field := datasetFields.FindField(fieldName);
    if field = nil then begin
      continue;
    end;

    propertyMap.Add(rttiProperty, field);
  end;
end;

function TDatasetRowMapper<T>.getConstructor(): TRttiMethod;
var
  rttiType: TRttiInstanceType;
  rttiMethod: TRttiMethod;
begin
  rttiType := rttiContext.GetType(TypeInfo(T)) as TRttiInstanceType;

  for rttiMethod in rttiType.GetMethods() do begin
    if rttiMethod.IsConstructor then begin
      exit(rttiMethod);
    end;
  end;

  raise EQueryMapper_NoEmptyConstructorFound.Create(rttiType.MetaclassType);
end;

function TDatasetRowMapper<T>.mapRow(dataset: TDataSet): T;
var
  fieldMapPair: TPair<TRttiField, TField>;
  propertyMapPair: TPair<TRttiProperty, TField>;
  rttiField: TRttiField;
  rttiProperty: TRttiProperty;
  field: TField;
  fieldValue: TValue;
begin
  Result := constructorMethod.Invoke(T, []).AsObject() as T;
  try
    for fieldMapPair in fieldMap do begin
      rttiField := fieldMapPair.Key;
      field := fieldMapPair.Value;

      fieldValue := TValue.FromVariant(field.Value);
      rttiField.SetValue(TObject(Result), fieldValue);
    end;

    for propertyMapPair in propertyMap do begin
      rttiProperty := propertyMapPair.Key;
      field := propertyMapPair.Value;

      fieldValue := TValue.FromVariant(field.Value);
      rttiProperty.SetValue(TObject(Result), fieldValue);
    end;
  except
    Result.Free();
    raise;
  end;
end;

class function TDatasetRowMapper<T>.getFieldName(rttiField: TRttiField): string;
var
  fieldNameAttr: FieldNameAttribute;
begin
  fieldNameAttr := rttiField.GetAttribute<FieldNameAttribute>();
  if fieldNameAttr = nil then begin
    exit(rttiField.Name);
  end;

  exit(fieldNameAttr.fieldName);
end;

class function TDatasetRowMapper<T>.getFieldName(rttiProperty: TRttiProperty): string;
var
  fieldNameAttr: FieldNameAttribute;
begin
  fieldNameAttr := rttiProperty.GetAttribute<FieldNameAttribute>();
  if fieldNameAttr = nil then begin
    exit(rttiProperty.Name);
  end;

  exit(fieldNameAttr.fieldName);
end;

destructor TDatasetRowMapper<T>.Destroy();
begin
  propertyMap.Free();
  fieldMap.Free();
  rttiContext.Free();
  inherited;
end;

end.
