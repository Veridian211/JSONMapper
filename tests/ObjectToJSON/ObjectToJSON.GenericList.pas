unit ObjectToJSON.GenericList;

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

  [TestFixture]
  TList_BasicDatatypes = class
  private
    integerList: TList<integer>;
    stringList: TList<string>;
    booleanList: TList<boolean>;
    userList: TList<TUser>;
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
    procedure TestGenericList();
    [Test]
    procedure TestObjectWithGenericList();
  end;

implementation

procedure TList_BasicDatatypes.Setup();
var
  i: Integer;
  isBiggerThanZero: boolean;
  user: TUser;
begin
  integerList := TList<integer>.Create();
  for i := 0 to 3 do begin
    integerList.Add(i);
  end;

  stringList := TList<string>.Create();
  for i := 0 to 3 do begin
    stringList.Add(IntToStr(i));
  end;

  booleanList := TList<boolean>.Create();
  for i := 0 to 3 do begin
    isBiggerThanZero := i > 0;
    booleanList.Add(isBiggerThanZero);
  end;

  userList := TList<TUser>.Create();
  for i := 0 to 2 do begin
    user := TUser.Create();
    userList.Add(user);

    user.age := i;
  end;
end;

procedure TList_BasicDatatypes.TearDown();
var
  i: Integer;
begin
  integerList.Free;
  stringList.Free;
  booleanList.Free;

  for i := 0 to userList.Count-1 do begin
    userList[i].Free();
  end;
  userList.Free();
end;

procedure TList_BasicDatatypes.TestIntegerList();
const
  EXPECTED_VALUE = '[0,1,2,3]';
var
  jsonArray: TJSONArray;
begin
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
  jsonArray: TJSONArray;
begin
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
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(booleanList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());    
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestGenericList();
const
  EXPECTED_VALUE = '[{"name":"","age":0,"isAdmin":false},{"name":"","age":1,"isAdmin":false},{"name":"","age":2,"isAdmin":false}]';
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(userList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());
  finally
    jsonArray.Free();
  end;
end;

procedure TList_BasicDatatypes.TestObjectWithGenericList();
const
  EXPECTED_VALUE = '{}';
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create();
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonObject.ToJSON());
  finally
    jsonObject.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TList_BasicDatatypes);

end.
