unit ObjectToJSON.GenericList_BasicDatatypes;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  JSONMapper;

type
  [TestFixture]
  TList_BasicDatatypes = class
  private
    integerList: TList<integer>;
    stringList: TList<string>;
    booleanList: TList<boolean>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestIntegerList;
    [Test]
    procedure TestStringList;
    [Test]
    procedure TestBoolList;
  end;

implementation

procedure TList_BasicDatatypes.Setup;
var
  i: Integer;
  isBiggerThanZero: boolean;
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
end;

procedure TList_BasicDatatypes.TearDown;
begin
  integerList.Free;
  stringList.Free;
  booleanList.Free;
end;

procedure TList_BasicDatatypes.TestIntegerList;
const
  EXPECTED_VALUE = '[0,1,2,3]';
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(integerList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());    
  finally
    jsonArray.Free;
  end;
end;

procedure TList_BasicDatatypes.TestStringList;
const
  EXPECTED_VALUE = '["0","1","2","3"]';
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(stringList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());    
  finally
    jsonArray.Free;
  end;
end;  

procedure TList_BasicDatatypes.TestBoolList;
const
  EXPECTED_VALUE = '[false,true,true,true]';
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONMapper.listToJSON(booleanList);
  try
    Assert.AreEqual(EXPECTED_VALUE, jsonArray.ToJSON());    
  finally
    jsonArray.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TList_BasicDatatypes);

end.
