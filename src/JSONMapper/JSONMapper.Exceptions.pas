unit JSONMapper.Exceptions;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  EJSONMapperException = class(Exception);

  EJSONMapperCastingException = class(EJSONMapperException)
  public
    constructor Create(rttiField: TRttiField); reintroduce;
  end;

  EJSONMapperNotImplementedException = class(Exception)
  public
    constructor Create(rttiType: TRttiType); reintroduce;
  end;

implementation

constructor EJSONMapperCastingException.Create(rttiField: TRttiField);
const
  ERROR_MESSAGE = 'Field "%s" of type "%s" cannot be casted into JSON. Consider ignoring the field.';
var
  fieldName: string;
  fieldType: string;
begin
  fieldName := rttiField.Name;
  fieldType := rttiField.FieldType.Name;
  inherited CreateFmt(ERROR_MESSAGE, [fieldName, fieldType]);
end;

constructor EJSONMapperNotImplementedException.Create(rttiType: TRttiType);
const
  ERROR_MESSAGE = 'Casting of "%s" is not implemented yet.';
begin
  inherited CreateFmt(ERROR_MESSAGE, [rttiType.Name]);
end;

end.
