unit JSONToObject.List;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  JSONMapper;

type
  TUser = class
  public
    name: string;
    age: integer;
    isAdmin: boolean;
  end;

  [TestFixture]
  TJSONToList = class
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestListOfInteger();
    [Test]
    procedure TestListOfObjects();
  end;

implementation

procedure TJSONToList.Setup();
begin
end;

procedure TJSONToList.TearDown();
begin
end;

procedure TJSONToList.TestListOfInteger();
const
  JSON_STRING = '[1,2,3]';
var
  jsonArray: TJSONArray;
  list: TList<integer>;
begin
  list := nil;
  jsonArray := TJSONArray.ParseJSONValue(JSON_STRING) as TJSONArray;
  try
    list := TJSONMapper.jsonToList<integer>(jsonArray);

    Assert.AreEqual(1, list[0]);
    Assert.AreEqual(2, list[1]);
    Assert.AreEqual(3, list[2]);
  finally
    if Assigned(list) then begin
      FreeAndNil(list);
    end;
    jsonArray.Free();
  end;
end;

procedure TJSONToList.TestListOfObjects();
const
  JSON_STRING = '[{"name":"0","age":0,"isAdmin":true},{"name":"1","age":1,"isAdmin":false},{"name":"2","age":2,"isAdmin":true}]';
var
  jsonArray: TJSONArray;
  list: TList<TUser>;
  user: TUser;
begin
  list := nil;
  jsonArray := TJSONArray.ParseJSONValue(JSON_STRING) as TJSONArray;
  try
    list := TJSONMapper.jsonToList<TUser>(jsonArray);

    user := list[0];
    Assert.AreEqual('0' , user.name);
    Assert.AreEqual(0   , user.age);
    Assert.AreEqual(true, user.isAdmin);

    user := list[1];
    Assert.AreEqual('1'  , user.name);
    Assert.AreEqual(1    , user.age);
    Assert.AreEqual(false, user.isAdmin);

    user := list[2];
    Assert.AreEqual('2' , user.name);
    Assert.AreEqual(2   , user.age);
    Assert.AreEqual(true, user.isAdmin);
  finally
    if Assigned(list) then begin
      for user in list do begin
        if Assigned(user) then begin
          FreeAndNil(user);
        end;
      end;
      FreeAndNil(list);
    end;
    jsonArray.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToList);

end.
