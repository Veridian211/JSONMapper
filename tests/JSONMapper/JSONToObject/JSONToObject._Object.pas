unit JSONToObject._Object;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  JSONMapper;

type
  TPerson = class
  private
    fIsVerified: boolean;
  public
    name: string;
    age: integer;
    property isVerified: Boolean read fIsVerified write fIsVerified;
  end;

  TPersonWrapper = class
  public
    person: TPerson;
    constructor Create();
    destructor Destroy(); override;
  end;

  [TestFixture]
  TJSONToObject = class
  private
  public
    [Test]
    procedure TestBasicObject();
    [Test]
    procedure TestNestedObject();
  end;

implementation

procedure TJSONToObject.TestBasicObject();
const
  JSON_STRING = '{"name":"John Doe","age":23,"isVerified":true}';
var
  json: TJSONObject;
  person: TPerson;
begin
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    person := TJSONMapper.jsonToObject<TPerson>(json);

    Assert.AreEqual(23, person.age);
    Assert.AreEqual('John Doe', person.name);
    Assert.AreEqual(true, person.isVerified);
  finally
    if Assigned(person) then begin
      FreeAndNil(person);
    end;
    json.Free();
  end;
end;

procedure TJSONToObject.TestNestedObject();
const
  JSON_STRING = '{"person":{"name":"John Doe","age":23,"isVerified":true}}';
var
  json: TJSONObject;
  personWrapper: TPersonWrapper;
  person: TPerson;
begin
  personWrapper := nil;

  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    personWrapper := TJSONMapper.JSONToObject<TPersonWrapper>(json);

    person := personWrapper.person;
    Assert.AreEqual(23, person.age);
    Assert.AreEqual('John Doe', person.name);
    Assert.AreEqual(true, person.isVerified);
  finally
    if Assigned(personWrapper) then begin
      FreeAndNil(personWrapper);
    end;
    json.Free();
  end;
end;

{ TPersonWrapper }

constructor TPersonWrapper.Create();
begin
  inherited;
  person := TPerson.Create();
end;

destructor TPersonWrapper.Destroy();
begin
  person.Free();
  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject);

end.
