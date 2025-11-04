unit Test.QueryMapper.Count;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  Datasnap.DBClient,
  QueryMapper;

type
  [TestFixture]
  TBasicMappingTest = class
  private
    dataset: TClientDataSet;
    emptyDataset: TClientDataSet;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestCount();
    [Test]
    procedure IsEmpty();
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


  emptyDataset := TClientDataSet.Create(nil);
  emptyDataset.FieldDefs.Add('Name', ftString, 50);
  emptyDataset.FieldDefs.Add('age', ftInteger);
  emptyDataset.CreateDataSet;
end;

procedure TBasicMappingTest.TearDown();
begin
  dataset.Free();
  emptyDataset.Free();
end;

procedure TBasicMappingTest.TestCount();
begin
  Assert.AreEqual(1, dataset.Count());
end;

procedure TBasicMappingTest.IsEmpty();
begin
  Assert.IsTrue(emptyDataset.IsEmpty());
  Assert.IsFalse(dataset.IsEmpty());
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicMappingTest);

end.

