unit ObjektToJSON.BasicObject_Test;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  TestObjects,
  JSONMapper,
  TestHelper;

type
  [TestFixture]
  TObjektToJSON_Test = class
  private
    obj: TUser;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestBasicObject;
  end;

implementation

procedure TObjektToJSON_Test.Setup;
begin
  obj := TUser.Create();
end;

procedure TObjektToJSON_Test.TearDown;
begin
  obj.Free;
end;

procedure TObjektToJSON_Test.TestBasicObject;
const
  EXPECTED_JSON = '';
var
  actual_json: string;
begin
  obj.id := 1;
  obj.name := 'John Doe';
  obj.isAdmin := true;

  actual_json := JSONToString(TJSONMapper.objectToJSON<TUser>(obj));
  Assert.AreEqual(EXPECTED_JSON, actual_json);
end;

initialization
  TDUnitX.RegisterTestFixture(TObjektToJSON_Test);

end.
