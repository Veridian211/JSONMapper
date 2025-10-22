unit JSONMapper;

interface

uses
  {$IF USE_ATTRIBUTE_HELPER}
  AttributeHelper,
  {$ENDIF}
  System.JSON,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.SysUtils,
  System.Generics.Collections,
  JSONMapper.Exceptions,
  JSONMapper.Attributes,
  JSONMapper.ClassFieldHelper,
  JSONMapper.EnumerableHelper,
  JSONMapper.DateFormatter,
  PublicFieldIterator,
  Nullable;

type
  /// <summary> JSONMapper for mapping a generic object to a TJSONObject and vice versa.
  ///  <para> <c>TJSONString</c> - String, Char, WChar, LString, WString, UString </para>
  ///  <para> <c>TJSONNumber</c> - Integer, Int64, Float </para>
  ///  <para> <c>TJSONBool</c> - Boolean </para>
  ///  <para> <c>TJSONObject</c> - Object, Record </para>
  ///  <para> <c>TJSONArray</c> - Array, Dynamic Array, TList, TEnumerable in general </para>
  /// </summary>
  /// <remarks>
  /// A Field can be ignored by adding the <c>IgnoreFieldAttribute</c> to it.
  /// </remarks>
  TJSONMapper = class
  protected
    class function getJSONKey(rttiField: TRttiField): string;

    class function createJSONValue(obj: TObject; rttiField: TRttiField): TJSONValue; overload; static;
    class function createJSONValue(rec: TValue; rttiField: TRttiField): TJSONValue; overload; static;
    class function createJSONValue(value: TValue): TJSONValue; overload; static;

    class function recordToJSON(const rec: TValue): TJSONObject; static;
    class function arrayToJSON(const arr: TValue): TJSONArray; static;

    class function createValue(
      const jsonValue: TJSONValue;
      const rttiField: TRttiField;
      const fieldValue: TValue
    ): TValue;

  public
    class var dateFormatterClass: TDateFormatterClass;

    /// <summary> Maps the public fields of a generic object into a TJSONObject. </summary>
    class procedure objectToJSON(const obj: TObject; var jsonObject: TJSONObject); overload;
    class function objectToJSON(const obj: TObject): TJSONObject; overload;

    /// <summary> Maps a generic TList/TEnumerable into a TJSONArray. </summary>
    class procedure listToJSON(const list: TObject; var jsonArray: TJSONArray); overload;
    class function listToJSON(const list: TObject): TJSONArray; overload;

    /// <summary> Maps a TJSONObject into a generic object. </summary>
    class procedure jsonToObject(const jsonObject: TJSONObject; const obj: TObject); overload;
    class function jsonToObject<T: class, constructor>(const jsonObject: TJSONObject): T; overload;

    /// <summary> Maps a TJSONObject into a record. </summary>
    class function jsonToRecord(const rec: Pointer; const typInfo: PTypeInfo; const jsonObject: TJSONObject): TValue; static;

    /// <summary> Maps a TJSONArray into a generic TList. </summary>
    class procedure jsonToList(const jsonArray: TJSONArray; const list: TObject); overload;
    class function jsonToList<T: class, constructor>(const jsonArray: TJSONArray): T; overload;
  end;

  IgnoreFieldAttribute = JSONMapper.Attributes.IgnoreFieldAttribute;
  JSONKeyAttribute = JSONMapper.Attributes.JSONKeyAttribute;

  /// <summary> ISO 8601 conform date conversion </summary>
  TDateFormatter_ISO8601 = JSONMapper.DateFormatter.TDateFormatter_ISO8601;
  /// <summary> uses current FormatSettings for date conversion </summary>
  TDateFormatter_Local = JSONMapper.DateFormatter.TDateFormatter_Local;

  EJSONMapperException = JSONMapper.Exceptions.EJSONMapperException;
  EJSONMapperObjectIsNil = JSONMapper.Exceptions.EJSONMapperObjectIsNil;
  EJSONMapperJSONIsNil = JSONMapper.Exceptions.EJSONMapperJSONIsNil;
  EJSONMapperCastingException = JSONMapper.Exceptions.EJSONMapperCastingException;
  EJSONMapperInvalidDateTime = JSONMapper.Exceptions.EJSONMapperInvalidDateTime;
  EJSONMapperInvalidDate = JSONMapper.Exceptions.EJSONMapperInvalidDate;
  EJSONMapperNotATListException = JSONMapper.Exceptions.EJSONMapperNotATListException;
  EJSONMapperFaultyEnumerator = JSONMapper.Exceptions.EJSONMapperFaultyEnumerator;
  EJSONMapperNotImplementedException = JSONMapper.Exceptions.EJSONMapperNotImplementedException;

  TNullString = Nullable.TNullString;
  TNullInteger = Nullable.TNullInteger;
  TNullDouble = Nullable.TNullDouble;
  TNullBoolean = Nullable.TNullBoolean;
  TNullDateTime = Nullable.TNullDateTime;

