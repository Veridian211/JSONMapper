unit JSONMapper;

{$IF CompilerVersion <= 34.0}
{$DEFINE USE_ATTRIBUTE_HELPER}
{$ENDIF}

interface

uses
  {$IFDEF USE_ATTRIBUTE_HELPER}
  JSONMapper.AttributeHelper,
  {$ENDIF}
  System.JSON,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.SysUtils,
  System.Generics.Collections,
  JSONMapper.Exceptions,
  JSONMapper.Attributes,
  JSONMapper.ListHelper,
  JSONMapper.DateTimeFormatter,
  JSONMapper.Settings,
  JSONMapper.CustomMapping,
  JSONMapper.PublicFieldIterator,
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
  /// A Field/Property can be ignored by adding the <c>IgnoreAttribute</c> to it.
  /// </remarks>
  TJSONMapper = class
  protected
    class function getJSONKey(rttiDataMember: TRttiDataMember): string;

    class function recordToJSON(const rec: TValue): TJSONObject; static;
    class function arrayToJSON(const arr: TValue): TJSONArray; static;

    class function tryCreateJSONValue(obj: TObject; rttiDataMember: TRttiDataMember): TJSONValue; overload; static;
    class function tryCreateJSONValue(rec: TValue; rttiDataMember: TRttiDataMember): TJSONValue; overload; static;
    class function tryCreateJSONValue(value: TValue): TJSONValue; overload; static;
    class function createJSONValue(value: TValue): TJSONValue; static;

    class function tryCreateValue(jsonValue: TJSONValue; obj: TObject; rttiDataMember: TRttiDataMember): TValue; overload; static;
    class function tryCreateValue(jsonValue: TJSONValue; rec: Pointer; rttiDataMember: TRttiDataMember): TValue; overload; static;
    class function tryCreateValue(elementJSON: TJSONValue; elementType: TRttiType): TValue; overload; static;
    class function createValue(jsonValue: TJSONValue; rttiType: TRttiType; fieldValue: TValue): TValue;

  public
    class var dateFormatterClass: TDateFormatterClass;
    class var customMappers: TCustomMappers;

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

    /// <summary> Adds a custom datatype mapper for <c>T</c>.
    ///  <para> Create a class which inherits from <c>TCustomMapper&lt;T&gt;</c> and
    ///   override the functions <c>toJSON()</c> and <c>fromJSON()</c>.
    ///  </para>
    ///  <para>
    ///   Then register it with <c>registerCustomMapper&lt;T&gt;()</c>.
    ///  </para>
    /// </summary>
    class procedure registerCustomMapper<T>(mapper: TCustomMapperClass);
  end;

  IgnoreAttribute = JSONMapper.Attributes.IgnoreAttribute;
  JSONKeyAttribute = JSONMapper.Attributes.JSONKeyAttribute;

  /// <summary> ISO 8601 conform date conversion </summary>
  TDateFormatter_ISO8601 = JSONMapper.DateTimeFormatter.TDateFormatter_ISO8601;
  /// <summary> uses current FormatSettings for date conversion </summary>
  TDateFormatter_Local = JSONMapper.DateTimeFormatter.TDateFormatter_Local;

  EJSONMapperException = JSONMapper.Exceptions.EJSONMapperException;
  EJSONMapperCastingToJSON = JSONMapper.Exceptions.EJSONMapperCastingToJSON;
  EJSONMapperCastingFromJSON = JSONMapper.Exceptions.EJSONMapperCastingFromJSON;
  EJSONMapperInvalidDate = JSONMapper.Exceptions.EJSONMapperInvalidDate;
  EJSONMapperInvalidDateTime = JSONMapper.Exceptions.EJSONMapperInvalidDateTime;
  EJSONMapperNotATListException = JSONMapper.Exceptions.EJSONMapperNotATListException;
  EJSONMapperFaultyEnumerator = JSONMapper.Exceptions.EJSONMapperFaultyEnumerator;

  TNullString = Nullable.TNullString;
  TNullInteger = Nullable.TNullInteger;
  TNullDouble = Nullable.TNullDouble;
  TNullBoolean = Nullable.TNullBoolean;
  TNullDateTime = Nullable.TNullDateTime;

implementation

