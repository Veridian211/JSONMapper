unit JSONToObject.List;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  JSONMapper;

type
  TPerson = class
  public
    name: string;
    age: integer;
    isVerified: boolean;
  end;

  [TestFixture]
  TJSONToList = class
  public
    [Test]
    procedure TestListOfInteger();
    [Test]
    procedure TestListOfObjects();
    [Test]
    procedure TestObjectWithList();
  end;

implementation

procedure TJSONToList.TestListOfInteger();
const
  JSON_STRING = '[1,2,3]';
var
  json: TJSONArray;
  list: TList<integer>;
begin
  list := nil;
  json := TJSONArray.ParseJSONValue(JSON_STRING) as TJSONArray;
  try
    list := TJSONMapper.jsonToList<integer>(json);

    Assert.AreEqual(1, list[0]);
    Assert.AreEqual(2, list[1]);
    Assert.AreEqual(3, list[2]);
  finally
    if Assigned(list) then begin
      FreeAndNil(list);
    end;
    json.Free();
  end;
end;

procedure TJSONToList.TestListOfObjects();
const
  JSON_STRING = '[{"name":"0","age":0,"isVerified":true},' +
    '{"name":"1","age":1,"isVerified":false},' +
    '{"name":"2","age":2,"isVerified":true}]';
var
  json: TJSONArray;
  list: TList<TPerson>;
  person: TPerson;
begin
  list := nil;
  json := TJSONArray.ParseJSONValue(JSON_STRING) as TJSONArray;
  try
    list := TJSONMapper.jsonToList<TPerson>(json);

    person := list[0];
    Assert.AreEqual('0' , person.name);
    Assert.AreEqual(0   , person.age);
    Assert.AreEqual(true, person.isVerified);

    person := list[1];
    Assert.AreEqual('1'  , person.name);
    Assert.AreEqual(1    , person.age);
    Assert.AreEqual(false, person.isVerified);

    person := list[2];
    Assert.AreEqual('2' , person.name);
    Assert.AreEqual(2   , person.age);
    Assert.AreEqual(true, person.isVerified);
  finally
    if Assigned(list) then begin
      for person in list do begin
        if Assigned(person) then begin
          FreeAndNil(person);
        end;
      end;
      FreeAndNil(list);
    end;
    json.Free();
  end;
end;

procedure TJSONToList.TestObjectWithList();
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToList);

end.
