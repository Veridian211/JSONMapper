unit ObjectToJSON.IgnoreAttribute;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  JSONMapper;

type
  TUser = class
  public
    name: string;
    [Ignore]
    age: integer;
    isAdmin: boolean;
  end;

  [TestFixture]
  TIgnoreAttribute = class
  private
    user: TUser;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestIgnoreAttribute();
  end;

implementation

procedure TIgnoreAttribute.Setup();
begin
  user := TUser.Create();
end;

procedure TIgnoreAttribute.TearDown();
begin
  user.Free();
end;

procedure TIgnoreAttribute.TestIgnoreAttribute();
var
  jsonObject: TJSONObject;
  _: TJSONValue;
begin
  jsonObject := TJSONMapper.objectToJSON(user);
  try
    Assert.IsFalse(jsonObject.TryGetValue('age', _));
  finally
    jsonObject.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIgnoreAttribute);

end.
