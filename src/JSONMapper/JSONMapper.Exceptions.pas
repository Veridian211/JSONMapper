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
    constructor Create(rttiField: TRttiField); reintroduce; overload;
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

  EJSONMapperObjectIsNil = class(EJSONMapperException)
  public
    constructor Create(rttiField: TRttiField); reintroduce; overload;
  end;

  EJSONMapperInvalidDate = class(EJSONMapperException)
  public
    constructor Create(date: string); reintroduce;
  end;

  EJSONMapperInvalidDateTime = class(EJSONMapperException)
  public
    constructor Create(dateTime: string); reintroduce;
  end;

implementation

{ EJSONMapperCastingException }

constructor EJSONMapperCastingException.Create(rttiField: TRttiField);
var
  fieldName: string;
  fieldParentName: string;
  fieldType: string;
begin
  fieldName := rttiField.Name;
  fieldParentName := rttiField.Parent.Name;
  fieldType := rttiField.FieldType.Name;

  inherited CreateFmt(
    'Field "%s.%s" of type "%s" cannot be casted into JSON. Consider ignoring it.',
    [fieldParentName, fieldName, fieldType]
  );
end;

constructor EJSONMapperCastingException.Create(typeInfo: PTypeInfo);
begin
  inherited CreateFmt('Type "%s" cannot be casted into JSON.', [typeInfo.Name]);
end;

{ EJSONMapperNotImplementedException }

constructor EJSONMapperNotImplementedException.Create(typeInfo: PTypeInfo);
begin
  inherited CreateFmt(
    'Casting of "%s" is not implemented yet.',
    [typeInfo.Name]
  );
end;

{ EJSONMapperNotATListException }

constructor EJSONMapperNotATListException.Create();
begin
  inherited Create('Is not a TList.');
end;

{ EJSONMapperEnumeratorNotFoundException }

constructor EJSONMapperFaultyEnumerator.Create(rttiType: TRttiType);
begin
  inherited CreateFmt(
    'Method GetEnumrator() not found on type "%s" or MoveNext() and GetCurrent() methods not found on enumerator.',
    [rttiType.ClassType.QualifiedClassName]
  );
end;

{ EJSONMapperObjectIsNil }

constructor EJSONMapperObjectIsNil.Create(rttiField: TRttiField);
var
 fieldName: string;
 fieldParentName: string;
 fieldType: string;
begin
  fieldName := rttiField.Name;
  fieldParentName := rttiField.Parent.Name;
  fieldType := rttiField.FieldType.Name;

  inherited CreateFmt(
    '%s.%s is nil (should be instance of %s).',
    [fieldParentName, fieldName, fieldType]
  );
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

end.
