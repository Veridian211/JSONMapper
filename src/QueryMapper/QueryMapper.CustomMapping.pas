unit QueryMapper.CustomMapping;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,
  Data.DB,
  QueryMapper.Exceptions;

type
  TCustomMapper = class
  public
    class function fieldToValue(field: TField): TValue; virtual; abstract;
  end;

  TCustomMapperClass = class of TCustomMapper;

  TCustomMapper<T> = class(TCustomMapper)
  public
    class function fieldToValue(field: TField): TValue; override; 
  
    class function fromField(field: TField): T; virtual; abstract;
  end;

  TCustomMappers = TDictionary<PTypeInfo, TCustomMapperClass>;

  TCustomMapperRegistry = class
  private
    class var customMappers: TCustomMappers;
  public
    class procedure registerCustomMapper<T>(customMapper: TCustomMapperClass); static;
    class function TryGetValue(
      typInfo: PTypeInfo; 
      out customMapper: TCustomMapperClass
    ): boolean; static;
  end;

implementation

{ TCustomMapper<T> }

class function TCustomMapper<T>.fieldToValue(field: TField): TValue;
begin
  try
    Result := TValue.From<T>(fromField(field));
  except
    on e: Exception do begin
      raise EQueryMapperCastingFromField.CreateFmt(
        'TCustomMapper<%s>.fromField(): Failed to convert field "%s". Error: %s',
        [
          GetTypeName(TypeInfo(T)),
          field.Name,
          e.Message
        ]);
    end;
  end;
end;

{ TCustomMapperRegistry }

class procedure TCustomMapperRegistry.registerCustomMapper<T>(
  customMapper: TCustomMapperClass
);
begin
  customMappers.Add(TypeInfo(T), customMapper);
end;

class function TCustomMapperRegistry.TryGetValue(
  typInfo: PTypeInfo;
  out customMapper: TCustomMapperClass
): boolean;
begin
  Result := customMappers.TryGetValue(typInfo, customMapper);
end;

initialization
  TCustomMapperRegistry.customMappers := TCustomMappers.Create();

finalization
  TCustomMapperRegistry.customMappers.Free();

end.
