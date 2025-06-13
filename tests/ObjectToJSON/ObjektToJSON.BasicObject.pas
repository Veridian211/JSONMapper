unit ObjektToJSON.BasicObject;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  TestObjects,
  JSONMapper,
  TestHelper;

type
  [TestFixture]
  TBasicObjektToJSON_Test = class
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

procedure TBasicObjektToJSON_Test.Setup;
begin
  obj := TUser.Create();
end;

procedure TBasicObjektToJSON_Test.TearDown;
begin
  obj.Free;
end;

procedure TBasicObjektToJSON_Test.TestBasicObject;
const
  EXPECTED_JSON = '{"id":1,"name":"John Doe","isAdmin":true}';
var
  jsonObject: TJSONObject;
begin
  obj.id := 1;
  obj.name := 'John Doe';
  obj.isAdmin := true;

  jsonObject := TJSONMapper.objectToJSON(obj);
  try
    Assert.AreEqual(EXPECTED_JSON, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicObjektToJSON_Test);

end.
