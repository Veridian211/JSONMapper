unit ObjectToJSON.IgnoreAttribute;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  JSONMapper;

type
  TPerson = class
  public
    name: string;
    [Ignore]
    age: integer;
    isVerified: boolean;
  end;

  [TestFixture]
  TIgnoreAttribute = class
  private
    person: TPerson;
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
  person := TPerson.Create();
end;

procedure TIgnoreAttribute.TearDown();
begin
  person.Free();
end;

procedure TIgnoreAttribute.TestIgnoreAttribute();
var
  json: TJSONObject;
  _: TJSONValue;
begin
  json := TJSONMapper.objectToJSON(person);
  try
    Assert.IsFalse(json.TryGetValue('age', _));
  finally
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TIgnoreAttribute);

end.
