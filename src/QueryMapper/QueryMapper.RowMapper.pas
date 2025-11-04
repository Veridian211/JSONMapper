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
  System.Variants,
  System.TypInfo,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  QueryMapper.Attributes,
  QueryMapper.Exceptions,
  CustomMapper;

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
    procedure setField(rttiField: TRttiField; obj: T; field: TField);
    procedure setProperty(rttiProperty: TRttiProperty; obj: T; field: TField);
    function getFieldValue(field: TField; rttiType: TRttiType): TValue;
  public
    constructor Create(datasetFields: TFields); reintroduce;
    function mapRow(dataset: TDataSet): T;
    destructor Destroy(); override;
  end;

implementation

var
  customMappers: TObjectList<TCustomMapper>;

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

  raise EQueryMapperNoEmptyConstructorFound.Create(rttiType.MetaclassType);
end;

function TDatasetRowMapper<T>.mapRow(dataset: TDataSet): T;
var
  fieldMapPair: TPair<TRttiField, TField>;
  rttiField: TRttiField;
  propertyMapPair: TPair<TRttiProperty, TField>;
  rttiProperty: TRttiProperty;
  field: TField;
begin
  Result := constructorMethod.Invoke(T, []).AsObject() as T;
  try
    for fieldMapPair in fieldMap do begin
      rttiField := fieldMapPair.Key;
      field := fieldMapPair.Value;
      setField(rttiField, Result, field);
    end;

    for propertyMapPair in propertyMap do begin
      rttiProperty := propertyMapPair.Key;
      field := propertyMapPair.Value;
      setProperty(rttiProperty, Result, field);
    end;
  except
    Result.Free();
    raise;
  end;
end;

procedure TDatasetRowMapper<T>.setField(
  rttiField: TRttiField;
  obj: T;
  field: TField
);
var
  fieldValue: TValue;
begin
  fieldValue := getFieldValue(field, rttiField.FieldType);
  rttiField.SetValue(TObject(obj), fieldValue);
end;

procedure TDatasetRowMapper<T>.setProperty(
  rttiProperty: TRttiProperty;
  obj: T;
  field: TField
);
var
  fieldValue: TValue;
begin
  fieldValue := getFieldValue(field, rttiProperty.PropertyType);
  rttiProperty.SetValue(TObject(obj), fieldValue);
end;

function TDatasetRowMapper<T>.getFieldValue(
  field: TField;
  rttiType: TRttiType
): TValue;
var
  customMapper: TCustomMapperClass;
begin
  case rttiType.TypeKind of
    tkString,
    tkChar,
    tkWChar,
    tkLString,
    tkWString,
    tkUString: begin
      exit(TValue.From<string>(field.AsString));
    end;

    tkInteger: begin
      exit(TValue.From<Integer>(field.AsInteger));
    end;
    tkInt64: begin
      exit(TValue.From<Int64>(field.AsLargeInt));
    end;

    tkFloat: begin
      if (rttiType.Handle = TypeInfo(TDateTime))
      or (rttiType.Handle = TypeInfo(TDate)) then begin
        exit(TValue.From<TDateTime>(field.AsDateTime));
      end;
      exit(TValue.From<Extended>(field.AsExtended));
    end;

    tkEnumeration: begin
      if rttiType.Handle = TypeInfo(Boolean) then begin
        exit(TValue.From<Boolean>(field.AsBoolean));
      end;
      if TCustomMapperRegistry.TryGetValue(rttiType.Handle, customMapper) then begin
        exit(customMapper.fieldToValue(field));
      end;
      raise EQueryMapperCastingFromField.Create(field, rttiType);
    end;

    tkVariant: begin
      exit(TValue.From<Variant>(field.AsVariant));
    end;

    tkClass: begin
//      obj := fieldValue.AsObject;
//      if hasGetEnumerator(obj) then begin
//        jsonToList(jsonValue as TJSONArray, obj);
//      end else begin
//        jsonToObject(TJSONObject(jsonValue), obj);
//      end;
//      exit(obj);
    end;

    tkRecord: begin
//      rec := jsonToRecord(
//        fieldValue.GetReferenceToRawData,
//        rttiType.Handle,
//        TJSONObject(jsonValue)
//      );
//      exit(rec);
    end;

//    tkArray,
//    tkDynArray: begin
//      exit(TJSONMapper.arrayToJSON(value));
//    end;
    else begin
//    tkUnknown: ;
//    tkSet: ;
//    tkMethod: ;
//    tkInterface: ;
//    tkClassRef: ;
//    tkPointer: ;
//    tkProcedure: ;
      raise EQueryMapperCastingFromField.Create(field, rttiType);
    end;
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

initialization
  customMappers := TObjectList<TCustomMapper>.Create();

finalization
  customMappers.Free;

end.
