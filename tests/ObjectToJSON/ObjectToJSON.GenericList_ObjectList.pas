unit ObjectToJSON.GenericList_ObjectList;

interface

uses
  System.Generics.Collections,
  System.JSON,
  DUnitX.TestFramework,
  JSONMapper;

type
  TUser = class
  public
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

  [TestFixture]
  TList_ObjectList = class
  private
    userList: TList<TUser>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestGenericList;
    [Test]
    procedure TestObjectWithGenericList;
  end;

implementation

procedure TList_ObjectList.Setup;
var
  user: TUser;
  i: Integer;
begin
  userList := TList<TUser>.Create();
  for i := 0 to 2 do begin
    user := TUser.Create();
    userList.Add(user);

    user.Id := i;
  end;
end;

procedure TList_ObjectList.TearDown;
var
  i: Integer;
begin
  for i := 0 to userList.Count-1 do begin
    userList[i].Free;
  end;
  userList.Free;
end;

procedure TList_ObjectList.TestGenericList;
const
  EXPECTED_VALUE = '[{"id":0,"name":"","isAdmin":false},{"id":1,"name":"","isAdmin":false},{"id":2,"name":"","isAdmin":false}]';
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(userList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free;
  end;
end;

procedure TList_ObjectList.TestObjectWithGenericList;
const
  EXPECTED_VALUE = '{}';
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create();
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TList_ObjectList);

end.
