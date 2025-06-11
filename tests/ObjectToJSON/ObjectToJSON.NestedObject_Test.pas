unit ObjectToJSON.NestedObject_Test;

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
  json: TJSONObject;
  userObj: TJSONObject;
  userId: integer;
begin
  obj.user.id := EXPECTED_VALUE;

  json := TJSONMapper.objectToJSON(obj);
  json.TryGetValue<TJSONObject>('user', userObj);
  userObj.TryGetValue<integer>('id', userId);
  Assert.IsTrue(userId = EXPECTED_VALUE);
end;

initialization
  TDUnitX.RegisterTestFixture(TNestedObject_Test);

end.
