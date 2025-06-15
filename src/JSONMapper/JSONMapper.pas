unit JSONMapper;

interface

uses
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
  PublicFieldIterator;

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
  public
    /// <summary> Maps the public fields of a generic object into a TJSONObject. </summary>
    class procedure objectToJSON(const obj: TObject; var jsonObject: TJSONObject); overload;
    class function objectToJSON(const obj: TObject): TJSONObject; overload;

    /// <summary> Maps a generic TList/TEnumerable into a TJSONArray. </summary>
    class procedure listToJSON(const list: TObject; var jsonArray: TJSONArray); overload;
    class function listToJSON(const list: TObject): TJSONArray; overload;

    /// <summary> Maps a TJSONObject into a generic object. </summary>
    class procedure jsonToObject<T: class>(const jsonObject: TJSONObject; obj: T); overload;
    class function jsonToObject<T: class, constructor>(const jsonObject: TJSONObject): T; overload;

    /// <summary> Maps a TJSONArray into a generic TList. </summary>
    class procedure jsonToList<T: class>(const jsonArray: TJSONArray; list: TList<T>); overload;
    class function jsonToList<T: class, constructor>(const jsonArray: TJSONArray): TList<T>; overload;
  end;

  IgnoreFieldAttribute = JSONMapper.Attributes.IgnoreFieldAttribute;
  JSONKeyAttribute = JSONMapper.Attributes.JSONKeyAttribute;

implementation

class function TJSONMapper.objectToJSON(const obj: TObject): TJSONObject;
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create();
  try
    objectToJSON(obj, jsonObject);
  except
    jsonObject.Free;
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
    rttiContext.Free;
  end;
end;

class procedure TJSONMapper.listToJSON(const list: TObject; var jsonArray: TJSONArray);
var
  rttiContext: TRttiContext;
  enumerator: TValue;
  currentProperty: TRttiProperty;
  moveNextMethod: TRttiMethod;

  current: TValue;
  jsonValue: TJSONValue;
begin
  rttiContext := TRttiContext.Create();
  try
    getEnumeratorMethods(
      list,
      enumerator,
      currentProperty,
      moveNextMethod
    );

    try
      while moveNextMethod.Invoke(enumerator, []).AsBoolean do begin
        current := currentProperty.GetValue(enumerator.AsObject);
        jsonValue := createJSONValue(current);
        jsonArray.AddElement(jsonValue);
      end;
    finally
      enumerator.AsObject.Free;
    end;
  finally
    rttiContext.Free;
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
    jsonArray.Free;
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
  obj: TObject;
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
      exit(TJSONNumber.Create(value.AsExtended));
    end;

    tkEnumeration: begin
      if not (value.TypeInfo = TypeInfo(Boolean)) then begin
        raise EJSONMapperCastingException.Create(value.TypeInfo);
      end;
      exit(TJSONBool.Create(value.AsBoolean));
    end;

    tkVariant: begin
      exit(TJSONString.Create(VarToStr(value.AsVariant)));
    end;

    tkClass: begin
      obj := value.AsObject;
      if isGenericTEnumerable(obj) then begin
        exit(TJSONMapper.listToJSON(obj));
      end;
      exit(TJSONMapper.objectToJSON(obj));
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
      rttiContext.Free;
    end;
  except
    jsonObject.Free;
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
      rttiContext.Free;
    end;
  except
    jsonArray.Free;
    raise;
  end;

  exit(jsonArray);
end;

class function TJSONMapper.jsonToObject<T>(
  const jsonObject: TJSONObject
): T;
var
  obj: T;
begin
  obj := T.Create();
  try
    jsonToObject<T>(jsonObject, obj);
  except
    obj.Free;
    raise;
  end;
  exit(obj);
end;

class procedure TJSONMapper.jsonToObject<T>(const jsonObject: TJSONObject; obj: T);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;
begin
  rttiContext := TRttiContext.Create();
  try
    rttiInstanceType := rttiContext.GetType(T) as TRttiInstanceType;

    for rttiField in rttiInstanceType.GetFields() do begin

    end;
  finally
    rttiContext.Free;
  end;
end;

class function TJSONMapper.jsonToList<T>(const jsonArray: TJSONArray): TList<T>;
begin

end;

class procedure TJSONMapper.jsonToList<T>(const jsonArray: TJSONArray; list: TList<T>);
begin

end;

class function TJSONMapper.getJSONKey(rttiField: TRttiField): string;
var
  jsonKeyAttrib: JSONKeyAttribute;
  jsonKey: string;
begin
  jsonKeyAttrib := rttiField.GetAttribute<JSONKeyAttribute>();
  if not Assigned(jsonKeyAttrib) then begin
    exit(rttiField.Name);
  end;
  exit(jsonKeyAttrib.getKey);
end;

end.
