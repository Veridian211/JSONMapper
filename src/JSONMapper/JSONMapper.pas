unit JSONMapper;

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

interface

uses
  {$IFDEF USE_ATTRIBUTE_HELPER}
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
  JSONMapper.ListHelper,
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

    class function tryCreateJSONValue(obj: TObject; rttiField: TRttiField): TJSONValue; overload; static;
    class function tryCreateJSONValue(rec: TValue; rttiField: TRttiField): TJSONValue; overload; static;
    class function tryCreateJSONValue(value: TValue): TJSONValue; overload; static;
    class function createJSONValue(value: TValue): TJSONValue; static;

    class function recordToJSON(const rec: TValue): TJSONObject; static;
    class function arrayToJSON(const arr: TValue): TJSONArray; static;

    class function tryCreateValue(jsonValue: TJSONValue; obj: TObject; rttiField: TRttiField): TValue; overload; static;
    class function tryCreateValue(jsonValue: TJSONValue; rec: Pointer; rttiField: TRttiField): TValue; overload; static;
    class function tryCreateValue(jsonValue: TJSONValue; rttiType: TRttiType): TValue; overload; static;
    class function createValue(jsonValue: TJSONValue; rttiType: TRttiType; fieldValue: TValue): TValue;

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

    /// <summary> Maps a TJSONArray into a generic TList. <c>list</c> must have an Add() method. </summary>
    class procedure jsonToList(const jsonArray: TJSONArray; const list: TObject); overload;
    class function jsonToList<T>(const jsonArray: TJSONArray): TList<T>; overload;
    class function jsonToObjectList<T: class, constructor>(const jsonArray: TJSONArray): TObjectList<T>;
  end;

  IgnoreFieldAttribute = JSONMapper.Attributes.IgnoreFieldAttribute;
  JSONKeyAttribute = JSONMapper.Attributes.JSONKeyAttribute;

  /// <summary> ISO 8601 conform date conversion </summary>
  TDateFormatter_ISO8601 = JSONMapper.DateFormatter.TDateFormatter_ISO8601;
  /// <summary> uses current FormatSettings for date conversion </summary>
  TDateFormatter_Local = JSONMapper.DateFormatter.TDateFormatter_Local;

  EJSONMapperException = JSONMapper.Exceptions.EJSONMapperException;
  EJSONMapperObjectIsNil = JSONMapper.Exceptions.EJSONMapperObjectIsNil;
  EJSONMapperCastingToJSON = JSONMapper.Exceptions.EJSONMapperCastingToJSON;
  EJSONMapperCastingFromJSON = JSONMapper.Exceptions.EJSONMapperCastingFromJSON;
  EJSONMapperInvalidDateTime = JSONMapper.Exceptions.EJSONMapperInvalidDateTime;
  EJSONMapperInvalidDate = JSONMapper.Exceptions.EJSONMapperInvalidDate;
  EJSONMapperNotATListException = JSONMapper.Exceptions.EJSONMapperNotATListException;
  EJSONMapperFaultyEnumerator = JSONMapper.Exceptions.EJSONMapperFaultyEnumerator;

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
    raise EJSONMapperException.Create('TJSONMapper.objectToJSON(): "obj" is nil.');
  end;
  if jsonObject = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.objectToJSON(): "jsonObject" is nil.');
  end;

  rttiContext := TRttiContext.Create();
  try
    rttiInstanceType := rttiContext.GetType(obj.ClassType) as TRttiInstanceType;

    for rttiField in rttiInstanceType.GetPublicFields() do begin
      jsonKey := getJSONKey(rttiField);
      jsonValue := tryCreateJSONValue(obj, rttiField);

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
  if list = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.listToJSON(): "list" is nil.');
  end;
  if jsonArray = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.listToJSON(): "jsonArray" is nil.');
  end;

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
        jsonValue := tryCreateJSONValue(currentValue);

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

