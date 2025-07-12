unit JSONToObject.BasicObject;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  JSONMapper;

type
  TUser = class
  public
    age: integer;
    name: string;
    isAdmin: boolean;
  end;

  [TestFixture]
  TJSONToObject = class
  public
    [Test]
    procedure TestBasicObject;
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
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject);

end.
