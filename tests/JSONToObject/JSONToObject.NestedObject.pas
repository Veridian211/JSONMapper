unit JSONToObject.NestedObject;

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
  TJSONToNestedObject = class
  private
    nestedUserJSON: TJSONObject;
  public
    [Test]
    procedure Test();
  end;

implementation

procedure TJSONToNestedObject.Test();
const
  JSON_STRING = '{"user":{"name":"John Doe","age":23,"isAdmin":true}}';
var
  userJSON: TJSONObject;
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
    nestedUserJSON.Free;
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

TDUnitX.RegisterTestFixture(TJSONToNestedObject);

end.
