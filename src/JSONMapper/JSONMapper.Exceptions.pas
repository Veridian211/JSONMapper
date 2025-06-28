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
    constructor Create(); reintroduce; overload;
  end;

implementation

{ EJSONMapperCastingException }

constructor EJSONMapperCastingException.Create(rttiField: TRttiField);
const
 ERROR_MESSAGE = 'Field "%s.%s" of type "%s" cannot be casted into JSON. Consider ignoring it.';
var
 fieldName: string;
 fieldParentName: string;
 fieldType: string;
begin
 fieldName := rttiField.Name;
 fieldParentName := rttiField.Parent.Name;
 fieldType := rttiField.FieldType.Name;
 inherited CreateFmt(ERROR_MESSAGE, [fieldParentName, fieldName, fieldType]);
end;

constructor EJSONMapperCastingException.Create(typeInfo: PTypeInfo);
const
  ERROR_MESSAGE = 'Type "%s" cannot be casted into JSON.';
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

{ EJSONMapperObjectIsNil }

constructor EJSONMapperObjectIsNil.Create();
begin
  inherited Create('Object is nil.');
end;

constructor EJSONMapperObjectIsNil.Create(rttiField: TRttiField);
const
  ERROR_MESSAGE = '%s.%s is nil (should be instance of %s).';
var
 fieldName: string;
 fieldParentName: string;
 fieldType: string;
begin
  fieldName := rttiField.Name;
  fieldParentName := rttiField.Parent.Name;
  fieldType := rttiField.FieldType.Name;
  inherited CreateFmt(ERROR_MESSAGE, [fieldParentName, fieldName, fieldType]);
end;

end.
