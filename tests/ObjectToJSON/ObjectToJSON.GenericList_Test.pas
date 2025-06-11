unit ObjectToJSON.GenericList_Test;

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
    user.Id := i;
    userList.Add(user);
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
var
  json: TJSONArray;
begin
//  json := TJSONMapper.objectListToJSON(userList);
end;

procedure TGenericList_Test.TestObjectWithGenericList;
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TGenericList_Test);

end.
