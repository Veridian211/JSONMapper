# JSONMapper

JSONMapper is a lightweight Delphi library for serializing and deserializing objects to and from TJSONObjects. 

Supported types:
- primitive types (string, integer, float, boolean)
- TDateTime & TDate
- nested objects
- records
- `TList<T>` and other descendants of `TEnumerable<T>`
- arrays
- Variant

## Installation

1. Copy `/src/JSONMapper` into your project.

2. Add `<src_to_JSONMapper>/JSONMapper` to Delphis searchpath.

## Usage

```delphi
program TestProgram;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.JSON,
  JSONMapper;

type
  TUser = class
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

const
  JSON_STRING = '{"id":1,"name":"John Doe","isAdmin":true}';
var
  user: TUser;
  json: TJSONObject;
begin
  json := TJSONObject.ParseJSONValue(JSON_STRING) as TJSONObject;
  user := TUser.Create();
  try
    TJSONMapper.jsonToObject(json, user);
    WriteLn(Format(
      'id = %d, name = %s, isAdmin = %s',
      [user.id, user.name, BoolToStr(user.isAdmin, true)]
    ));
    // Output: id = 1, name = John Doe, isAdmin = True

    user.id := 2;
    user.name := 'Jane Roe';
    user.isAdmin := false;

    TJSONMapper.objectToJSON(user, json);
    WriteLn(json.ToJSON());
    // Output: {"id":2,"name":"Jane Roe","isAdmin":false}
  finally
    FreeAndNil(user);
    FreeAndNil(json);
  end;
end.

```