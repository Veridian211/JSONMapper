unit JSONMapper;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.SysUtils,
  JSONMapper.Exceptions,
  JSONMapper.Attributes,
  JSONMapper.EnumerableHelper,
  RttiUtils,
  PublicFieldIterator;

type
  TJSONMapper = class
  protected
    class function createJSONValue(
      element: TObject;
      rttiField: TRttiField
    ): TJSONValue; overload; static;
    class function createJSONValue(value: TValue): TJSONValue; overload; static;
  public
    class function objectToJSON(const obj: TObject): TJSONObject;
    class function listToJSON(const list: TObject): TJSONArray;

    class function jsonToObject<T: class, constructor>(const jsonObject: TJSONObject): T;
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

class function TJSONMapper.createJSONValue(element: TObject; rttiField: TRttiField): TJSONValue;
var
  value: TValue;
begin
  value := rttiField.GetValue(TObject(element));
  exit(createJSONValue(value));
end;

class function TJSONMapper.createJSONValue(value: TValue): TJSONValue;
var
  obj: TObject;
begin
  case value.Kind of
    tkInteger: begin
      exit(TJSONNumber.Create(value.AsInteger));
    end;
    tkInt64: begin
      exit(TJSONNumber.Create(value.AsInt64));
    end;
    tkFloat: begin
      exit(TJSONNumber.Create(value.AsExtended));
    end;

    tkString,
    tkChar,
    tkWChar,
    tkLString,
    tkWString,
    tkUString: begin
      exit(TJSONString.Create(value.AsString));
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
      raise EJSONMapperNotImplementedException.Create(value.TypeInfo);
    end;

    tkArray,
    tkDynArray: begin
      raise EJSONMapperNotImplementedException.Create(value.TypeInfo);
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
