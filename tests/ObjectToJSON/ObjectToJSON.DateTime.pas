unit ObjectToJSON.DateTime;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  System.DateUtils,
  JSONMapper;

type
  TUser = class
  public
    dateOfBirth: TDate;
    lastActive: TDateTime;
  end;

  [TestFixture]
  TDateTimeToJSON = class
  private
    user: TUser;
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
  user := TUser.Create();

  user.dateOfBirth := ISO8601ToDate(DATE_OF_BIRTH);
  user.lastActive := ISO8601ToDate(LAST_ACTIVE);
end;

procedure TDateTimeToJSON.TearDown();
begin
  user.Free();
  TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;
end;

procedure TDateTimeToJSON.TestTDateTime();
const
  EXPECTED_VALUE = '{"dateOfBirth":"2006-01-21","lastActive":"2025-06-29T23:28:59.000Z"}';
var
  json: TJSONObject;
begin
  json := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free;
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
    [DateToStr(user.dateOfBirth), DateTimeToStr(user.lastActive)]
  );

  json := TJSONMapper.objectToJSON(user);
  try
    Assert.AreEqual(expectedJSON, json.ToJSON());
  finally
    json.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDateTimeToJSON);

end.
