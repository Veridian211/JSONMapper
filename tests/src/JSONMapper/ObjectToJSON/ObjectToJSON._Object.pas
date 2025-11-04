unit ObjectToJSON._Object;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.DateUtils,
  JSONMapper;

type
  TPerson = class
  private
    fIsVerified: boolean;
  public
    name: string;
    age: integer;
    dateOfBirth: TDate;
    reputationScore: double;
    property isVerified: boolean read fIsVerified write fIsVerified;
  end;

  TPersonWrapper = class
  public
    person: TPerson;
    constructor Create();
    destructor Destroy(); override;
  end;

  [TestFixture]
  TBasicObjectToJSON = class
  private
    person: TPerson;
    personWrapper: TPersonWrapper;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestBasicObject();
    [Test]
    procedure TestNestedObject();
  end;

implementation

{ TBasicObjektToJSON }

procedure TBasicObjectToJSON.Setup();
begin
  person := TPerson.Create();
  personWrapper := TPersonWrapper.Create();
end;

procedure TBasicObjectToJSON.TearDown();
begin
  person.Free();
  personWrapper.Free();
end;

procedure TBasicObjectToJSON.TestBasicObject();
const
  EXPECTED_JSON = '{"name":"John Doe","age":32,"dateOfBirth":"2006-10-23",' +
    '"reputationScore":12.4,"isVerified":true}';
var
  jsonObject: TJSONObject;
begin
  person.name := 'John Doe';
  person.age := 32;
  person.isVerified := true;
  person.dateOfBirth := ISO8601ToDate('2006-10-23');
  person.reputationScore := 12.4;

  jsonObject := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(EXPECTED_JSON, jsonObject.ToJSON());
  finally
    jsonObject.Free();
  end;
end;

procedure TBasicObjectToJSON.TestNestedObject();
var
  json: TJSONObject;
  personJSON: TJSONObject;
begin
  personWrapper.person.age := 23;

  json := TJSONMapper.objectToJSON(personWrapper);
  try
    personJSON := json.GetValue('person') as TJSONObject;

    Assert.AreEqual(
      personWrapper.person.age,
      personJSON.GetValue<Integer>('age')
    );
  finally
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
  TDUnitX.RegisterTestFixture(TBasicObjectToJSON);

end.