class procedure TJSONMapper.objectToJSON(const obj: TObject; var jsonObject: TJSONObject);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiDataMember: TRttiDataMember;

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

    for rttiDataMember in rttiInstanceType.GetPublicDataMembers() do begin
      jsonKey := getJSONKey(rttiDataMember);
      jsonValue := tryCreateJSONValue(obj, rttiDataMember);

      jsonPair := TJSONPair.Create(jsonKey, jsonValue);
      jsonObject.AddPair(jsonPair);
    end;
  finally
    rttiContext.Free();
  end;
end;

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
    FreeAndNil(jsonArray);
    raise;
  end;
  exit(jsonArray);
end;

class function TJSONMapper.recordToJSON(const rec: TValue): TJSONObject;
var
  jsonObject: TJSONObject;

  rttiContext: TRttiContext;
  recordType: TRttiRecordType;
  rttiDataMember: TRttiDataMember;

  jsonKey: string;
  jsonValue: TJSONValue;
  jsonPair: TJSONPair;
begin
  jsonObject := TJSONObject.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      recordType := rttiContext.GetType(rec.TypeInfo) as TRttiRecordType;

      for rttiDataMember in recordType.GetPublicDataMembers() do begin
        jsonKey := rttiDataMember.Name;
        jsonValue := tryCreateJSONValue(rec, rttiDataMember);

        jsonPair := TJSONPair.Create(jsonKey, jsonValue);
        jsonObject.AddPair(jsonPair);
      end;
    finally
      rttiContext.Free();
    end;
  except
    FreeAndNil(jsonObject);
    raise;
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
    FreeAndNil(jsonArray);
    raise;
  end;

  exit(jsonArray);
end;

class function TJSONMapper.tryCreateJSONValue(obj: TObject; rttiDataMember: TRttiDataMember): TJSONValue;
var
  value: TValue;
begin
  value := rttiDataMember.GetValue(obj);
  try
    exit(createJSONValue(value));
  except
    on E: EValueToJSON do raise EJSONMapperCastingToJSON.Create(rttiDataMember)
    else raise;
  end;
end;

class function TJSONMapper.tryCreateJSONValue(rec: TValue; rttiDataMember: TRttiDataMember): TJSONValue;
var
  value: TValue;
begin
  value := rttiDataMember.GetValue(rec.GetReferenceToRawData);
  try
    exit(createJSONValue(value));
  except
    on E: EValueToJSON do raise EJSONMapperCastingToJSON.Create(rttiDataMember)
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
  customMapper: TCustomMapperClass;
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
      if value.TypeInfo = TypeInfo(Boolean) then begin
        exit(TJSONBool.Create(value.AsBoolean));
      end;
      if customMappers.TryGetValue(value.TypeInfo, customMapper) then begin
        exit(customMapper.valueToJSON(value));
      end;
      raise EValueToJSON.Create();
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

