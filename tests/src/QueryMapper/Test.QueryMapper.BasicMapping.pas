unit Test.QueryMapper.BasicMapping;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  Datasnap.DBClient,
  QueryMapper;

type
  TPerson = class
  private
    fAge: integer;
  public
    [FieldName('Name')]
    fullName: string;
    property age: integer read fAge write fAge;
  end;

  [TestFixture]
  TBasicMappingTest = class
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
  end;

implementation

procedure TBasicMappingTest.Setup();
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

procedure TBasicMappingTest.TearDown();
begin
  dataset.Free();
end;

procedure TBasicMappingTest.TestEnumeration();
var
  person: TPerson;
  index: integer;
begin
  index := 0;
  for person in dataset.Rows<TPerson> do begin
    if index = 0 then begin
      Assert.AreEqual('Max', person.fullName);
      Assert.AreEqual(32, person.age);
    end;
    if index = 1 then begin
      Assert.AreEqual('Anna', person.fullName);
      Assert.AreEqual(23, person.age);
    end;
    inc(index);
  end;
end;

procedure TBasicMappingTest.TestAsList();
var
  personList: TList<TPerson>;
  person: TPerson;
begin
  personList := dataset.Rows<TPerson>.asList();
  try
    Assert.AreEqual('Max', personList[0].fullName);
    Assert.AreEqual(32, personList[0].age);
    Assert.AreEqual('Anna', personList[1].fullName);
    Assert.AreEqual(23, personList[1].age);
  finally
    for person in personList do begin
      person.Free();
    end;
    personList.Free();
  end;
end;

procedure TBasicMappingTest.TestAsObjectList();
var
  personList: TObjectList<TPerson>;
begin
  personList := dataset.Rows<TPerson>.asObjectList();
  try
    Assert.AreEqual('Max', personList[0].fullName);
    Assert.AreEqual(32, personList[0].age);
    Assert.AreEqual('Anna', personList[1].fullName);
    Assert.AreEqual(23, personList[1].age);
  finally
    personList.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicMappingTest);

end.

