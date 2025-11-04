unit JSONToObject.JSONKeyAttribute;

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
  public
    [Test]
    procedure Test();
  end;

implementation

procedure TestJSONKeyAttribute.Test();
const
  JSON_STRING = '{"personName":"John Doe","age":23}';
var
  person: TPerson;
  json: TJSONObject;
begin
  person := nil;
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    person := TJSONMapper.jsonToObject<TPerson>(json);
    Assert.AreEqual('John Doe', person.name);
    Assert.AreEqual(23, person.age);
  finally
    if Assigned(person) then begin
      FreeAndNil(person);
    end;
    json.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TestJSONKeyAttribute);

end.
