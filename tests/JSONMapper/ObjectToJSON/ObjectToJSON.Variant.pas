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
  TPerson = class
  public
    name: Variant;
    age: Variant;
    dateOfBirth: Variant;
    rating: Variant;
    isVerified: Variant;
  end;

  [TestFixture]
  TVariantToJSON = class
  private
    person: TPerson;
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
  person := TPerson.Create();
end;

procedure TVariantToJSON.Teardown();
begin
  person.Free();
end;

procedure TVariantToJSON.TestNull();
const
  EXPECTED_JSON = '{"name":null,"age":null,"dateOfBirth":null,"rating":null,"isVerified":null}';
var
  json: TJSONObject;
begin
  person.name := null;
  person.age := null;
  person.dateOfBirth := null;
  person.rating := null;
  person.isVerified := null;

  json := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(EXPECTED_JSON, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TVariantToJSON.TestVariant();
const
  EXPECTED_JSON = '{"name":"John Doe","age":32,' +
    '"dateOfBirth":"2006-10-23T00:00:00.000Z","rating":12.4,"isVerified":true}';
var
  json: TJSONObject;
begin
  person.name := 'John Doe';
  person.age := 32;
  person.isVerified := true;
  person.dateOfBirth := ISO8601ToDate('2006-10-23');
  person.rating := 12.4;

  json := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(EXPECTED_JSON, json.ToJSON());
  finally
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TVariantToJSON);

end.
