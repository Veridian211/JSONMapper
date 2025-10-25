unit JSONToObject._Record;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.Rtti,
  JSONMapper;

type
  TPerson = record
    name: string;
    age: integer;
    isVerified: boolean;
  end;

  TPersonWrapper = class
    person: TPerson;
    constructor Create();
  end;

  [TestFixture]
  TJSONToObject_Record = class
  public
    [Test]
    procedure Test();
    [Test]
    procedure TestNestedObject();
  end;

implementation

procedure TJSONToObject_Record.Test();
const
  JSON_STRING = '{"name":"John Doe","age":23,"isVerified":true}';
var
  json: TJSONObject;
  personValue: TValue;
  person: TPerson;
begin
  person := Default(TPerson);
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    personValue := TJSONMapper.jsonToRecord(@person, TypeInfo(TPerson), json);
    person := personValue.AsType<TPerson>;

    Assert.AreEqual(json.GetValue('age').AsType<Integer>, person.age);
    Assert.AreEqual(json.GetValue('name').AsType<string>, person.name);
    Assert.AreEqual(json.GetValue('isVerified').AsType<Boolean>, person.isVerified);
  finally
    json.Free();
  end;
end;

procedure TJSONToObject_Record.TestNestedObject();
const
  JSON_STRING = '{"person":{"name":"John Doe","age":23,"isVerified":true}}';
var
  json: TJSONObject;
  personJSON: TJSONObject;
  personWrapper: TPersonWrapper;
  person: TPerson;
begin
  personWrapper := nil;

  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  try
    personWrapper := TJSONMapper.JSONToObject<TPersonWrapper>(json);

    personJSON := json.GetValue('person') as TJSONObject;
    person := personWrapper.person;

    Assert.AreEqual(personJSON.GetValue('age').AsType<Integer>, person.age);
    Assert.AreEqual(personJSON.GetValue('name').AsType<string>, person.name);
    Assert.AreEqual(personJSON.GetValue('isVerified').AsType<Boolean>, person.isVerified);
  finally
    if Assigned(personWrapper) then begin
      FreeAndNil(personWrapper);
    end;
    json.Free();
  end;
end;

{ TPersonWrapper }

constructor TPersonWrapper.Create();
begin
  self.person := Default(TPerson);
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToObject_Record);

end.
