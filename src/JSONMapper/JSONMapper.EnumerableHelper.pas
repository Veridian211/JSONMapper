unit JSONMapper.EnumerableHelper;

interface

uses
  System.TypInfo,
  System.Rtti,
  System.SysUtils,
  JSONMapper.Exceptions;

  function hasGetEnumerator(const obj: TObject): Boolean;
  procedure getEnumerableMethods(
    const enumerable: TObject;
    out enumerator: TValue;
    out current: TRttiProperty;
    out moveNext: TRttiMethod
  );

implementation

function hasGetEnumerator(const obj: TObject): Boolean;
var
  rttiContext: TRttiContext;
  rttiType: TRttiType;
  getEnumeratorMethod: TRttiMethod;
  enumerator: TRttiType;
  enumeratorHasMoveNext: boolean;
  enumeratorHasCurrent: boolean;
begin
  rttiContext := TRttiContext.Create();
  try
    rttiType := rttiContext.GetType(obj.ClassType);
    getEnumeratorMethod := rttiType.GetMethod('GetEnumerator');
    if getEnumeratorMethod = nil then begin
      exit(false);
    end;
    enumerator := getEnumeratorMethod.ReturnType;
    enumeratorHasMoveNext := enumerator.GetMethod('MoveNext') <> nil;
    enumeratorHasCurrent := enumerator.GetProperty('Current') <> nil;
    exit(enumeratorHasMoveNext and enumeratorHasCurrent);
  finally
    rttiContext.Free();
  end;
end;

procedure getEnumerableMethods(
  const enumerable: TObject;
  out enumerator: TValue;
  out current: TRttiProperty;
  out moveNext: TRttiMethod
);
var
  rttiContext: TRttiContext;
  enumerableType: TRttiInstanceType;

  getEnumeratorMethod: TRttiMethod;
  enumeratorType: TRttiInstanceType;
begin
  rttiContext := TRttiContext.Create();
  try
    enumerableType := rttiContext.GetType(enumerable.ClassType) as TRttiInstanceType;

    getEnumeratorMethod := enumerableType.GetMethod('GetEnumerator');
    if getEnumeratorMethod = nil then begin
      raise EJSONMapperFaultyEnumerator.Create(enumerableType);
    end;

    enumerator := getEnumeratorMethod.Invoke(enumerable, []);

    enumeratorType := rttiContext.GetType(enumerator.TypeInfo) as TRttiInstanceType;
    moveNext := enumeratorType.GetMethod('MoveNext');
    current := enumeratorType.GetProperty('Current');
    if (moveNext = nil) or (current = nil) then begin
      raise EJSONMapperFaultyEnumerator.Create(enumerableType);
    end;
  finally
    rttiContext.Free();
  end;
end;

end.
