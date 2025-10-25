unit ObjectToJSON._Object;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.DateUtils,
  JSONMapper;

type
  TUser = class
  private
    fIsAdmin: boolean;
  public
    name: string;
    age: integer;
    dateOfBirth: TDate;
    rating: double;
    property isAdmin: boolean read fIsAdmin write fIsAdmin;
  end;

  TNestedUser = class
  public
    user: TUser;
    constructor Create();
    destructor Destroy(); override;
  end;

  [TestFixture]
  TBasicObjectToJSON = class
  private
    user: TUser;
    nestedUser: TNestedUser;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestBasicObject();
    [Test]
    procedure TestNestedObject();
  end;

implementation

{ TBasicObjektToJSON }

procedure TBasicObjectToJSON.Setup();
begin
  user := TUser.Create();
  nestedUser := TNestedUser.Create();
end;

procedure TBasicObjectToJSON.TearDown();
begin
  user.Free();
  nestedUser.Free();
end;

procedure TBasicObjectToJSON.TestBasicObject();
const
  EXPECTED_JSON = '{"name":"John Doe","age":32,"dateOfBirth":"2006-10-23","rating":12.4,"isAdmin":true}';
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
    jsonObject.Free();
  end;
end;

procedure TBasicObjectToJSON.TestNestedObject();
const
  EXPECTED_AGE = 23;
var
  jsonObject: TJSONObject;
  userObj: TJSONObject;
  userAge: integer;
begin
  nestedUser.user.age := EXPECTED_AGE;

  jsonObject := TJSONMapper.objectToJSON(nestedUser);
  try
    jsonObject.TryGetValue<TJSONObject>('user', userObj);
    userObj.TryGetValue<integer>('age', userAge);

    Assert.AreEqual(EXPECTED_AGE, userAge);
  finally
    jsonObject.Free();
  end;
end;

{ TNestedUser }

constructor TNestedUser.Create();
begin
  inherited;
  user := TUser.Create();
end;

destructor TNestedUser.Destroy();
begin
  user.Free();
  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicObjectToJSON);

end.
