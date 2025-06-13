unit ObjectToJSON.IgnoreAttribute;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  TestObjects,
  TestHelper,
  JSONMapper;

type
  [TestFixture]
  TIgnoreAttribute_Test = class
  private
    obj: TUserWithIgnoreAttribute;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestIgnoreAttribute;
  end;

implementation

procedure TIgnoreAttribute_Test.Setup;
begin
  obj := TUserWithIgnoreAttribute.Create();
end;

procedure TIgnoreAttribute_Test.TearDown;
begin
  obj.Free;
end;

procedure TIgnoreAttribute_Test.TestIgnoreAttribute;
var
  jsonObject: TJSONObject;
  _: TJSONValue;
begin
  jsonObject := TJSONMapper.objectToJSON(obj);
  try
    Assert.IsFalse(jsonObject.TryGetValue('id', _));
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIgnoreAttribute_Test);

end.
