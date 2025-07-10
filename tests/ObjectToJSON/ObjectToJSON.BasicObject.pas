unit ObjectToJSON.BasicObject;

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

  [TestFixture]
  TBasicObjektToJSON = class
  private
    user: TUser;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestBasicObject;
  end;

implementation

procedure TBasicObjektToJSON.Setup;
begin
  user := TUser.Create();
end;

procedure TBasicObjektToJSON.TearDown;
begin
  user.Free;
end;

procedure TBasicObjektToJSON.TestBasicObject;
const
  EXPECTED_JSON = '{"id":1,"name":"John Doe","isAdmin":true}';
var
  jsonObject: TJSONObject;
begin
  user.id := 1;
  user.name := 'John Doe';
  user.isAdmin := true;

  jsonObject := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(EXPECTED_JSON, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicObjektToJSON);

end.
