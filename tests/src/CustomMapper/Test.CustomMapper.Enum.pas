unit Test.CustomMapper.Enum;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  JSONMapper,
  QueryMapper,
  CustomMapper;

type
  TColor = (
    clRed,
    clGreen,
    clBlue,
    clUndefined
  );

  TColorHelper = record helper for TColor
  const
    COLOR_RED = 'red';
    COLOR_GREEN = 'green';
    COLOR_BLUE = 'blue';
  public
    class function fromString(value: string): TColor; static;
    function toString(): string;
  end;

  TColorJSONMapper = class(TCustomMapper<TColor>)
    class function fromField(field: TField): TColor; override;
    class function toJSON(value: TColor): TJSONValue; override;
    class function fromJSON(jsonValue: TJSONValue): TColor; override;
  end;

  TColorObject = class
  public
    color: TColor;
  end;

  [TestFixture]
  TTestEnumMapper = class
  private
    colorObject: TColorObject;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestToJSON();
    [Test]
    procedure TestToJSONWithException();
    [Test]
    procedure TestFromJSON();
    [Test]
    procedure TestFromJSONWithException();
  end;

implementation

procedure TTestEnumMapper.Setup();
begin
  colorObject := TColorObject.Create();
end;

procedure TTestEnumMapper.TearDown();
begin
  colorObject.Free;
end;

procedure TTestEnumMapper.TestToJSON();
var
  json: TJSONObject;
begin
  colorObject.color := clGreen;
  json := TJSONMapper.objectToJSON(colorObject);
  try
    Assert.AreEqual(
      colorObject.color.toString(),
      json.GetValue('color').Value
    );
  finally
    json.Free;
  end;
end;

procedure TTestEnumMapper.TestToJSONWithException();
var
  json: TJSONObject;
begin
  colorObject.color := clUndefined;

  json := nil;
  try
    try
      json := TJSONMapper.objectToJSON(colorObject);
    except
      on e: Exception do begin
        Assert.AreEqual(EJSONMapperCastingToJSON, e.ClassType);
      end;
    end;
  finally
    if Assigned(json) then begin
      FreeAndNil(json);
    end;
  end;
end;

procedure TTestEnumMapper.TestFromJSON();
const
  JSON_STRING = '{"color":"green"}';
var
  json: TJSONObject;
  colorObject: TColorObject;
begin
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    colorObject := TJSONMapper.jsonToObject<TColorObject>(json);

    Assert.AreEqual(
      colorObject.color.toString(),
      json.GetValue('color').Value
    );
  finally
    if Assigned(colorObject) then begin
      FreeAndNil(colorObject);
    end;
    json.Free();
  end;
end;

procedure TTestEnumMapper.TestFromJSONWithException();
const
  JSON_STRING = '{"color":"this is no color"}';
var
  json: TJSONObject;
  colorObject: TColorObject;
begin
  colorObject := nil;
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    try
      colorObject := TJSONMapper.jsonToObject<TColorObject>(json);
    except
      on e: Exception do begin
        Assert.AreEqual(EJSONMapperCastingFromJSON, e.ClassType);
      end;
    end;
  finally
    if Assigned(colorObject) then begin
      FreeAndNil(colorObject);
    end;
    json.Free();
  end;
end;

{ TColorHelper }

class function TColorHelper.fromString(value: string): TColor;
begin
  if value = COLOR_RED then exit(clRed)
  else if value = COLOR_GREEN then exit(clGreen)
  else if value = COLOR_BLUE then exit(clBlue)
  else raise Exception.CreateFmt('Unknown color: %s', [value]);
end;

function TColorHelper.toString(): string;
begin
  case Self of
    clRed: exit(COLOR_RED);
    clGreen: exit(COLOR_GREEN);
    clBlue: exit(COLOR_BLUE);
  end;
  raise Exception.CreateFmt('Unknown color: %d', [Ord(self)]);
end;

{ TColorJSONMapper }

class function TColorJSONMapper.fromField(field: TField): TColor;
begin
  Result := TColor.fromString(field.AsString);
end;

class function TColorJSONMapper.toJSON(value: TColor): TJSONValue;
begin
  Result := TJSONString.Create(value.toString());
end;

class function TColorJSONMapper.fromJSON(jsonValue: TJSONValue): TColor;
var
  colorString: string;
begin
  colorString := (jsonValue as TJSONString).Value;
  Result := TColor.fromString(colorString);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestEnumMapper);
  TCustomMapperRegistry.register<TColor>(TColorJSONMapper);

end.
