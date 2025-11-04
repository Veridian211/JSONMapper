unit ObjectToJSON.List;

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.Generics.Collections,
  System.SysUtils,
  JSONMapper;

type
  TPerson = class
  public
    name: string;
    age: integer;
    isVerified: boolean;
  end;

  TObjectWithPersonList = class
  public
    personList: TObjectList<TPerson>;
    constructor Create(); reintroduce;
    destructor Destroy(); override;
  end;

  [TestFixture]
  TList_BasicDatatypes = class
  private
    integerList: TList<integer>;
    stringList: TList<string>;
    booleanList: TList<boolean>;
    personList: TList<TPerson>;
    personObjectList: TObjectList<TPerson>;
    objectWithPersonList: TObjectWithPersonList;
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
  personList := TList<TPerson>.Create();
  personObjectList := TObjectList<TPerson>.Create();
  objectWithPersonList := TObjectWithPersonList.Create();
end;

procedure TList_BasicDatatypes.TearDown();
var
  person: TPerson;
begin
  integerList.Free;
  stringList.Free;
  booleanList.Free;
  for person in personList do begin
    person.Free;
  end;
  personList.Free();
  personObjectList.Free();
  objectWithPersonList.Free();
end;

procedure TList_BasicDatatypes.TestIntegerList();
const
  EXPECTED_VALUE = '[0,1,2,3]';
var
  i: integer;
  json: TJSONArray;
begin
  for i := 0 to 3 do begin
    integerList.Add(i);
  end;

  json := TJSONMapper.listToJSON(integerList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TList_BasicDatatypes.TestStringList();
const
  EXPECTED_VALUE = '["0","1","2","3"]';
var
  i: integer;
  json: TJSONArray;
begin
  for i := 0 to 3 do begin
    stringList.Add(IntToStr(i));
  end;

  json := TJSONMapper.listToJSON(stringList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TList_BasicDatatypes.TestBoolList();
const
  EXPECTED_VALUE = '[false,true,true,true]';
var
  i: integer;
  isBiggerThanZero: Boolean;
  json: TJSONArray;
begin
  for i := 0 to 3 do begin
    isBiggerThanZero := i > 0;
    booleanList.Add(isBiggerThanZero);
  end;

  json := TJSONMapper.listToJSON(booleanList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TList_BasicDatatypes.TestTListOfObjects();
const
  EXPECTED_VALUE = '[{"name":"0","age":0,"isVerified":true},' +
    '{"name":"1","age":1,"isVerified":false},' +
    '{"name":"2","age":2,"isVerified":true}]';
var
  i: integer;
  person: TPerson;
  json: TJSONArray;
begin
  for i := 0 to 2 do begin
    person := TPerson.Create();
    personList.Add(person);

    person.name := IntToStr(i);
    person.age := i;
    person.isVerified := (i mod 2) = 0;
  end;

  json := TJSONMapper.listToJSON(personList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TList_BasicDatatypes.TestTObjectList;
const
  EXPECTED_VALUE = '[{"name":"0","age":0,"isVerified":true},' +
    '{"name":"1","age":1,"isVerified":false},' +
    '{"name":"2","age":2,"isVerified":true}]';
var
  i: integer;
  person: TPerson;
  json: TJSONArray;
begin
  for i := 0 to 2 do begin
    person := TPerson.Create();
    personObjectList.Add(person);

    person.name := IntToStr(i);
    person.age := i;
    person.isVerified := (i mod 2) = 0;
  end;

  json := TJSONMapper.listToJSON(personObjectList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

procedure TList_BasicDatatypes.TestObjectWithTObjectList();
const
  EXPECTED_VALUE = '{"personList":[{"name":"0","age":0,"isVerified":true},' +
    '{"name":"1","age":1,"isVerified":false},' +
    '{"name":"2","age":2,"isVerified":true}]}';
var
  i: integer;
  person: TPerson;
  json: TJSONObject;
begin
  for i := 0 to 2 do begin
    person := TPerson.Create();
    objectWithPersonList.personList.Add(person);

    person.name := IntToStr(i);
    person.age := i;
    person.isVerified := (i mod 2) = 0;
  end;

  json := TJSONMapper.objectToJSON(objectWithPersonList);
  try
    Assert.AreEqual(EXPECTED_VALUE, json.ToJSON());
  finally
    json.Free();
  end;
end;

{ TObjectWithPersonList }

constructor TObjectWithPersonList.Create();
begin
  inherited;
  personList := TObjectList<TPerson>.Create();
end;

destructor TObjectWithPersonList.Destroy();
begin
  personList.Free();
  inherited;
end;

initialization
  TDUnitX.RegisterTestFixture(TList_BasicDatatypes);

end.
