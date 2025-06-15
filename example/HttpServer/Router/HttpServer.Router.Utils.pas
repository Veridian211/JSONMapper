unit HttpServer.Router.Utils;

interface

uses
  System.SysUtils,
  System.StrUtils;

type
  TRouteURISegments = TArray<string>;

function getRouteURISegments(route: string): TRouteURISegments;
function getRemainingRouteSegments(requestURI: string; controllerRoute: string): TRouteURISegments;

implementation

function getRouteURISegments(route: string): TRouteURISegments;
begin
  route := route.Trim(['/']);
  exit(SplitString(route, '/'));
end;

function getRemainingRouteSegments(requestURI: string; controllerRoute: string): TRouteURISegments;
var
  requestURISegments: TRouteURISegments;
  controllerRouteSegments: TRouteURISegments;

  remainingLength: integer;
  remainingRouteSegments: TRouteURISegments;
  i: Integer;
begin
  requestURISegments := getRouteURISegments(requestURI);
  controllerRouteSegments := getRouteURISegments(controllerRoute);

  remainingLength := Length(requestURISegments) - Length(controllerRouteSegments);

  SetLength(remainingRouteSegments, remainingLength);
  for i := 0 to remainingLength do begin
    remainingRouteSegments[i] := requestURISegments[Length(controllerRouteSegments) + i];
  end;
end;

end.
