unit JSONToObject._Record;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.Rtti,
  JSONMapper;

type
  TUser = record
    name: string;
    age: integer;
    isAdmin: boolean;
  end;

  TNestedUser = class
    user: TUser;
    constructor Create();
  end;

  [TestFixture]
  TJSONToObject_Record = class
  public
    [Test]
    procedure Test();
    [Test]
    procedure TestNestedObject();
  end;

implementation

procedure TJSONToObject_Record.Test();
const
  JSON_STRING = '{"name":"John Doe","age":23,"isAdmin":true}';
var
  jsonObject: TJSONObject;
  userValue: TValue;
  user: TUser;
begin
  user := Default(TUser);
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    userValue := TJSONMapper.jsonToRecord(@user, TypeInfo(TUser), jsonObject);
    user := userValue.AsType<TUser>;

    Assert.AreEqual(23, user.age);
    Assert.AreEqual('John Doe', user.name);
    Assert.AreEqual(true, user.isAdmin);
  finally
    jsonObject.Free();
  end;
end;

procedure TJSONToObject_Record.TestNestedObject();
const
  JSON_STRING = '{"user":{"name":"John Doe","age":23,"isAdmin":true}}';
var
  nestedUserJSON: TJSONObject;
  nestedUser: TNestedUser;
  user: TUser;
begin
  nestedUser := nil;

  nestedUserJSON := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    nestedUser := TJSONMapper.JSONToObject<TNestedUser>(nestedUserJSON);

    user := nestedUser.user;
    Assert.AreEqual(23, user.age);
    Assert.AreEqual('John Doe', user.name);
    Assert.AreEqual(true, user.isAdmin);
  finally
    if Assigned(nestedUser) then begin
      FreeAndNil(nestedUser);
    end;
    nestedUserJSON.Free();
  end;
end;

{ TNestedUser }

constructor TNestedUser.Create;
begin
  self.user := Default(TUser);
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject_Record);

end.
