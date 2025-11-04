unit ObjectToJSON.Arrays;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  JSONMapper;

type
  TArrayWrapper = class
    integerArray: TArray<integer>;
    stringArray: TArray<string>;
    booleanArray: TArray<boolean>;
  end;

  [TestFixture]
  TArrayToJSON = class
  private
    arrayWrapper: TArrayWrapper;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestBasicArray();
  end;

implementation

procedure TArrayToJSON.Setup();
var
  i: Integer;
  isBiggerThanZero: boolean;
begin
  arrayWrapper := TArrayWrapper.Create();

  SetLength(arrayWrapper.integerArray, 3);
  for i := 0 to 2 do begin
    arrayWrapper.integerArray[i] := i;
  end;

  SetLength(arrayWrapper.stringArray, 3);
  for i := 0 to 2 do begin
    arrayWrapper.stringArray[i] := IntToStr(i);
  end;

  SetLength(arrayWrapper.booleanArray, 3);
  for i := 0 to 2 do begin
    isBiggerThanZero := i > 0;
    arrayWrapper.booleanArray[i] := isBiggerThanZero;
  end;
end;

procedure TArrayToJSON.TearDown();
begin
  arrayWrapper.Free();
end;

procedure TArrayToJSON.TestBasicArray();
const
  EXPECTED_INTEGER_ARRAY = '[0,1,2]';
  EXPECTED_STRING_ARRAY = '["0","1","2"]';
  EXPECTED_BOOLEAN_ARRAY = '[false,true,true]';
var
  json: TJSONObject;
  jsonArray: TJSONValue;
begin
  json := TJSONMapper.objectToJSON(arrayWrapper);
  try
    jsonArray := json.GetValue('integerArray');
    Assert.AreEqual(EXPECTED_INTEGER_ARRAY, jsonArray.ToJSON());

    jsonArray := json.GetValue('stringArray');
    Assert.AreEqual(EXPECTED_STRING_ARRAY, jsonArray.ToJSON());

    jsonArray := json.GetValue('booleanArray');
    Assert.AreEqual(EXPECTED_BOOLEAN_ARRAY, jsonArray.ToJSON());
  finally
    json.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TArrayToJSON);

end.
