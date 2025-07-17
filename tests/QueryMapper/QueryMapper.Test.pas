unit QueryMapper.Test;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  Datasnap.DBClient,
  QueryMapper;

type
  TUser = class
  public
    [FieldName('Name')]
    name: string;
    age: integer;
  end;

  [TestFixture]
  TQueryMapperTest = class
  private
    dataset: TClientDataSet;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestEnumeration();
    [Test]
    procedure TestAsList();
    [Test]
    procedure TestAsObjectList();
    [Test]
    procedure TestCount();
  end;

implementation

procedure TQueryMapperTest.Setup();
begin
  dataset := TClientDataSet.Create(nil);

  dataset.FieldDefs.Add('Name', ftString, 50);
  dataset.FieldDefs.Add('age', ftInteger);
  dataset.CreateDataSet;

  dataset.Append;
  dataset.FieldByName('Name').AsString := 'Max';
  dataset.FieldByName('age').AsInteger := 32;
  dataset.Post;

  dataset.Append;
  dataset.FieldByName('Name').AsString := 'Anna';
  dataset.FieldByName('age').AsInteger := 23;
  dataset.Post;
end;

procedure TQueryMapperTest.TearDown();
begin
  dataset.Free();
end;

procedure TQueryMapperTest.TestEnumeration();
var
  user: TUser;
  index: integer;
begin
  index := 0;
  for user in dataset.Rows<TUser> do begin
    if index = 0 then begin
      Assert.AreEqual('Max', user.name);
      Assert.AreEqual(32, user.age);
    end;
    if index = 1 then begin
      Assert.AreEqual('Anna', user.name);
      Assert.AreEqual(23, user.age);
    end;
    inc(index);
  end;
end;

procedure TQueryMapperTest.TestAsList();
var
  userList: TList<TUser>;
  user: TUser;
begin
  userList := dataset.Rows<TUser>.asList();
  try
    Assert.AreEqual('Max', userList[0].name);
    Assert.AreEqual(32, userList[0].age);
    Assert.AreEqual('Anna', userList[1].name);
    Assert.AreEqual(23, userList[1].age);
  finally
    for user in userList do begin
      user.Free;
    end;
    userList.Free;
  end;
end;

procedure TQueryMapperTest.TestAsObjectList;
var
  userList: TObjectList<TUser>;
begin
  userList := dataset.Rows<TUser>.asObjectList();
  try
    Assert.AreEqual('Max', userList[0].name);
    Assert.AreEqual(32, userList[0].age);
    Assert.AreEqual('Anna', userList[1].name);
    Assert.AreEqual(23, userList[1].age);
  finally
    userList.Free;
  end;
end;

procedure TQueryMapperTest.TestCount;
begin
  Assert.AreEqual(2, dataset.Count());
end;

initialization
  TDUnitX.RegisterTestFixture(TQueryMapperTest);

end.

