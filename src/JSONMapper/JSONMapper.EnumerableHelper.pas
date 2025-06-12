unit JSONMapper.EnumerableHelper;

interface

uses
  System.TypInfo,
  System.Rtti,
  System.SysUtils,
  JSONMapper.Exceptions;

  function isGenericTEnumerable(const obj: TObject): Boolean;
  procedure getEnumeratorMethods(
    const enumerable: TObject;
    out enumerator: TValue;
    out currentProperty: TRttiProperty;
    out moveNextMethod: TRttiMethod
  );

implementation

function isGenericTEnumerable(const obj: TObject): Boolean;
var
  rttiContext: TRttiContext;
  rttiType: TRttiType;
begin
  rttiContext := TRttiContext.Create;
  try
    rttiType := rttiContext.GetType(obj.ClassType);
    exit(rttiType.Name.StartsWith('TEnumerable<'));
  finally
    rttiContext.Free;
  end;
end;

procedure getEnumeratorMethods(
  const enumerable: TObject;
  out enumerator: TValue;
  out currentProperty: TRttiProperty;
  out moveNextMethod: TRttiMethod
);
var
  rttiContext: TRttiContext;
  enumerableType: TRttiType;

  getEnumMethod: TRttiMethod;
  enumeratorType: TRttiType;
begin
  rttiContext := TRttiContext.Create();
  try
    enumerableType := rttiContext.GetType(enumerable.ClassType);

    getEnumMethod := enumerableType.GetMethod('GetEnumerator');
    if not Assigned(getEnumMethod) then begin
      raise EJSONMapperFaultyEnumerator.Create(enumerableType);
    end;

    enumerator := getEnumMethod.Invoke(enumerable, []);

    enumeratorType := rttiContext.GetType(enumerator.TypeInfo);
    moveNextMethod := enumeratorType.GetMethod('MoveNext');
    currentProperty := enumeratorType.GetProperty('Current');
    if not Assigned(moveNextMethod) or not Assigned(currentProperty) then begin
      raise EJSONMapperFaultyEnumerator.Create(enumerableType);
    end;
  finally
    rttiContext.Free;
  end;
end;

end.
