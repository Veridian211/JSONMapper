unit JSONToObject.BasicObject;

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
  TJSONToObject = class
  private
    jsonObject: TJSONObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestBasicObject;
  end;

implementation

procedure TJSONToObject.Setup;
begin
  jsonObject := TJSONObject.Create();
end;

procedure TJSONToObject.TearDown;
begin
  jsonObject.Free;
end;

procedure TJSONToObject.TestBasicObject;
var
  jsonPair: TJSONPair;
  obj: TUser;
begin
  jsonPair := TJSONPair.Create('id', 1);
  jsonObject.AddPair(jsonPair);
  jsonPair := TJSONPair.Create('name', 'John Doe');
  jsonObject.AddPair(jsonPair);
  jsonPair := TJSONPair.Create('isAdmin', true);
  jsonObject.AddPair(jsonPair);

  obj := TJSONMapper.jsonToObject<TUser>(jsonObject);
  try
    Assert.AreEqual(obj.id, 1);
    Assert.AreEqual(obj.name, 'John Doe');
    Assert.AreEqual(obj.isAdmin, true);
  finally
    obj.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject);

end.
