unit JSONMapper.Exceptions;

interface

uses
  System.SysUtils,
  System.Typinfo,
  System.Rtti;

type
  EJSONMapperException = class(Exception);

  EJSONMapperCastingException = class(EJSONMapperException)
  public
    constructor Create(typeInfo: PTypeInfo); reintroduce; overload;
  end;

  EJSONMapperNotImplementedException = class(EJSONMapperException)
  public
    constructor Create(typeInfo: PTypeInfo); reintroduce; overload;
  end;

  EJSONMapperNotATListException = class(EJSONMapperException)
  public
    constructor Create(); reintroduce;
  end;

  EJSONMapperFaultyEnumerator = class(EJSONMapperException)
  public
    constructor Create(rttiType: TRttiType); reintroduce;
  end;

implementation

{ EJSONMapperCastingException }

//constructor EJSONMapperCastingException.Create(rttiField: TRttiField);
//const
//  ERROR_MESSAGE = 'Field "%s" of type "%s" cannot be casted into JSON. Consider ignoring the field.';
//var
//  fieldName: string;
//  fieldType: string;
//begin
//  fieldName := rttiField.Name;
//  fieldType := rttiField.FieldType.Name;
//  inherited CreateFmt(ERROR_MESSAGE, [fieldName, fieldType]);
//end;

constructor EJSONMapperCastingException.Create(typeInfo: PTypeInfo);
const
  ERROR_MESSAGE = 'Type "%s" cannot be casted into JSON. Consider ignoring the field.';
begin
  inherited CreateFmt(ERROR_MESSAGE, [typeInfo.Name]);
end;

{ EJSONMapperNotImplementedException }

constructor EJSONMapperNotImplementedException.Create(typeInfo: PTypeInfo);
const
  ERROR_MESSAGE = 'Casting of "%s" is not implemented yet.';
begin
  inherited CreateFmt(ERROR_MESSAGE, [typeInfo.Name]);
end;

{ EJSONMapperNotATListException }

constructor EJSONMapperNotATListException.Create();
begin
  inherited Create('Is not a TList.');
end;

{ EJSONMapperEnumeratorNotFoundException }

constructor EJSONMapperFaultyEnumerator.Create(rttiType: TRttiType);
const
  ERROR_MESSAGE = 'Method GetEnumrator() not found on type "%s" or MoveNext() and GetCurrent() methods not found on enumerator.';
begin
  inherited CreateFmt(ERROR_MESSAGE, [rttiType.Name]);
end;

end.
