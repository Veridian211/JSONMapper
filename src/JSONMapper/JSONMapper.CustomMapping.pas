unit JSONMapper.CustomMapping;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.TypInfo;

type
  TCustomMappingBase = class
  public
    class procedure toJSONUntyped(value: Pointer; out jsonValue: TJSONValue); virtual; abstract;
    class procedure fromJSONUntyped(jsonValue: TJSONValue; out value: Pointer); virtual; abstract;
  end;

  TCustomMapping<T> = class(TCustomMappingBase)
  public
    class procedure toJSONUntyped(value: Pointer; out jsonValue: TJSONValue); override;
    class procedure fromJSONUntyped(jsonValue: TJSONValue; out value: Pointer); override;

    class procedure toJSON(value: T; out jsonValue: TJSONValue); virtual; abstract;
    class procedure fromJSON(jsonValue: TJSONValue; out value: T); virtual; abstract;
  end;

  TCustomMappingBaseClass = class of TCustomMappingBase;

  TCustomMappings = class(TDictionary<PTypeInfo, TCustomMappingBaseClass>)
  public
    procedure Add<T>(customMappingClass: TCustomMappingBaseClass); reintroduce;
  end;

implementation

{ TCustomMapping<T> }

class procedure TCustomMapping<T>.fromJSONUntyped(
  jsonValue: TJSONValue;
  out value: Pointer
);
begin
  fromJSON(jsonValue, T(value^));
end;

class procedure TCustomMapping<T>.toJSONUntyped(
  value: Pointer;
  out jsonValue: TJSONValue
);
begin
  toJSON(T(value^), jsonValue);
end;

{ TCustomMappings }

procedure TCustomMappings.Add<T>(customMappingClass: TCustomMappingBaseClass);
begin
  inherited Add(TypeInfo(T), customMappingClass);
end;

end.

