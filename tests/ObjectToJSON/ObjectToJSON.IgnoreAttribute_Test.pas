unit ObjectToJSON.IgnoreAttribute_Test;

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
  json: TJSONObject;
  _: TJSONValue;
begin
  json := TJSONMapper.objectToJSON(obj);
  Assert.IsFalse(json.TryGetValue('id', _));
end;

initialization
  TDUnitX.RegisterTestFixture(TIgnoreAttribute_Test);

end.
