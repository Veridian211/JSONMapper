unit JSONMapper;

interface

uses
  System.Generics.Collections,
  System.JSON,
  System.Rtti,
  System.TypInfo,
  System.Variants,
  System.SysUtils,
  JSONMapper.Attributes,
  RttiUtils,
  PublicFieldIterator;

type
  TJSONMapper = class
  protected
    class function createJSONValue<T: class, constructor>(
      element: T; 
      rttiField: TRttiField
    ): TJSONValue; static;
  public
    class function objectToJSON<T: class, constructor>(obj: T): TJSONObject; overload;
    class function objectListToJSON<T: class, constructor>(objList: TObjectList<T>): TJSONArray; overload;

    class function jsonToObject<T: class, constructor>(jsonObject: TJSONObject): T;
  end;

implementation

class function TJSONMapper.objectToJSON<T>(obj: T): TJSONObject;
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
      rttiInstanceType := rttiContext.GetType(T) as TRttiInstanceType;

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

class function TJSONMapper.objectListToJSON<T>(
  objList: TObjectList<T>
): TJSONArray;
var
  jsonArray: TJSONArray;
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiFields: TArray<TRttiField>;
  rttiField: TRttiField;
  jsonKey: string;
  element: T;

  jsonObject: TJSONObject;
  jsonValue: TJSONValue;
  jsonPair: TJSONPair;
begin
  jsonArray := TJSONArray.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      rttiInstanceType := rttiContext.GetType(T) as TRttiInstanceType;

      rttiFields := rttiInstanceType.GetPublicFields();

      for element in objList do begin
        jsonObject := TJSONObject.Create();
        jsonArray.AddElement(jsonObject);

        for rttiField in rttiFields do begin
          jsonKey := rttiField.Name;
          jsonValue := createJSONValue(element, rttiField);

          jsonPair := TJSONPair.Create(jsonKey, jsonValue);
          jsonObject.AddPair(jsonPair);
        end;
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

class function TJSONMapper.createJSONValue<T>(element: T; rttiField: TRttiField): TJSONValue;
var
  value: TValue; 
  valueVariant: Variant;   
begin
  value := rttiField.GetValue(TObject(element));
  
  case rttiField.FieldType.TypeKind of
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

    tkVariant: begin
      valueVariant := value.AsVariant;
      exit(TJSONString.Create(VarToStr(valueVariant)));
    end;

    tkEnumeration: begin
      if rttiField.FieldType.Handle = TypeInfo(Boolean) then begin
        exit(TJSONBool.Create(value.AsBoolean));
      end;
      raise Exception.CreateFmt('Typ kann nicht in JSON gecastet werden: %s', [rttiField.FieldType.Name]);
    end;
    
    else begin
      raise Exception.CreateFmt('Typ kann nicht in JSON gecastet werden: %s', [rttiField.FieldType.Name]);
    end;

//    tkUnknown: ;
//    tkSet: ;
//    tkClass: ;
//    tkMethod: ;
//    tkArray: ;
//    tkRecord: ;
//    tkInterface: ;
//    tkDynArray: ;
//    tkUString: ;
//    tkClassRef: ;
//    tkPointer: ;
//    tkProcedure: ;
  end;
end;

class function TJSONMapper.jsonToObject<T>(
  jsonObject: TJSONObject
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
