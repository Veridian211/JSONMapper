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
  TCustomMapper = class
  public
    class function valueToJSON(value: TValue): TJSONValue; virtual; abstract;
    class function JSONToValue(jsonValue: TJSONValue): TValue; virtual; abstract;
  end;

  TCustomMapper<T> = class(TCustomMapper)
  public
    class function valueToJSON(value: TValue): TJSONValue; override;
    class function JSONToValue(jsonValue: TJSONValue): TValue; override;

    class function toJSON(value: T): TJSONValue; virtual; abstract;
    class function fromJSON(jsonValue: TJSONValue): T; virtual; abstract;
  end;

  TCustomMapperClass = class of TCustomMapper;

  TCustomMappers = class(TDictionary<PTypeInfo, TCustomMapperClass>)
  public
    procedure Add<T>(customMappingClass: TCustomMapperClass); reintroduce;
  end;

implementation

{ TCustomMapper<T> }

class function TCustomMapper<T>.valueToJSON(value: TValue): TJSONValue;
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

class function TCustomMapper<T>.JSONToValue(jsonValue: TJSONValue): TValue;
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

{ TCustomMappers }

procedure TCustomMappers.Add<T>(customMappingClass: TCustomMapperClass);
begin
  inherited Add(TypeInfo(T), customMappingClass);
end;

end.

