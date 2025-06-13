unit JSONMapper;

interface

uses
  System.JSON,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.SysUtils,
  JSONMapper.Exceptions,
  JSONMapper.Attributes,
  JSONMapper.ClassFieldHelper,
  JSONMapper.EnumerableHelper,
  PublicFieldIterator;

type
  TJSONMapper = class
  protected
    class function createJSONValue(
      obj: TObject;
      rttiField: TRttiField
    ): TJSONValue; overload; static;
    class function createJSONValue(value: TValue): TJSONValue; overload; static;
    class function recordToJSON(const rec: TValue): TJSONObject; static;
    class function arrayToJSON(const arr: TValue): TJSONArray; static;
  public
    /// <summary> Maps the public fields of a generic object into a TJSONObject.
    ///  <para> <c>TJSONString</c> - String, Char, WChar, LString, WString, UString </para>
    ///  <para> <c>TJSONNumber</c> - Integer, Int64, Float </para>
    ///  <para> <c>TJSONBool</c> - Boolean </para>
    ///  <para> <c>TJSONObject</c> - Object, Record </para>
    ///  <para> <c>TJSONArray</c> - Array, Dynamic Array, TList, TEnumerable in general </para>
    /// </summary>
    /// <remarks>
    /// A Field can be ignored by adding the <c>IgnoreFieldAttribute</c> to it.
    /// </remarks>
    class function objectToJSON(const obj: TObject): TJSONObject;

    /// <summary> Maps a generic TList/TEnumerable into a TJSONArray. </summary>
    class function listToJSON(const list: TObject): TJSONArray;

    class function jsonToObject<T: class, constructor>(const jsonObject: TJSONObject): T; static;
  end;

  IgnoreFieldAttribute = JSONMapper.Attributes.IgnoreFieldAttribute;

implementation

class function TJSONMapper.objectToJSON(const obj: TObject): TJSONObject;
var
  jsonObject: TJSONObject;

  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;

  jsonKey: string;
  jsonValue: TJSONValue;
  jsonPair: TJSONPair;
begin
  jsonObject := TJSONObject.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      rttiInstanceType := rttiContext.GetType(obj.ClassType) as TRttiInstanceType;

      for rttiField in rttiInstanceType.GetPublicFields() do begin
        jsonKey := rttiField.Name;
        jsonValue := createJSONValue(obj, rttiField);

        jsonPair := TJSONPair.Create(jsonKey, jsonValue);
        jsonObject.AddPair(jsonPair);
      end;
    finally
      rttiContext.Free;
    end;
  except
    jsonObject.Free;
    raise;
  end;

  exit(jsonObject);
end;

class function TJSONMapper.listToJSON(const list: TObject): TJSONArray;
var
  jsonArray: TJSONArray;

  rttiContext: TRttiContext;
  enumerator: TValue;
  currentProperty: TRttiProperty;
  moveNextMethod: TRttiMethod;

  current: TValue;
  jsonValue: TJSONValue;
begin
  jsonArray := TJSONArray.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      getEnumeratorMethods(
        list,
        enumerator,
        currentProperty,
        moveNextMethod
      );

      while moveNextMethod.Invoke(enumerator, []).AsBoolean do begin
        current := currentProperty.GetValue(enumerator.AsObject);
        jsonValue := createJSONValue(current);
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

class function TJSONMapper.createJSONValue(obj: TObject; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(obj);

  try
    exit(createJSONValue(value));
  except
    on E: EJSONMapperCastingException do begin
      raise EJSONMapperCastingException.Create(rttiField);
    end else begin
      raise;
    end;
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
      if value.TypeInfo = TypeInfo(Boolean) then begin
        exit(TJSONBool.Create(value.AsBoolean));
      end;
      raise EJSONMapperCastingException.Create(value.TypeInfo);
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
begin

end;

class function TJSONMapper.arrayToJSON(const arr: TValue): TJSONArray;
begin

end;

class function TJSONMapper.jsonToObject<T>(
  const jsonObject: TJSONObject
): T;
var
  obj: T;

  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;
begin
  obj := T.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      rttiInstanceType := rttiContext.GetType(T) as TRttiInstanceType;

      for rttiField in rttiInstanceType.GetFields() do begin

      end;
    finally
      rttiContext.Free;
    end;
  except
    obj.Free;
    raise;
  end;

  exit(obj);
end;

end.
