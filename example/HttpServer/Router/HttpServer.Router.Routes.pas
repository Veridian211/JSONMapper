unit HttpServer.Router.Routes;

interface

uses
  System.Rtti,
  System.Generics.Collections,
  Http.Exceptions,
  HttpServer.Router.Endpoint,
  HttpServer.Router.Utils,
  HttpServer.MethodAttributes;

type
  TRoute = class
  public
    controllerClass: TClass;
    path: string;
    pathSegments: TURISegments;
    constructor Create(path: string; controllerClass: TClass);
  end;

  TRoutes = class(TList<TRoute>)
  public
    function Add(path: string; controllerClass: TClass): TRoute; reintroduce;
    function findRouteForURI(uri: string): TRoute;
    destructor Destroy(); override;
  end;

implementation

{ TRoute }

constructor TRoute.Create(path: string; controllerClass: TClass);
begin
  inherited Create();
  self.path := path;
  self.controllerClass := controllerClass;
  self.pathSegments := getURISegments(path);
end;

{ TRoutes }

function TRoutes.Add(path: string; controllerClass: TClass): TRoute;
var
  route: TRoute;
begin
  route := TRoute.Create(path, controllerClass);
  inherited Add(route);
  exit(route);
end;

destructor TRoutes.Destroy;
var
  route: TRoute;
begin
  for route in self do begin
    route.Free;
  end;

  inherited;
end;

function TRoutes.findRouteForURI(uri: string): TRoute;
var
  route: TRoute;
begin
  for route in self do begin
    if doPartiallyMatch(uri, route.path) then begin
      exit(route);
    end;
  end;

  raise ENotFoundException.Create();
end;

end.
