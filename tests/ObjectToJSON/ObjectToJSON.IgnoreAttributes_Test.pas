unit ObjectToJSON.IgnoreAttributes_Test;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  TestObjects,
  TestHelper,
  JSONMapper;

type
  [TestFixture]
  TObjectToJSON_IgnoreAttribute_Test = class
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

procedure TObjectToJSON_IgnoreAttribute_Test.Setup;
begin
  obj := TUserWithIgnoreAttribute.Create();
end;

procedure TObjectToJSON_IgnoreAttribute_Test.TearDown;
begin
  obj.Free;
end;

procedure TObjectToJSON_IgnoreAttribute_Test.TestIgnoreAttribute;
var
  json: TJSONObject;
  _: TJSONValue;
begin
  json := TJSONMapper.objectToJSON<TUserWithIgnoreAttribute>(obj);
  Assert.IsFalse(json.TryGetValue('id', _));
end;

initialization
  TDUnitX.RegisterTestFixture(TObjectToJSON_IgnoreAttribute_Test);

end.
