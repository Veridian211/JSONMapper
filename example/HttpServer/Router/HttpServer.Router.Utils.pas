unit HttpServer.Router.Utils;

interface

uses
  System.Types,
  System.SysUtils,
  System.StrUtils;

type
  TURISegments = TStringDynArray;

function trimSlashes(uri: string): string;
function getURISegments(uri: string): TURISegments;
function doPartiallyMatch(requestURI: string; controllerPath: string): boolean;
function getEndpointPath(requestURI: string; controllerPath: string): string;

implementation

function trimSlashes(uri: string): string;
begin
  exit(uri.Trim(['/']));
end;

function getURISegments(uri: string): TURISegments;
begin
  uri := trimSlashes(uri);
  exit(SplitString(uri, '/'));
end;

function doPartiallyMatch(requestURI: string; controllerPath: string): boolean;
var
  requestURISegments: TURISegments;
  controllerURISegments: TURISegments;
  i: integer;
begin
  requestURISegments := getURISegments(requestURI);
  controllerURISegments := getURISegments(controllerPath);

  if Length(requestURISegments) < Length(controllerURISegments) then begin
    exit(false);
  end;

  for i := 0 to Length(controllerURISegments) - 1 do begin
    if requestURISegments[i] <> controllerURISegments[i] then begin
      exit(false);
    end;
  end;
  exit(true);
end;

function getEndpointPath(requestURI: string; controllerPath: string): string;
var
  requestURISegments: TURISegments;
  controllerURISegments: TURISegments;

  remainingLength: integer;
  i: Integer;

  endpointPath: string;
begin
  requestURISegments := getURISegments(requestURI);
  controllerURISegments := getURISegments(controllerPath);

  remainingLength := Length(requestURISegments) - Length(controllerURISegments);

  for i := 0 to remainingLength - 1 do begin
    endpointPath := endpointPath + '/' + requestURISegments[Length(controllerURISegments) + i];
  end;

  exit(endpointPath);
end;

end.
