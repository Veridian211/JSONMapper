unit JSONToObject.NestedObject;

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
  TJSONToNestedObject = class
  private
    nestedUserJSON: TJSONObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test();
  end;

implementation

procedure TJSONToNestedObject.Setup;
begin
  nestedUserJSON := TJSONObject.Create();
end;

procedure TJSONToNestedObject.TearDown;
begin
  nestedUserJSON.Free;
end;

procedure TJSONToNestedObject.Test();
var
  userJSON: TJSONObject;
  jsonPair: TJSONPair;
  nestedUser: TNestedUser;
  user: TUser;
begin
  userJSON := TJSONObject.Create();
  jsonPair := TJSONPair.Create('id', 1);
  userJSON.AddPair(jsonPair);
  jsonPair := TJSONPair.Create('name', 'John Doe');
  userJSON.AddPair(jsonPair);
  jsonPair := TJSONPair.Create('isAdmin', true);
  userJSON.AddPair(jsonPair);

  nestedUserJSON.AddPair('user', userJSON);

  nestedUser := TJSONMapper.JSONToObject<TNestedUser>(nestedUserJSON);
  try
    user := nestedUser.user;
    Assert.AreEqual(user.id, 1);
    Assert.AreEqual(user.name, 'John Doe');
    Assert.AreEqual(user.isAdmin, true);
  finally
    nestedUser.Free;
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
