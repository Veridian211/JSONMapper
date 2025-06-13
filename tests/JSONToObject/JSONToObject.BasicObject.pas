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
    obj: TUser;
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
  json: string;
begin
  jsonPair := TJSONPair.Create('id', 1);
  jsonObject.AddPair(jsonPair);

  json := jsonObject.ToString;

  obj := TJSONMapper.jsonToObject<TUser>(jsonObject);
  try
    Assert.AreEqual(obj.id, 1);
  finally
    obj.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject);

end.
