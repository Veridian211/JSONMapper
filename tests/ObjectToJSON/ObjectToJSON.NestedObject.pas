unit ObjectToJSON.NestedObject;

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
  TNestedObject = class
  private
    nestedUser: TNestedUser;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestNestedObject;
  end;

implementation

procedure TNestedObject.Setup;
begin
  nestedUser := TNestedUser.Create();
end;

procedure TNestedObject.TearDown;
begin
  nestedUser.Free;
end;

procedure TNestedObject.TestNestedObject;
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
  TDUnitX.RegisterTestFixture(TNestedObject);

end.