implementation

class function TJSONMapper.objectToJSON(const obj: TObject): TJSONObject;
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create();
  try
    objectToJSON(obj, jsonObject);
  except
    jsonObject.Free();
    raise;
  end;
  exit(jsonObject);
end;

class procedure TJSONMapper.objectToJSON(const obj: TObject; var jsonObject: TJSONObject);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;

  jsonKey: string;
  jsonValue: TJSONValue;
  jsonPair: TJSONPair;
begin
  if obj = nil then begin
    raise EJSONMapperObjectIsNil.Create();
  end;
  if jsonObject = nil then begin
    raise EJSONMapperJSONIsNil.Create();
  end;

  rttiContext := TRttiContext.Create();
  try
    rttiInstanceType := rttiContext.GetType(obj.ClassType) as TRttiInstanceType;

    for rttiField in rttiInstanceType.GetPublicFields() do begin
      jsonKey := getJSONKey(rttiField);
      jsonValue := createJSONValue(obj, rttiField);

      jsonPair := TJSONPair.Create(jsonKey, jsonValue);
      jsonObject.AddPair(jsonPair);
    end;
  finally
    rttiContext.Free();
  end;
end;

class procedure TJSONMapper.listToJSON(const list: TObject; var jsonArray: TJSONArray);
var
  rttiContext: TRttiContext;
  enumerator: TValue;
  current: TRttiProperty;
  moveNext: TRttiMethod;

  currentValue: TValue;
  jsonValue: TJSONValue;
begin
  rttiContext := TRttiContext.Create();
  try
    getEnumerableMethods(
      list,
      enumerator,
      current,
      moveNext
    );

    try
      while moveNext.Invoke(enumerator, []).AsBoolean do begin
        currentValue := current.GetValue(enumerator.AsObject);
        jsonValue := createJSONValue(currentValue);
        jsonArray.AddElement(jsonValue);
      end;
    finally
      enumerator.AsObject.Free();
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.listToJSON(const list: TObject): TJSONArray;
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONArray.Create();
  try
    listToJSON(list, jsonArray);
  except
    jsonArray.Free();
    raise;
  end;
  exit(jsonArray);
end;

