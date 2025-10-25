unit ObjectToJSON._Record;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  JSONMapper;

type
  TPerson = record
    id: integer;
    name: string;
    isVerified: boolean;
  end;

  TPersonWrapper = class
    person: TPerson;
  end;

  [TestFixture]
  TRecordToJSON = class
  private
    personWrapper: TPersonWrapper;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestBasicRecord();
  end;

implementation

procedure TRecordToJSON.Setup();
begin
  personWrapper := TPersonWrapper.Create();

  personWrapper.person.id := 1;
  personWrapper.person.name := 'John Doe';
  personWrapper.person.isVerified := true;
end;

procedure TRecordToJSON.TearDown();
begin
  personWrapper.Free();
end;

procedure TRecordToJSON.TestBasicRecord();
const
  EXPECTED_VALUE = '{"person":{"id":1,"name":"John Doe","isVerified":true}}';
var
  json: TJSONObject;
begin
  json := TJSONMapper.objectToJSON(personWrapper);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRecordToJSON);

end.
