unit QueryMapper.Test;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
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
    procedure Test();
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

procedure TQueryMapperTest.Test();
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

initialization
  TDUnitX.RegisterTestFixture(TQueryMapperTest);

end.
