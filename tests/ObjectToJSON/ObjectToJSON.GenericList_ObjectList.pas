unit ObjectToJSON.GenericList_ObjectList;

interface

uses
  System.Generics.Collections,
  System.JSON,
  DUnitX.TestFramework,
  JSONMapper,
  TestObjects;

type
  [TestFixture]
  TGenericList_Test = class
  private
    userList: TList<TUser>;
//    userWithList: TUserWithList;
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

procedure TGenericList_Test.Setup;
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

procedure TGenericList_Test.TearDown;
var
  i: Integer;
begin
  for i := 0 to userList.Count-1 do begin
    userList[i].Free;
  end;
  userList.Free;
end;

procedure TGenericList_Test.TestGenericList;
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

procedure TGenericList_Test.TestObjectWithGenericList;
const
  EXPECTED_VALUE = '{}';
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create();
//  jsonObject := TJSONMapper.objectToJSON(userWithList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TGenericList_Test);

end.
