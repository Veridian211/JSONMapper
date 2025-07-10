unit JSONToObject.DateTime;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.DateUtils,
  JSONMapper;

type
  TUser = class
  public
    dateOfBirth: TDate;
    lastActive: TDateTime;
  end;

  [TestFixture]
  TJSONToDateTime = class
  public
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestTDateTime();
    [Test]
    procedure TestDateFormatter();

    [Test]
    procedure TestInvalidDateTime();
    [Test]
    procedure TestInvalidDate();
  end;

implementation

procedure TJSONToDateTime.TearDown();
begin
  TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;
end;

procedure TJSONToDateTime.TestTDateTime();
const
  JSON_STRING = '{"dateOfBirth":"2006-01-21","lastActive":"2025-06-29T23:28:59.000Z"}';

  EXPECTED_DATE_OF_BIRTH = '2006-01-21';
  EXPECTED_LAST_ACTIVE = '2025-06-29T23:28:59.000Z';
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    user := TJSONMapper.jsonToObject<TUser>(jsonObject);
    try
      Assert.AreEqual(user.dateOfBirth, ISO8601ToDate(EXPECTED_DATE_OF_BIRTH));
      Assert.AreEqual(user.lastActive, ISO8601ToDate(EXPECTED_LAST_ACTIVE));
    finally
      user.Free();
    end;
  finally
    jsonObject.Free();
  end;
end;

procedure TJSONToDateTime.TestDateFormatter();
const
  JSON_STRING = '{"dateOfBirth":"%s","lastActive":"%s"}';

  EXPECTED_DATE_OF_BIRTH = '2006-01-21';
  EXPECTED_LAST_ACTIVE = '2025-06-29T23:28:59.000Z';
var
  expectedDateOfBirth: TDate;
  expectedLastActive: TDateTime;

  jsonString: string;
  jsonObject: TJSONObject;
  user: TUser;
begin
  TJSONMapper.dateFormatterClass := TDateFormatter_Local;

  expectedDateOfBirth := ISO8601ToDate(EXPECTED_DATE_OF_BIRTH);
  expectedLastActive := ISO8601ToDate(EXPECTED_LAST_ACTIVE);

  jsonString := Format(
    JSON_STRING,
    [DateToStr(expectedDateOfBirth), DateTimeToStr(expectedLastActive)]
  );

  jsonObject := TJSONObject.ParseJSONValue(jsonString) as TJSONObject;
  try
    user := TJSONMapper.jsonToObject<TUser>(jsonObject);
    try
      Assert.AreEqual(user.dateOfBirth, expectedDateOfBirth);
      Assert.AreEqual(user.lastActive, expectedLastActive);
    finally
      user.Free;
    end;
  finally
    jsonObject.Free();
  end;
end;

procedure TJSONToDateTime.TestInvalidDateTime();
const
  JSON_STRING = '{"dateOfBirth":"malformed date","lastActive":"2025-06-29T23:28:59.000Z"}';
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  user := nil;
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    try
      user := TJSONMapper.jsonToObject<TUser>(jsonObject);
    except
      on e: Exception do begin
        Assert.AreEqual(e.ClassType, EJSONMapperInvalidDate);
      end;
    end;
  finally
    FreeAndNil(user);
    jsonObject.Free();
  end;
end;

procedure TJSONToDateTime.TestInvalidDate();
const
  JSON_STRING = '{"dateOfBirth":"2006-01-21","lastActive":"malformed datetime"}';
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  user := nil;
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    try
      user := TJSONMapper.jsonToObject<TUser>(jsonObject);
    except
      on e: Exception do begin
        Assert.AreEqual(e.ClassType, EJSONMapperInvalidDateTime);
      end;
    end;
  finally
    FreeAndNil(user);
    jsonObject.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToDateTime);

end.
