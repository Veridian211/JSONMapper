unit ObjectToJSON.DateTime;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  System.DateUtils,
  JSONMapper;

type
  TPerson = class
  public
    dateOfBirth: TDate;
    lastActive: TDateTime;
  end;

  [TestFixture]
  TDateTimeToJSON = class
  private
    person: TPerson;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestTDateTime();
    [Test]
    procedure TestDateFormatter();
  end;

implementation

procedure TDateTimeToJSON.Setup();
const
  DATE_OF_BIRTH = '2006-01-21';
  LAST_ACTIVE = '2025-06-29T23:28:59.000Z';
begin
  person := TPerson.Create();

  person.dateOfBirth := ISO8601ToDate(DATE_OF_BIRTH);
  person.lastActive := ISO8601ToDate(LAST_ACTIVE);
end;

procedure TDateTimeToJSON.TearDown();
begin
  person.Free();
  TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;
end;

procedure TDateTimeToJSON.TestTDateTime();
const
  EXPECTED_VALUE = '{"dateOfBirth":"2006-01-21","lastActive":"2025-06-29T23:28:59.000Z"}';
var
  json: TJSONObject;
begin
  json := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TDateTimeToJSON.TestDateFormatter();
const
  EXPECTED_JSON = '{"dateOfBirth":"%s","lastActive":"%s"}';
var
  expectedJSON: string;
  json: TJSONObject;
begin
  TJSONMapper.dateFormatterClass := TDateFormatter_Local;

  expectedJSON := Format(
    EXPECTED_JSON,
    [DateToStr(person.dateOfBirth), DateTimeToStr(person.lastActive)]
  );

  json := TJSONMapper.objectToJSON(person);
  try
    Assert.AreEqual(expectedJSON, json.ToJSON());
  finally
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDateTimeToJSON);

end.
