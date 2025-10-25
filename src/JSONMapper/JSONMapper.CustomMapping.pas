unit JSONMapper.CustomMapping;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  System.JSON,
  System.TypInfo,
  JSONMapper.Exceptions;

type
  TCustomMapping = class
  public
    class function valueToJSON(value: TValue): TJSONValue; virtual; abstract;
    class function JSONToValue(jsonValue: TJSONValue): TValue; virtual; abstract;
  end;

  TCustomMapping<T> = class(TCustomMapping)
  public
    class function valueToJSON(value: TValue): TJSONValue; override;
    class function JSONToValue(jsonValue: TJSONValue): TValue; override;

    class function toJSON(value: T): TJSONValue; virtual; abstract;
    class function fromJSON(jsonValue: TJSONValue): T; virtual; abstract;
  end;

  TCustomMappingClass = class of TCustomMapping;

  TCustomMappings = class(TDictionary<PTypeInfo, TCustomMappingClass>)
  public
    procedure Add<T>(customMappingClass: TCustomMappingClass); reintroduce;
  end;

implementation

{ TCustomMapping<T> }

class function TCustomMapping<T>.valueToJSON(value: TValue): TJSONValue;
begin
  try
    Result := toJSON(value.AsType<T>);
  except
    on e: Exception do begin
      raise EJSONMapperCastingToJSON.CreateFmt(
        'TCustomMapping<%s>.toJSON(): Failed to convert to JSON. Error: %s',
        [GetTypeName(TypeInfo(T)), e.Message]
      );
    end;
  end;
end;

class function TCustomMapping<T>.JSONToValue(jsonValue: TJSONValue): TValue;
begin
  try
    Result := TValue.From<T>(fromJSON(jsonValue));
  except
    on e: Exception do begin
      raise EJSONMapperCastingFromJSON.CreateFmt(
        'TCustomMapping<%s>.fromJSON(): Failed to convert from JSON. Error: %s',
        [GetTypeName(TypeInfo(T)), e.Message]
      );
    end;
  end;
end;

{ TCustomMappings }

procedure TCustomMappings.Add<T>(customMappingClass: TCustomMappingClass);
begin
  inherited Add(TypeInfo(T), customMappingClass);
end;

end.