class function TJSONMapper.tryCreateJSONValue(obj: TObject; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(obj);
  try
    exit(createJSONValue(value));
  except
    on E: EValueToJSON do raise EJSONMapperCastingToJSON.Create(rttiField)
    else raise;
  end;
end;

class function TJSONMapper.tryCreateJSONValue(rec: TValue; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(rec.GetReferenceToRawData);
  try
    exit(createJSONValue(value));
  except
    on E: EValueToJSON do raise EJSONMapperCastingToJSON.Create(rttiField)
    else raise;
  end;
end;

class function TJSONMapper.tryCreateJSONValue(value: TValue): TJSONValue;
begin
  try
    exit(createJSONValue(value));
  except
    on E: EValueToJSON do raise EJSONMapperCastingToJSON.Create(value.TypeInfo)
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
        raise EValueToJSON.Create();
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
      raise EValueToJSON.Create();
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
        jsonValue := tryCreateJSONValue(rec, rttiField);

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

        jsonValue := tryCreateJSONValue(element);
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
  newFieldValue: TValue;
begin
  if jsonObject = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.jsonToObject(): "jsonObject" is nil.');
  end;
  if obj = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.jsonToObject(): "obj" is nil.');
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

      newFieldValue := tryCreateValue(jsonValue, obj, rttiField);
      rttiField.SetValue(obj, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.tryCreateValue(
  jsonValue: TJSONValue;
  obj: TObject;
  rttiField: TRttiField
): TValue;
var
  fieldValue: TValue;
begin
  fieldValue := rttiField.GetValue(obj);
  try
    exit(TJSONMapper.createValue(jsonValue, rttiField.FieldType, fieldValue));
  except
    on e: EJSONToValue do raise EJSONMapperCastingFromJSON.Create(jsonValue, rttiField);
    else raise;
  end;
end;   

class function TJSONMapper.tryCreateValue(
  jsonValue: TJSONValue; 
  rec: Pointer;
  rttiField: TRttiField
): TValue;
var
  fieldValue: TValue;
begin
  fieldValue := rttiField.GetValue(rec);
  try
    exit(TJSONMapper.createValue(jsonValue, rttiField.FieldType, fieldValue));
  except
    on e: EJSONToValue do raise EJSONMapperCastingFromJSON.Create(jsonValue, rttiField);
    else raise;
  end;
end;

class function TJSONMapper.tryCreateValue(
  jsonValue: TJSONValue;
  rttiType: TRttiType
): TValue;
begin
  // TODO: create value
end;

class function TJSONMapper.createValue(
  jsonValue: TJSONValue;
  rttiType: TRttiType;
  fieldValue: TValue
): TValue;
var
  obj: TObject;
  rec: TValue;
  dateString: string;
  value_Integer: Int64;
  value_Double: double;
begin
  case rttiType.TypeKind of
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
      if rttiType.Handle = TypeInfo(TDateTime) then begin
        dateString := TJSONString(jsonValue).Value;
        exit(dateFormatterClass.tryStringToDateTime(dateString));
      end;
      if rttiType.Handle = TypeInfo(TDate) then begin
        dateString := TJSONString(jsonValue).Value;
        exit(dateFormatterClass.tryStringToDate(dateString));
      end;
      exit(TJSONNumber(jsonValue).AsDouble);
    end;

    tkEnumeration: begin
      if not (rttiType.Handle = TypeInfo(Boolean)) then begin
        raise EJSONToValue.Create();
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
      jsonToObject(TJSONObject(jsonValue), obj);
      exit(obj);
    end;

    tkRecord: begin
      rec := jsonToRecord(
        fieldValue.GetReferenceToRawData,
        rttiType.Handle,
        TJSONObject(jsonValue)
      );
      exit(rec);
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
      raise EJSONToValue.Create();
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

      fieldValue := tryCreateValue(jsonValue, rec, rttiField);
      rttiField.SetValue(rec, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
  TValue.Make(rec, typInfo, Result);
end;

class procedure TJSONMapper.jsonToList(const jsonArray: TJSONArray; const list: TObject);
var
  rttiContext: TRttiContext;
  listType: TRttiInstanceType;
  addMethod: TRttiMethod;
  elementType: TRttiType;

  elementJSON: TJSONValue;
  elementValue: TValue;
begin
  if jsonArray = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.jsonToList(): "jsonArray" is nil.');
  end;
  if list = nil then begin
    raise EJSONMapperException.Create('TJSONMapper.jsonToList(): "list" is nil.');
  end;

  rttiContext := TRttiContext.Create();
  try
    listType := rttiContext.GetType(list) as TRttiInstanceType;
    getAddMethod(
      listType,
      addMethod,
      elementType
    );

    for elementJSON in jsonArray do begin
      // todo check if element is simple type or an object or a list type
      elementValue := tryCreateValue(elementJSON, elementType);
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.jsonToList<T>(const jsonArray: TJSONArray): TList<T>;
begin

end;

class function TJSONMapper.jsonToObjectList<T>(const jsonArray: TJSONArray): TObjectList<T>;
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
