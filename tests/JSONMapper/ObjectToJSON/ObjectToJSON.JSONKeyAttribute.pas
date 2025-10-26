unit ObjectToJSON.JSONKeyAttribute;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  JSONMapper;

type
  TPerson = class
    [JSONKey('personName')]
    name: string;
    age: integer;
  end;

  [TestFixture]
  TestJSONKeyAttribute = class
  private
    person: TPerson;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure Teardown;
    [Test]
    procedure Test();
  end;

implementation

procedure TestJSONKeyAttribute.Setup();
begin
  person := TPerson.Create();
end;

procedure TestJSONKeyAttribute.Teardown();
begin
  FreeAndNil(person);
end;

procedure TestJSONKeyAttribute.Test();
var
  json: TJSONObject;
begin
  person.name := 'John Doe';
  person.age := 23;

  json := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(json.GetValue<string>('personName'), person.name);
    Assert.AreEqual(json.GetValue<integer>('age'), person.age);
  finally
    json.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestJSONKeyAttribute);

end.
