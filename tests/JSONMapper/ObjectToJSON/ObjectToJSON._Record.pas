unit ObjectToJSON._Record;

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
  TRecordToJSON = class
  private
    userWrapper: TUserWrapper;
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
  userWrapper := TUserWrapper.Create();

  userWrapper.user.id := 1;
  userWrapper.user.name := 'John Doe';
  userWrapper.user.isAdmin := true;
end;

procedure TRecordToJSON.TearDown();
begin
  userWrapper.Free();
end;

procedure TRecordToJSON.TestBasicRecord();
const
  EXPECTED_VALUE = '{"user":{"id":1,"name":"John Doe","isAdmin":true}}';
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONMapper.objectToJSON(userWrapper);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TRecordToJSON);

end.