class procedure TJSONMapper.jsonToObject(const jsonObject: TJSONObject; const obj: TObject);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiDataMember: TRttiDataMember;

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

    for rttiDataMember in rttiInstanceType.GetPublicDataMembers() do begin
      jsonKey := getJSONKey(rttiDataMember);
      jsonValue := jsonObject.GetValue(jsonKey);

      if jsonValue = nil then begin
        continue;
      end;

      newFieldValue := tryCreateValue(jsonValue, obj, rttiDataMember);
      rttiDataMember.SetValue(obj, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.jsonToObject<T>(const jsonObject: TJSONObject): T;
var
  obj: T;
begin
  obj := T.Create();
  try
    jsonToObject(jsonObject, obj);
  except
    FreeAndNil(obj);
    raise;
  end;
  exit(obj);
end;

class function TJSONMapper.jsonToRecord(
  const rec: Pointer;
  const typInfo: PTypeInfo;
  const jsonObject: TJSONObject
): TValue;
var
  rttiContext: TRttiContext;
  recordType: TRttiRecordType;
  rttiDataMember: TRttiDataMember;

  jsonKey: string;
  jsonValue: TJSONValue;
  newFieldValue: TValue;
begin
  rttiContext := TRttiContext.Create();
  try
    recordType := rttiContext.GetType(typInfo) as TRttiRecordType;

    for rttiDataMember in recordType.GetPublicDataMembers() do begin
      jsonKey := getJSONKey(rttiDataMember);
      jsonValue := jsonObject.GetValue(jsonKey);

      if jsonValue = nil then begin
        continue;
      end;

      newFieldValue := tryCreateValue(jsonValue, rec, rttiDataMember);
      rttiDataMember.SetValue(rec, newFieldValue);
    end;
  finally
    rttiContext.Free();
  end;
  TValue.Make(rec, typInfo, Result);
end;

class procedure TJSONMapper.jsonToList(const jsonArray: TJSONArray; const list: TObject);
var
  rttiContext: TRttiContext;
  listType: TRttiType;
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
    listType := rttiContext.GetType(list.ClassType);
    getAddMethod(
      TRttiInstanceType(listType),
      addMethod,
      elementType
    );

    for elementJSON in jsonArray do begin
      elementValue := tryCreateValue(elementJSON, elementType);
      addMethod.Invoke(list, [elementValue]);
    end;
  finally
    rttiContext.Free();
  end;
end;

class function TJSONMapper.jsonToList<T>(const jsonArray: TJSONArray): TList<T>;
var
  list: TList<T>;
begin
  list := TList<T>.Create();
  try
    jsonToList(jsonArray, list);
  except
    // TODO: if T is TRttiInstanceType then free objects in List
    FreeAndNil(list);
    raise;
  end;

  exit(list);
end;

class function TJSONMapper.jsonToObjectList<T>(const jsonArray: TJSONArray): TObjectList<T>;
var
  list: TObjectList<T>;
begin
  list := TObjectList<T>.Create();
  try
    jsonToList(jsonArray, list);
  except
    FreeAndNil(list);
    raise;
  end;

  exit(list);
end;

class function TJSONMapper.tryCreateValue(
  jsonValue: TJSONValue;
  obj: TObject;
  rttiDataMember: TRttiDataMember
): TValue;
var
  fieldValue: TValue;
begin
  fieldValue := rttiDataMember.GetValue(obj);
  try
    exit(TJSONMapper.createValue(jsonValue, rttiDataMember.DataType, fieldValue));
  except
    on e: EJSONToValue do raise EJSONMapperCastingFromJSON.Create(jsonValue, rttiDataMember);
    else raise;
  end;
end;   

class function TJSONMapper.tryCreateValue(
  jsonValue: TJSONValue; 
  rec: Pointer;
  rttiDataMember: TRttiDataMember
): TValue;
var
  fieldValue: TValue;
begin
  fieldValue := rttiDataMember.GetValue(rec);
  try
    exit(TJSONMapper.createValue(jsonValue, rttiDataMember.DataType, fieldValue));
  except
    on e: EJSONToValue do raise EJSONMapperCastingFromJSON.Create(jsonValue, rttiDataMember);
    else raise;
  end;
end;

class function TJSONMapper.tryCreateValue(
  elementJSON: TJSONValue;
  elementType: TRttiType
): TValue;
var
  constructorMethod: TConstructorMethod;
  elementValue: TValue;
  elementObject: TObject;
begin
  try
    elementValue := TValue.Empty;

    if elementType is TRttiInstanceType then begin
      constructorMethod := getConstructorMethod(TRttiInstanceType(elementType));
      elementValue := TValue.From<TObject>(constructorMethod());
    end;

    try
      exit(TJSONMapper.createValue(elementJSON, elementType, elementValue));
    except
      on e: EJSONToValue do raise EJSONMapperCastingFromJSON.Create(elementJSON, elementType);
      else raise;
    end;
  except
    if not elementValue.IsEmpty then begin
      elementObject := elementValue.AsObject;
      elementObject.Free;
    end;
    raise;
  end;
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
  customMapper: TCustomMapperClass;
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
      if rttiType.Handle = TypeInfo(Boolean) then begin
        exit(TJSONBool(jsonValue).AsBoolean);
      end;
      if customMappers.TryGetValue(rttiType.Handle, customMapper) then begin
        exit(customMapper.JSONToValue(jsonValue));
      end;
      raise EJSONToValue.Create();
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

class function TJSONMapper.getJSONKey(rttiDataMember: TRttiDataMember): string;
var
  jsonKeyAttr: JSONKeyAttribute;
begin
  jsonKeyAttr := rttiDataMember.GetAttribute<JSONKeyAttribute>();
  if jsonKeyAttr = nil then begin
    exit(rttiDataMember.Name);
  end;
  exit(jsonKeyAttr.getKey);
end;

class procedure TJSONMapper.registerCustomMapper<T>(mapper: TCustomMapperClass);
begin
  TJSONMapper.customMappers.add<T>(mapper);
end;

initialization
  TJSONMapper.customMappers := TCustomMappers.Create();
  TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;

finalization
  FreeAndNil(TJSONMapper.customMappers);

end.
