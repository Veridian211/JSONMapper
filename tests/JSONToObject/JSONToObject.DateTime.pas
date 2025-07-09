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
  JSON_STRING = '{"dateOfBirth":"21.01.2006","lastActive":"29.06.2025 23:28:59"}';

  EXPECTED_DATE_OF_BIRTH = '2006-01-21';
  EXPECTED_LAST_ACTIVE = '2025-06-29T23:28:59.000Z';
var
  jsonObject: TJSONObject;
  user: TUser;
begin
  jsonObject := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    TJSONMapper.dateFormatterClass := TDateFormatter_Local;

    user := TJSONMapper.jsonToObject<TUser>(jsonObject);
    try
      Assert.AreEqual(user.dateOfBirth, ISO8601ToDate(EXPECTED_DATE_OF_BIRTH));
      Assert.AreEqual(user.lastActive, ISO8601ToDate(EXPECTED_LAST_ACTIVE));
    finally
      user.Free;
    end;
  finally
    TJSONMapper.dateFormatterClass := TDateFormatter_ISO8601;
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
