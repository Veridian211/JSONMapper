unit Test.QueryMapper.GetOne;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  QueryMapper;

type
  TPerson = class
  public
    name: string;
    age: integer;
  end;

  [TestFixture]
  TGetOneTest = class
  private
    dataset: TClientDataSet;
    emptyDataset: TClientDataSet;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test;
    [Test]
    procedure TestEmptyDataset;
  end;

implementation

procedure TGetOneTest.Setup();
begin
  dataset := TClientDataSet.Create(nil);

  dataset.FieldDefs.Add('Name', ftString, 50);
  dataset.FieldDefs.Add('age', ftInteger);
  dataset.CreateDataSet;

  dataset.Append;
  dataset.FieldByName('Name').AsString := 'Max';
  dataset.FieldByName('age').AsInteger := 32;
  dataset.Post;

  emptyDataset := TClientDataset.Create(nil);
  emptyDataset.FieldDefs.Add('Name', ftString, 50);
  emptyDataset.FieldDefs.Add('age', ftInteger);
  emptyDataset.CreateDataSet;
end;

procedure TGetOneTest.TearDown();
begin
  dataset.Free();
  emptyDataset.Free();
end;

procedure TGetOneTest.Test;
var
  person: TPerson;
begin
  person := dataset.GetOne<TPerson>();
  try
    Assert.AreEqual('Max', person.name);
    Assert.AreEqual(32, person.age);
  finally
    person.Free;
  end;
end;

procedure TGetOneTest.TestEmptyDataset();
var
  person: TPerson;
begin
  person := nil;
  try
    try
      person := emptyDataset.GetOne<TPerson>();
    except
      on e: Exception do begin
        Assert.AreEqual(EQueryMapperNotExactlyOneRecord, e.ClassType);
      end;
    end;
  finally
    if Assigned(person) then begin
      person.Free();
    end;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TGetOneTest);

end.
