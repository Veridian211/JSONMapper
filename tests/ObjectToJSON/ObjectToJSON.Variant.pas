unit ObjectToJSON.Variant;

interface

uses
  DUnitX.TestFramework,
  JSONMapper,
  System.Rtti,
  System.JSON,
  System.Variants,
  System.DateUtils;

type
  TUser = class
  public
    name: Variant;
    age: Variant;
    dateOfBirth: Variant;
    rating: Variant;
    isAdmin: Variant;
  end;

  [TestFixture]
  TVariantToJSON = class
  private
    user: TUser;
  public
    [Setup]
    procedure Setup();
    [Teardown]
    procedure Teardown();

    [Test]
    procedure TestNull();
    [Test]
    procedure TestVariant();
  end;

implementation

procedure TVariantToJSON.Setup();
begin
  user := TUser.Create();
end;

procedure TVariantToJSON.Teardown();
begin
  user.Free;
end;

procedure TVariantToJSON.TestNull();
const
  EXPECTED_JSON = '{"name":null,"age":null,"dateOfBirth":null,"rating":null,"isAdmin":null}';
var
  json: TJSONObject;
begin
  user.name := null;
  user.age := null;
  user.dateOfBirth := null;
  user.rating := null;
  user.isAdmin := null;

  json := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(EXPECTED_JSON, json.ToJSON());
  finally
    json.Free;
  end;
end;

procedure TVariantToJSON.TestVariant();
const
  EXPECTED_JSON = '{"name":"John Doe","age":32,"dateOfBirth":"2006-10-23T00:00:00.000Z","rating":12.4,"isAdmin":true}';
var
  jsonObject: TJSONObject;
begin
  user.name := 'John Doe';
  user.age := 32;
  user.isAdmin := true;
  user.dateOfBirth := ISO8601ToDate('2006-10-23');
  user.rating := 12.4;

  jsonObject := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(EXPECTED_JSON, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TVariantToJSON);

end.
