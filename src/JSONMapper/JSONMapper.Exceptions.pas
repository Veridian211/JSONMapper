unit JSONMapper.Exceptions;

interface

uses
  System.SysUtils,
  System.Typinfo,
  System.Rtti,
  System.JSON;

type
  EJSONMapperException = class(Exception);

  // ###  Type conversions  ###

  EJSONMapperCastingToJSON = class(EJSONMapperException)
  public
    constructor Create(rttiDataMember: TRttiDataMember); reintroduce; overload;
    constructor Create(typeInfo: PTypeInfo); reintroduce; overload;
  end;

  EJSONMapperCastingFromJSON = class(EJSONMapperException)
  private
    function truncateJSON(json: string): string;
  public
    constructor Create(jsonValue: TJSONValue; rttiDataMember: TRttiDataMember); overload;
    constructor Create(jsonValue: TJSONValue; rttiType: TRttiType); overload;
  end;

  EValueToJSON = class(EJSONMapperException)
  public
    constructor Create(); reintroduce;
  end;

  EJSONToValue = class(EJSONMapperException)
  public
    constructor Create(); reintroduce;
  end;

  EJSONMapperInvalidDate = class(EJSONMapperException)
  public
    constructor Create(date: string); reintroduce;
  end;

  EJSONMapperInvalidDateTime = class(EJSONMapperException)
  public
    constructor Create(dateTime: string); reintroduce;
  end;

  // ###  Lists  ###

  EJSONMapperNotATListException = class(EJSONMapperException)
  public
    constructor Create(); reintroduce;
  end;

  EJSONMapperFaultyEnumerator = class(EJSONMapperException)
  public
    constructor Create(rttiType: TRttiType); reintroduce;
  end;

implementation

{ EJSONMapperCastingToJSON }

constructor EJSONMapperCastingToJSON.Create(rttiDataMember: TRttiDataMember);
var
  className: string;
  datamemberName: string;
  datamemberType: string;
begin
  className := rttiDataMember.Parent.Name;
  datamemberName := rttiDataMember.Name;
  datamemberType := rttiDataMember.DataType.Name;

  inherited CreateFmt(
    'Failed to cast "%s.%s" of type "%s" into JSON. Consider adding the Ignore-Attribute.',
    [className, datamemberName, datamemberType]
  );
end;

constructor EJSONMapperCastingToJSON.Create(typeInfo: PTypeInfo);
begin
  inherited CreateFmt('Failed to cast type "%s" into JSON.', [typeInfo.Name]);
end;

{ EJSONMapperCastingFromJSON }

constructor EJSONMapperCastingFromJSON.Create(
  jsonValue: TJSONValue;
  rttiDataMember: TRttiDataMember
);
var
  datamemberType: string;
  className: string;
  datamemberName: string;
begin
  datamemberType := rttiDataMember.DataType.Name;
  className := rttiDataMember.Parent.Name;
  datamemberName := rttiDataMember.Name;

  inherited CreateFmt(
    'Failed to cast json "%s" into type "%s" at "%s.%s"',
    [
      truncateJSON(jsonValue.ToJSON),
      datamemberType,
      className,
      datamemberName
    ]
  );
end;

constructor EJSONMapperCastingFromJSON.Create(
  jsonValue: TJSONValue;
  rttiType: TRttiType
);
begin
  inherited CreateFmt(
    'Failed to cast json "%s" into type "%s"',
    [truncateJSON(jsonValue.ToJSON), rttiType.Name]
  );
end;

function EJSONMapperCastingFromJSON.truncateJSON(json: string): string;
const
  MAX_JSON_LENGTH = 100;
begin
  if Length(json) < MAX_JSON_LENGTH then begin
    exit(json);
  end;
  Result := Copy(json, 1, MAX_JSON_LENGTH) + '...';
end;

{ EValueToJSON }

constructor EValueToJSON.Create();
begin
  inherited Create(EmptyStr);
end;

{ EJSONToValue }

constructor EJSONToValue.Create();
begin
  inherited Create(EmptyStr);
end;

{ EJSONMapperInvalidDate }

constructor EJSONMapperInvalidDate.Create(date: string);
begin
  inherited CreateFmt('Invalid TDate: %s', [date]);
end;

{ EJSONMapperInvalidDateTime }

constructor EJSONMapperInvalidDateTime.Create(dateTime: string);
begin
  inherited CreateFmt('Invalid TDateTime: %s', [dateTime]);
end;

{ EJSONMapperNotATListException }

constructor EJSONMapperNotATListException.Create();
begin
  inherited Create('Is not a TList.');
end;

{ EJSONMapperFaultyEnumerator }

constructor EJSONMapperFaultyEnumerator.Create(rttiType: TRttiType);
begin
  inherited CreateFmt(
    'Method GetEnumrator() not found on type "%s" or MoveNext() and GetCurrent() methods not found on enumerator.',
    [rttiType.ClassType.QualifiedClassName]
  );
end;

end.
