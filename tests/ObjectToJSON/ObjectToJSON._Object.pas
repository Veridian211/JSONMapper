unit ObjectToJSON._Object;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  JSONMapper;

type
  TUser = class
  public
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

  TNestedUser = class
  public
    user: TUser;
    constructor Create();
    destructor Destroy(); override;
  end;

  [TestFixture]
  TBasicObjektToJSON = class
  private
    user: TUser;
    nestedUser: TNestedUser;
    procedure TestNestedObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestBasicObject;
  end;

implementation

{ TBasicObjektToJSON }

procedure TBasicObjektToJSON.Setup;
begin
  user := TUser.Create();
  nestedUser := TNestedUser.Create();
end;

procedure TBasicObjektToJSON.TearDown;
begin
  user.Free;
  nestedUser.Free;
end;

procedure TBasicObjektToJSON.TestBasicObject;
const
  EXPECTED_JSON = '{"id":1,"name":"John Doe","isAdmin":true}';
var
  jsonObject: TJSONObject;
begin
  user.id := 1;
  user.name := 'John Doe';
  user.isAdmin := true;

  jsonObject := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(EXPECTED_JSON, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

procedure TBasicObjektToJSON.TestNestedObject();
const
  EXPECTED_VALUE = 1;
var
  jsonObject: TJSONObject;
  userObj: TJSONObject;
  userId: integer;
begin
  nestedUser.user.id := EXPECTED_VALUE;

  jsonObject := TJSONMapper.objectToJSON(nestedUser);
  try
    jsonObject.TryGetValue<TJSONObject>('user', userObj);
    userObj.TryGetValue<integer>('id', userId);

    Assert.IsTrue(userId = EXPECTED_VALUE);
  finally
    jsonObject.Free;
  end;
end;

{ TNestedUser }

constructor TNestedUser.Create;
begin
  inherited;
  user := TUser.Create();
end;

destructor TNestedUser.Destroy;
begin
  user.Free;
  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicObjektToJSON);

end.
