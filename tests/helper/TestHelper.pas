unit TestHelper;

interface

uses
  System.JSON;

  function JSONToString(jsonValue: TJSONValue): string;

implementation

function JSONToString(jsonValue: TJSONValue): string;
begin
  try
    exit(jsonValue.ToJSON);
  finally
    jsonValue.Free;
  end;
end;

end.
