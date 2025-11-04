unit CustomMapper;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  System.JSON,
  System.TypInfo,
  Data.DB,
  JSONMapper.Exceptions,
  QueryMapper.Exceptions;

type
  TCustomMapper = class
  public
    class function fieldToValue(field: TField): TValue; virtual; abstract;
    class function valueToJSON(value: TValue): TJSONValue; virtual; abstract;
    class function JSONToValue(jsonValue: TJSONValue): TValue; virtual; abstract;
  end;

  TCustomMapperClass = class of TCustomMapper;

  TCustomMapper<T> = class(TCustomMapper)
  public
    class function fieldToValue(field: TField): TValue; override;
    class function JSONToValue(jsonValue: TJSONValue): TValue; override;
    class function valueToJSON(value: TValue): TJSONValue; override;

    class function fromField(field: TField): T; virtual; abstract;
    class function fromJSON(jsonValue: TJSONValue): T; virtual; abstract;
    class function toJSON(value: T): TJSONValue; virtual; abstract;
  end;

  TCustomMappers = TDictionary<PTypeInfo, TCustomMapperClass>;

  TCustomMapperRegistry = class
  private
    class var customMappers: TCustomMappers;
  public
    /// <summary> Adds a custom datatype mapper for <c>T</c>.
    ///  <para> Create a class which inherits from <c>TCustomMapper&lt;T&gt;</c> and
    ///   override the functions <c>toJSON()</c>, <c>fromJSON()</c> and <c>fromField()</c>.
    ///  </para>
    ///  <para>
    ///   Then register it with <c>registerCustomMapper&lt;T&gt;()</c>.
    ///  </para>
    /// </summary>
    class procedure register<T>(customMapper: TCustomMapperClass); static;
    class function TryGetValue(
      typInfo: PTypeInfo;
      out customMapper: TCustomMapperClass
    ): boolean; static;
  end;

  TField = Data.DB.TField;

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

class function TCustomMapper<T>.JSONToValue(jsonValue: TJSONValue): TValue;
begin
  try
    Result := TValue.From<T>(fromJSON(jsonValue));
  except
    on e: Exception do begin
      raise EJSONMapperCastingFromJSON.CreateFmt(
        'TCustomMapper<%s>.fromJSON(): Failed to convert from JSON. Error: %s',
        [GetTypeName(TypeInfo(T)), e.Message]
      );
    end;
  end;
end;

class function TCustomMapper<T>.valueToJSON(value: TValue): TJSONValue;
begin
  try
    Result := toJSON(value.AsType<T>);
  except
    on e: Exception do begin
      raise EJSONMapperCastingToJSON.CreateFmt(
        'TCustomMapper<%s>.toJSON(): Failed to convert to JSON. Error: %s',
        [GetTypeName(TypeInfo(T)), e.Message]
      );
    end;
  end;
end;

{ TCustomMapperRegistry }

class procedure TCustomMapperRegistry.register<T>(
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

