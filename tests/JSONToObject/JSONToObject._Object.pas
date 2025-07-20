unit JSONToObject._Object;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  JSONMapper;

type
  TUser = class
  public
    name: string;
    age: integer;
    isAdmin: boolean;
  end;

  TNestedUser = class
  public
    user: TUser;
    constructor Create();
    destructor Destroy(); override;
  end;

  [TestFixture]
  TJSONToObject = class
  private
  public
    [Test]
    procedure TestBasicObject();
    [Test]
    procedure TestNestedObject();
  end;

implementation

procedure TJSONToObject.TestBasicObject;
const
  JSON_STRING = '{"name":"John Doe","age":23,"isAdmin":true}';
var
  jsonObject: TJSONObject;
  jsonPair: TJSONPair;
  user: TUser;
begin
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    user := TJSONMapper.jsonToObject<TUser>(jsonObject);

    Assert.AreEqual(23, user.age);
    Assert.AreEqual('John Doe', user.name);
    Assert.AreEqual(true, user.isAdmin);
  finally
    if Assigned(user) then begin
      FreeAndNil(user);
    end;
    jsonObject.Free();
  end;
end;

procedure TJSONToObject.TestNestedObject();
const
  JSON_STRING = '{"user":{"name":"John Doe","age":23,"isAdmin":true}}';
var
  nestedUserJSON: TJSONObject;
  jsonPair: TJSONPair;
  nestedUser: TNestedUser;
  user: TUser;
begin
  user := nil;

  nestedUserJSON := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    nestedUser := TJSONMapper.JSONToObject<TNestedUser>(nestedUserJSON);

    user := nestedUser.user;
    Assert.AreEqual(user.age, 23);
    Assert.AreEqual(user.name, 'John Doe');
    Assert.AreEqual(user.isAdmin, true);
  finally
    if Assigned(nestedUser) then begin
      FreeAndNil(nestedUser);
    end;
    nestedUserJSON.Free();
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
  TDUnitX.RegisterTestFixture(TJSONToObject);

end.
