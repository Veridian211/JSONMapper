unit ObjectToJSON.List;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  JSONMapper;

type
  TUser = class
  public
    name: string;
    age: integer;
    isAdmin: boolean;
  end;

  TObjectWithUserList = class
  public
    users: TObjectList<TUser>;
    constructor Create(); reintroduce;
    destructor Destroy(); override;
  end;

  [TestFixture]
  TList_BasicDatatypes = class
  private
    integerList: TList<integer>;
    stringList: TList<string>;
    booleanList: TList<boolean>;
    userList: TList<TUser>;
    userObjectList: TObjectList<TUser>;
    objectWithUserList: TObjectWithUserList;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestIntegerList();
    [Test]
    procedure TestStringList();
    [Test]
    procedure TestBoolList();

    [Test]
    procedure TestTListOfObjects();
    [Test]
    procedure TestTObjectList();
    [Test]
    procedure TestObjectWithTObjectList();
  end;

implementation

procedure TList_BasicDatatypes.Setup();
begin
  integerList := TList<integer>.Create();
  stringList := TList<string>.Create();
  booleanList := TList<boolean>.Create();
  userList := TList<TUser>.Create();
  userObjectList := TObjectList<TUser>.Create();
  objectWithUserList := TObjectWithUserList.Create();
end;

procedure TList_BasicDatatypes.TearDown();
var
  user: TUser;
begin
  integerList.Free;
  stringList.Free;
  booleanList.Free;
  for user in userList do begin
    user.Free;
  end;
  userList.Free();
  userObjectList.Free();
  objectWithUserList.Free();
end;

procedure TList_BasicDatatypes.TestIntegerList();
const
  EXPECTED_VALUE = '[0,1,2,3]';
var
  i: integer;
  jsonArray: TJSONArray;
begin
  for i := 0 to 3 do begin
    integerList.Add(i);
  end;

  jsonArray := TJSONMapper.listToJSON(integerList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestStringList();
const
  EXPECTED_VALUE = '["0","1","2","3"]';
var
  i: integer;
  jsonArray: TJSONArray;
begin
  for i := 0 to 3 do begin
    stringList.Add(IntToStr(i));
  end;

  jsonArray := TJSONMapper.listToJSON(stringList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestBoolList();
const
  EXPECTED_VALUE = '[false,true,true,true]';
var
  i: integer;
  isBiggerThanZero: Boolean;
  jsonArray: TJSONArray;
begin
  for i := 0 to 3 do begin
    isBiggerThanZero := i > 0;
    booleanList.Add(isBiggerThanZero);
  end;

  jsonArray := TJSONMapper.listToJSON(booleanList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestTListOfObjects();
const
  EXPECTED_VALUE = '[{"name":"0","age":0,"isAdmin":true},{"name":"1","age":1,"isAdmin":false},{"name":"2","age":2,"isAdmin":true}]';
var
  i: integer;
  user: TUser;
  jsonArray: TJSONArray;
begin
  for i := 0 to 2 do begin
    user := TUser.Create();
    userList.Add(user);

    user.name := IntToStr(i);
    user.age := i;
    user.isAdmin := (i mod 2) = 0;
  end;

  jsonArray := TJSONMapper.listToJSON(userList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestTObjectList;
const
  EXPECTED_VALUE = '[{"name":"0","age":0,"isAdmin":true},{"name":"1","age":1,"isAdmin":false},{"name":"2","age":2,"isAdmin":true}]';
var
  i: integer;
  user: TUser;
  jsonArray: TJSONArray;
begin
  for i := 0 to 2 do begin
    user := TUser.Create();
    userObjectList.Add(user);

    user.name := IntToStr(i);
    user.age := i;
    user.isAdmin := (i mod 2) = 0;
  end;

  jsonArray := TJSONMapper.listToJSON(userObjectList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestObjectWithTObjectList();
const
  EXPECTED_VALUE = '{"users":[{"name":"0","age":0,"isAdmin":true},{"name":"1","age":1,"isAdmin":false},{"name":"2","age":2,"isAdmin":true}]}';
var
  i: integer;
  user: TUser;
  jsonObject: TJSONObject;
begin
  for i := 0 to 2 do begin
    user := TUser.Create();
    objectWithUserList.users.Add(user);

    user.name := IntToStr(i);
    user.age := i;
    user.isAdmin := (i mod 2) = 0;
  end;

  jsonObject := TJSONMapper.objectToJSON(objectWithUserList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free();
  end;
end;

{ TObjectWithUserList }

constructor TObjectWithUserList.Create();
begin
  inherited;
  users := TObjectList<TUser>.Create();
end;

destructor TObjectWithUserList.Destroy();
begin
  users.Free();
  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TList_BasicDatatypes);

end.
