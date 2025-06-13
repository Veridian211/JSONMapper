unit ObjectToJSON.NestedObject;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  TestObjects,
  JSONMapper;

type
  [TestFixture]
  TNestedObject_Test = class
  private
    obj: TNestedUser;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestNestedObject;
  end;

implementation

procedure TNestedObject_Test.Setup;
begin
  obj := TNestedUser.Create();
end;

procedure TNestedObject_Test.TearDown;
begin
  obj.Free;
end;

procedure TNestedObject_Test.TestNestedObject;
const
  EXPECTED_VALUE = 1;
var
  jsonObject: TJSONObject;
  userObj: TJSONObject;
  userId: integer;
begin
  obj.user.id := EXPECTED_VALUE;

  jsonObject := TJSONMapper.objectToJSON(obj);
  try
    jsonObject.TryGetValue<TJSONObject>('user', userObj);
    userObj.TryGetValue<integer>('id', userId);

    Assert.IsTrue(userId = EXPECTED_VALUE);
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TNestedObject_Test);

end.
