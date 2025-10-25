unit JSONMapper.ListHelper;

interface

uses
  System.TypInfo,
  System.Rtti,
  System.SysUtils,
  JSONMapper.Exceptions;

type
  TConstructorMethod = reference to function: TObject;

  function hasGetEnumerator(const obj: TObject): Boolean;
  procedure getEnumerableMethods(
    const enumerable: TObject;
    out enumerator: TValue;
    out current: TRttiProperty;
    out moveNext: TRttiMethod
  );
  function isObjectType(typInfo: PTypeInfo): boolean;
  function getConstructorMethod(rttiType: TRttiInstanceType): TConstructorMethod;
  procedure getAddMethod(
    const listType: TRttiInstanceType;
    out addMethod: TRttiMethod;
    out elementType: TRttiType
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

function isObjectType(typInfo: PTypeInfo): boolean;
var
  rttiContext: TRttiContext;
  rttiType: TRttiType;
begin
  rttiContext := TRttiContext.Create();
  try
    rttiType := rttiContext.GetType(typInfo);
    exit(rttiType is TRttiInstanceType);
  finally
    rttiContext.Free;
  end;
end;

function getConstructorMethod(rttiType: TRttiInstanceType): TConstructorMethod;
var
  rttiMethod: TRttiMethod;
  constructorMethod: TConstructorMethod;
begin
  constructorMethod := nil;

  for rttiMethod in rttiType.GetMethods() do begin
    if rttiMethod.IsConstructor then begin
      constructorMethod :=
        function(): TObject
        begin
          Result := rttiMethod.Invoke(rttiType.MetaclassType, []).AsObject();
        end;
      break;
    end;
  end;

  if not Assigned(constructorMethod) then begin
    raise Exception.CreateFmt(
      'No default constructor found on "%s"',
      [rttiType.MetaclassType]
    );
  end;

  Result := constructorMethod;
end;

procedure getAddMethod(
  const listType: TRttiInstanceType;
  out addMethod: TRttiMethod;
  out elementType: TRttiType
);
var
  addMethodParameters: TArray<TRttiParameter>;
begin
  addMethod := listType.GetMethod('Add');
  if addMethod = nil then begin
    raise EJSONMapperException.CreateFmt(
      '%s does not contain an Add() method.',
      [listType.Name]
    );
  end;

  addMethodParameters := addMethod.GetParameters();
  if Length(addMethodParameters) <> 1 then begin
    raise EJSONMapperException.Create('Add() does not accept exact 1 argument.');
  end;
  elementType := addMethodParameters[0].ParamType;
end;

end.
