unit JSONToObject.List;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON,
  System.Generics.Collections,
  JSONMapper;

type
  TUser = class
  public
    name: string;
    age: integer;
    isAdmin: boolean;
  end;

  [TestFixture]
  TJSONToList = class
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();

    [Test]
    procedure TestIntegerList();
  end;

implementation

procedure TJSONToList.Setup();
begin
end;

procedure TJSONToList.TearDown();
begin
end;

procedure TJSONToList.TestIntegerList();
const
  JSON_STRING = '[1,2,3]';
var
  jsonArray: TJSONArray;
  list: TList<integer>;
begin
  list := nil;
  jsonArray := TJSONArray.ParseJSONValue(JSON_STRING) as TJSONArray;
  try
    list := TJSONMapper.jsonToList<integer>(jsonArray);

//    Assert.AreEqual(list[0], 1);
//    Assert.AreEqual(list[1], 2);
//    Assert.AreEqual(list[2], 3);
  finally
    if Assigned(list) then begin
      FreeAndNil(list);
    end;
    jsonArray.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONToList);

end.
