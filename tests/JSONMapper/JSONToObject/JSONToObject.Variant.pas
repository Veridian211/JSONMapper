unit JSONToObject.Variant;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  System.Variants,
  JSONMapper;

type
  TPerson = class
  public
    name: Variant;
    age: Variant;
    rating: Variant;
    isVerified: Variant;
  end;

  [TestFixture]
  TJSONToVariant = class
  public
    [Test]
    procedure TestVariant();
    [Test]
    procedure TestNull();
  end;

implementation

procedure TJSONToVariant.TestVariant();
const
  JSON_STRING = '{"name":"John Doe","age":23,"rating":12.4,"isVerified":true}';

  EXPECTED_NAME = 'John Doe';
  EXPECTED_AGE = 23;
  EXPECTED_RATING = 12.4;
  EXPECTED_IS_ADMIN = true;
var
  json: TJSONObject;
  person: TPerson;
begin
  person := nil;

  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    person := TJSONMapper.jsonToObject<TPerson>(json);

    Assert.AreEqual(EXPECTED_NAME, VarToStr(person.name));
    Assert.AreEqual(EXPECTED_AGE, Integer(person.age));
    Assert.IsTrue(Round(EXPECTED_RATING) = Round(Double(person.rating)));
    Assert.AreEqual(EXPECTED_IS_ADMIN, Boolean(person.isVerified));
  finally
    if Assigned(person) then begin
      FreeAndNil(person);
    end;
    json.Free();
  end;
end;

procedure TJSONToVariant.TestNull();
const
  JSON_STRING = '{"name":null,"age":null,"isVerified":null}';
var
  json: TJSONObject;
  person: TPerson;
begin
  person := nil;

  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    person := TJSONMapper.jsonToObject<TPerson>(json);

    Assert.AreEqual(Null, person.name);
    Assert.AreEqual(Null, person.age);
    Assert.AreEqual(Null, person.name);
  finally
    if Assigned(person) then begin
      FreeAndNil(person);
    end;
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToVariant);

end.