class function TJSONMapper.createJSONValue(obj: TObject; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(obj);
  try
    exit(createJSONValue(value));
  except
    on E: EJSONMapperCastingException do raise EJSONMapperCastingException.Create(rttiField)
    else raise;
  end;
end;

class function TJSONMapper.createJSONValue(rec: TValue; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(rec.GetReferenceToRawData);
  try
    exit(createJSONValue(value));
  except
    on E: EJSONMapperCastingException do raise EJSONMapperCastingException.Create(rttiField)
    else raise;
  end;
end;

class function TJSONMapper.createJSONValue(value: TValue): TJSONValue;
var
  value_Object: TObject;
  value_Variant: Variant;
  dateString: string;
begin
  case value.Kind of
    tkString,
    tkChar,
    tkWChar,
    tkLString,
    tkWString,
    tkUString: begin
      exit(TJSONString.Create(value.AsString));
    end;

    tkInteger: begin
      exit(TJSONNumber.Create(value.AsInteger));
    end;
    tkInt64: begin
      exit(TJSONNumber.Create(value.AsInt64));
    end;

    tkFloat: begin
      if value.TypeInfo = TypeInfo(TDateTime) then begin
        dateString := dateFormatterClass.dateTimeToString(value.AsExtended);
        exit(TJSONString.Create(dateString));
      end;
      if value.TypeInfo = TypeInfo(TDate) then begin
        dateString := dateFormatterClass.dateToString(value.AsExtended);
        exit(TJSONString.Create(dateString));
      end;
      exit(TJSONNumber.Create(value.AsExtended));
    end;

    tkEnumeration: begin
      if not (value.TypeInfo = TypeInfo(Boolean)) then begin
        raise EJSONMapperCastingException.Create(value.TypeInfo);
      end;
      exit(TJSONBool.Create(value.AsBoolean));
    end;

    tkVariant: begin
      value_Variant := value.AsVariant;
      if VarIsNull(value_Variant) then begin
        exit(TJSONNull.Create());
      end;
      if FindVarData(value_Variant)^.VType = varBoolean then begin
        exit(TJSONBool.Create(Boolean(value_Variant)));
      end;
      if FindVarData(value_Variant)^.VType = varDate then begin
        dateString := dateFormatterClass.dateTimeToString(TDateTime(value_Variant));
        exit(TJSONString.Create(dateString));
      end;
      if VarIsOrdinal(value_Variant) then begin
        exit(TJSONNumber.Create(Int64(value_Variant)));
      end;
      if VarIsFloat(value_Variant) then begin
        exit(TJSONNumber.Create(Double(value_Variant)));
      end;

      exit(TJSONString.Create(VarToStr(value_Variant)));
    end;

    tkClass: begin
      value_Object := value.AsObject;
      if hasGetEnumerator(value_Object) then begin
        exit(TJSONMapper.listToJSON(value_Object));
      end;
      exit(TJSONMapper.objectToJSON(value_Object));
    end;

    tkRecord: begin
      exit(TJSONMapper.recordToJSON(value));
    end;

    tkArray,
    tkDynArray: begin
      exit(TJSONMapper.arrayToJSON(value));
    end;

    else begin
//    tkUnknown: ;
//    tkSet: ;
//    tkMethod: ;
//    tkInterface: ;
//    tkClassRef: ;
//    tkPointer: ;
//    tkProcedure: ;
      raise EJSONMapperCastingException.Create(value.TypeInfo);
    end;
  end;
end;

class function TJSONMapper.recordToJSON(const rec: TValue): TJSONObject;
var
  jsonObject: TJSONObject;

  rttiContext: TRttiContext;
  recordType: TRttiRecordType;
  rttiField: TRttiField;

  jsonKey: string;
  jsonValue: TJSONValue;
  jsonPair: TJSONPair;
begin
  jsonObject := TJSONObject.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      recordType := rttiContext.GetType(rec.TypeInfo) as TRttiRecordType;

      for rttiField in recordType.GetPublicFields() do begin
        jsonKey := rttiField.Name;
        jsonValue := createJSONValue(rec, rttiField);

        jsonPair := TJSONPair.Create(jsonKey, jsonValue);
        jsonObject.AddPair(jsonPair);
      end;
    finally
      rttiContext.Free();
    end;
  except
    jsonObject.Free();
  end;

  exit(jsonObject);
end;

class function TJSONMapper.arrayToJSON(const arr: TValue): TJSONArray;
var
  jsonArray: TJSONArray;

  rttiContext: TRttiContext;
  arrayLength: integer;

  i: Integer;
  element: TValue;
  jsonValue: TJSONValue;
begin
  jsonArray := TJSONArray.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      arrayLength := arr.GetArrayLength();

      for i := 0 to arrayLength - 1 do begin
        element := arr.GetArrayElement(i);

        jsonValue := createJSONValue(element);
        jsonArray.AddElement(jsonValue);
      end;
    finally
      rttiContext.Free();
    end;
  except
    jsonArray.Free();
    raise;
  end;

  exit(jsonArray);
end;

class function TJSONMapper.jsonToObject<T>(const jsonObject: TJSONObject): T;
var
  obj: T;
begin
  obj := T.Create();
  try
    jsonToObject(jsonObject, obj);
  except
    obj.Free();
    raise;
  end;
  exit(obj);
end;

class procedure TJSONMapper.jsonToObject(const jsonObject: TJSONObject; const obj: TObject);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;

  jsonKey: string;
  jsonValue: TJSONValue;
  fieldValue: TValue;
  newFieldValue: TValue;
begin
  if jsonObject = nil then begin
    raise EJSONMapperJSONIsNil.Create();
  end;
  if obj = nil then begin
    raise EJSONMapperObjectIsNil.Create();
  end;

  rttiContext := TRttiContext.Create();
  try
    rttiInstanceType := rttiContext.GetType(obj.ClassType) as TRttiInstanceType;

    for rttiField in rttiInstanceType.GetFields() do begin
      jsonKey := getJSONKey(rttiField);
      jsonValue := jsonObject.GetValue(jsonKey);

      if jsonValue = nil then begin
        continue;
      end;

      fieldValue := rttiField.GetValue(obj);
      newFieldValue := TJSONMapper.createValue(jsonValue, rttiField, fieldValue);
      rttiField.SetValue(obj, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.createValue(
  const jsonValue: TJSONValue;
  const rttiField: TRttiField;
  const fieldValue: TValue
): TValue;
var
  obj: TObject;
  dateString: string;
  value_Integer: Int64;
  value_Double: double;
begin
  case rttiField.FieldType.TypeKind of
    tkString,
    tkChar,
    tkWChar,
    tkLString,
    tkWString,
    tkUString: begin
      exit(TJSONString(jsonValue).Value);
    end;

    tkInteger: begin
      exit(TJSONNumber(jsonValue).AsInt);
    end;
    tkInt64: begin
      exit(TJSONNumber(jsonValue).AsInt64);
    end;

    tkFloat: begin
      if rttiField.FieldType.Handle = TypeInfo(TDateTime) then begin
        dateString := TJSONString(jsonValue).Value;
        exit(dateFormatterClass.tryStringToDateTime(dateString));
      end;
      if rttiField.FieldType.Handle = TypeInfo(TDate) then begin
        dateString := TJSONString(jsonValue).Value;
        exit(dateFormatterClass.tryStringToDate(dateString));
      end;
      exit(TJSONNumber(jsonValue).AsDouble);
    end;

    tkEnumeration: begin
      if not (rttiField.FieldType.Handle = TypeInfo(Boolean)) then begin
        raise EJSONMapperCastingException.Create(rttiField);
      end;
      exit(TJSONBool(jsonValue).AsBoolean);
    end;

    tkVariant: begin
      if jsonValue is TJSONNull then begin
        exit(TValue.FromVariant(Null));
      end;

      if jsonValue is TJSONNumber then begin
        if TryStrToInt64(TJSONNumber(JsonValue).Value, value_Integer) then begin
          if (value_Integer >= Low(Integer)) and (value_Integer <= High(Integer)) then begin
            exit(TValue.From<Integer>(Integer(value_Integer)));
          end else begin
            exit(TValue.From<Int64>(value_Integer));
          end;
        end else begin
          value_Double := TJSONNumber(JsonValue).AsDouble;
          exit(TValue.From<Double>(value_Double));
        end;
      end;

      if jsonValue is TJSONBool then begin
        exit(TValue.From<Boolean>(TJSONBool(jsonValue).AsBoolean));
      end;

      if jsonValue is TJSONString then begin
        exit(TValue.From<String>(TJSONString(jsonValue).Value));
      end;

      // TODO: theoretisch fehlt TDate / TDateTime
    end;

    tkClass: begin
      obj := fieldValue.AsObject;
//      if isGenericTEnumerable(obj) then begin
//        exit(TJSONMapper.listToJSON(obj));
//      end;
      try
        jsonToObject(TJSONObject(jsonValue), obj);
      except
        on e: EJSONMapperObjectIsNil do raise EJSONMapperObjectIsNil.Create(rttiField);
        else raise;
      end;
      exit(obj);
    end;

    tkRecord: begin
      exit(jsonToRecord(fieldValue.GetReferenceToRawData, rttiField.FieldType.Handle, TJSONObject(jsonValue)));
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
      raise EJSONMapperCastingException.Create(rttiField);
    end;
  end;
end;

class function TJSONMapper.jsonToRecord(
  const rec: Pointer;
  const typInfo: PTypeInfo;
  const jsonObject: TJSONObject
): TValue;
var
  rttiContext: TRttiContext;
  recordType: TRttiRecordType;
  rttiField: TRttiField;

  jsonKey: string;
  jsonValue: TJSONValue;
  fieldValue: TValue;
  newFieldValue: TValue;
begin
  rttiContext := TRttiContext.Create();
  try
    recordType := rttiContext.GetType(typInfo) as TRttiRecordType;

    for rttiField in recordType.GetFields() do begin
      jsonKey := getJSONKey(rttiField);
      jsonValue := jsonObject.GetValue(jsonKey);

      if jsonValue = nil then begin
        continue;
      end;

      fieldValue := rttiField.GetValue(rec);
      newFieldValue := TJSONMapper.createValue(jsonValue, rttiField, fieldValue);
      rttiField.SetValue(rec, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
  TValue.Make(rec, typInfo, Result);
end;

class function TJSONMapper.jsonToList<T>(const jsonArray: TJSONArray): T;
begin

end;

class procedure TJSONMapper.jsonToList(const jsonArray: TJSONArray; const list: TObject);
begin

end;

class function TJSONMapper.getJSONKey(rttiField: TRttiField): string;
var
  jsonKeyAttrib: JSONKeyAttribute;
begin
  jsonKeyAttrib := rttiField.GetAttribute<JSONKeyAttribute>();
  if jsonKeyAttrib = nil then begin
    exit(rttiField.Name);
  end;
  exit(jsonKeyAttrib.getKey);
end;

initialization
  TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;

end.
