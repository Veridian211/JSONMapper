unit ObjectToJSON.BasicRecord;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  JSONMapper;

type
  TUser = record
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

  TUserWrapper = class
    user: TUser;
  end;

  [TestFixture]
  TRecordToJSON_Test = class
  private
    userWrapper: TUserWrapper;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestBasicRecord;
  end;

implementation

procedure TRecordToJSON_Test.Setup;
begin
  userWrapper := TUserWrapper.Create();

  userWrapper.user.id := 1;
  userWrapper.user.name := 'John Doe';
  userWrapper.user.isAdmin := true;
end;

procedure TRecordToJSON_Test.TearDown;
begin
  userWrapper.Free;
end;

procedure TRecordToJSON_Test.TestBasicRecord;
const
  EXPECTED_VALUE = '{"user":{"id":1,"name":"John Doe","isAdmin":true}}';
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONMapper.objectToJSON(userWrapper);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRecordToJSON_Test);

end.
