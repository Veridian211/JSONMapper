# JSONMapper

JSONMapper is a lightweight Delphi library for serializing and deserializing objects to and from TJSONObjects. 

Supported types:
- primitive types (string, integer, float, boolean)
- nested objects
- records
- `TList<T>` and other descendants of `TEnumerable<T>`
- arrays

## Installation

1. Copy /src/JSONMapper into your project.

2. Add <path_to_jsonmapper>/JSONMapper to Delphis searchpath.

## Usage

```delphi
program TestProgram;

{$APPTYPE CONSOLE}

uses
  System.JSON,
  JSONMapper;

type
  TUser = class
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

var
  user: TUser;
  json: TJSONObject;
begin
  user := TUser.Create();
  try
    user.id := 1;
    user.name := 'John Doe';
    user.isAdmin := true;

    json := TJSONMapper.objectToJSON(user);
    
    WriteLn(json.ToJSON());
    // Output: {"id":1,"name":"John Doe","isAdmin":true}
  finally
    FreeAndNil(user);
    FreeAndNil(json);
  end;
end.

```