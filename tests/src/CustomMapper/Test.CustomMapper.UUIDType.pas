unit Test.CustomMapper.UUIDType;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.RegularExpressions,
  Data.DB,
  Datasnap.DBClient,
  JSONMapper,
  QueryMapper,
  CustomMapper;

type
  TUUID = record
  private
    value: string;
    class procedure checkIsUUID(const uuid: string); static;
  public
    class operator Implicit(uuid: string): TUUID;
    class operator Implicit(uuid: TUUID): string;
  end;

  TUUIDCustomMapper = class(TCustomMapper<TUUID>)
    class function fromField(field: TField): TUUID; override;
    class function toJSON(value: TUUID): TJSONValue; override;
    class function fromJSON(jsonValue: TJSONValue): TUUID; override;
  end;

  TUUIDObject = class
    uuid: TUUID;
  end;


  [TestFixture]
  TTestUUIDMapper = class
  private
    uuidObject: TUUIDObject;
    dataset: TClientDataset;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestToJSON();
    [Test]
    procedure TestFromJSON();
    [Test]
    procedure TestFromJSONWithException();
    [Test]
    procedure TestFromField();
    [Test]
    procedure TestFromFieldWithException();
  end;

implementation

procedure TTestUUIDMapper.Setup();
begin
  uuidObject := TUUIDObject.Create();

  dataset := TClientDataSet.Create(nil);
  dataset.FieldDefs.Add('uuid', ftString, 50);
  dataset.CreateDataSet;
end;

procedure TTestUUIDMapper.TearDown();
begin
  dataset.Free();
  uuidObject.Free();
end;

procedure TTestUUIDMapper.TestToJSON();
var
  json: TJSONObject;
  test: string;
begin
  uuidObject.uuid := '7312ef58-5a00-4a5a-9238-87ec2ded93ab';

  json := TJSONMapper.objectToJSON(uuidObject);
  try
    test := json.ToJSON();
    Assert.AreEqual(
      string(uuidObject.uuid),
      json.GetValue('uuid').Value
    );
  finally
    json.Free;
  end;
end;

procedure TTestUUIDMapper.TestFromJSON();
const
  JSON_STRING = '{"uuid":"7312ef58-5a00-4a5a-9238-87ec2ded93ab"}';
var
  json: TJSONObject;
  uuidObject: TUUIDObject;
begin
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    uuidObject := TJSONMapper.jsonToObject<TUUIDObject>(json);

    Assert.AreEqual(
      json.GetValue('uuid').Value,
      string(uuidObject.uuid)
    );
  finally
    if Assigned(uuidObject) then begin
      FreeAndNil(uuidObject);
    end;
    json.Free();
  end;
end;

procedure TTestUUIDMapper.TestFromJSONWithException();
const
  JSON_STRING = '{"uuid":"this is not a uuid"}';
var
  json: TJSONObject;
  uuidObject: TUUIDObject;
begin
  uuidObject := nil;
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    try
      uuidObject := TJSONMapper.jsonToObject<TUUIDObject>(json);
    except
      on e: Exception do begin
        Assert.AreEqual(EJSONMapperCastingFromJSON, e.ClassType);
      end;
    end;
  finally
    if Assigned(uuidObject) then begin
      FreeAndNil(uuidObject);
    end;
    json.Free();
  end;
end;

procedure TTestUUIDMapper.TestFromField();
const
  UUID = '7312ef58-5a00-4a5a-9238-87ec2ded93ab';
var
  uuidObject: TUUIDObject;
begin
  dataset.Append;
  dataset.FieldByName('uuid').AsString := UUID;
  dataset.Post;

  uuidObject := dataset.GetOne<TUUIDObject>();
  try
    Assert.AreEqual(UUID, string(uuidObject.uuid));
  finally
    uuidObject.Free;
  end;
end;

procedure TTestUUIDMapper.TestFromFieldWithException();
var
  uuidObject: TUUIDObject;
begin
  dataset.Append;
  dataset.FieldByName('uuid').AsString := 'not a uuid';
  dataset.Post;

  uuidObject := nil;
  try
    try
      uuidObject := dataset.GetOne<TUUIDObject>();
    except
      on e: Exception do begin
        Assert.AreEqual(EQueryMapperUnknownType, e.ClassType);
      end;
    end;
  finally
    if Assigned(uuidObject) then begin
      uuidObject.Free;
    end;
  end;
end;

{ TUUID }

class procedure TUUID.checkIsUUID(const uuid: string);
var
  isUUID: boolean;
begin
  isUUID := TRegEx.IsMatch(
    uuid,
    '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
  );

  if not isUUID then begin
    raise Exception.CreateFmt('Is not a UUID: "%s"', [uuid]);
  end;
end;

class operator TUUID.Implicit(uuid: string): TUUID;
begin
  checkIsUUID(uuid);
  Result := Default(TUUID);
  Result.value := uuid;
end;

class operator TUUID.Implicit(uuid: TUUID): string;
begin
  exit(uuid.value);
end;

{ TUUIDCustomMapper }

class function TUUIDCustomMapper.fromField(field: TField): TUUID;
begin
  Result := field.AsString;
end;

class function TUUIDCustomMapper.fromJSON(jsonValue: TJSONValue): TUUID;
begin
  Result := (jsonValue as TJSONString).Value;
end;

class function TUUIDCustomMapper.toJSON(value: TUUID): TJSONValue;
begin
  Result := TJSONString.Create(value);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUUIDMapper);
  TCustomMapperRegistry.register<TUUID>(TUUIDCustomMapper);

end.
