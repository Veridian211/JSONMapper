unit JSONToObject.Variant;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  System.Variants,
  JSONMapper;

type
  TUser = class
  public
    name: Variant;
    age: Variant;
    rating: Variant;
    isAdmin: Variant;
  end;

  [TestFixture]
  TJSONToObject_Variant = class
  public
    [Test]
    procedure TestVariant();
    [Test]
    procedure TestNull();
  end;

implementation

procedure TJSONToObject_Variant.TestVariant();
const
  JSON_STRING = '{"name":"John Doe","age":23,"rating":12.4,"isAdmin":true}';

  EXPECTED_NAME = 'John Doe';
  EXPECTED_AGE = 23;
  EXPECTED_RATING = 12.4;
  EXPECTED_IS_ADMIN = true;
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  user := nil;

  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    user := TJSONMapper.jsonToObject<TUser>(jsonObject);

    Assert.AreEqual(EXPECTED_NAME, VarToStr(user.name));
    Assert.AreEqual(EXPECTED_AGE, Integer(user.age));
    Assert.IsTrue(Round(EXPECTED_RATING) = Round(Double(user.rating)));
    Assert.AreEqual(EXPECTED_IS_ADMIN, Boolean(user.isAdmin));
  finally
    if Assigned(user) then begin
      FreeAndNil(user);
    end;
    jsonObject.Free;
  end;
end;

procedure TJSONToObject_Variant.TestNull();
const
  JSON_STRING = '{"name":null,"age":null,"isAdmin":null}';
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  user := nil;

  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    user := TJSONMapper.jsonToObject<TUser>(jsonObject);

    Assert.AreEqual(Null, user.name);
    Assert.AreEqual(Null, user.age);
    Assert.AreEqual(Null, user.name);
  finally
    if Assigned(user) then begin
      FreeAndNil(user);
    end;
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject_Variant);

end.
