unit HttpServer.Router.Routes;

interface

uses
  System.Generics.Collections,
  Http.Exceptions,
  HttpServer.Router.Utils;

type
  TRoute = class
  public
    controllerClass: TClass;
    route: string;
    routeSegments: TRouteURISegments;
    constructor Create(route: string; controllerClass: TClass);
  end;

  TRoutes = class(TList<TRoute>)
  public
    procedure Add(route: string; controllerClass: TClass); reintroduce;
    destructor Destroy(); override;
  end;

implementation

{ TRoute }

constructor TRoute.Create(route: string; controllerClass: TClass);
begin
  inherited Create();
  self.route := route;
  self.controllerClass := controllerClass;
  self.routeSegments := getRouteURISegments(route);
end;

{ TRoutes }

procedure TRoutes.Add(route: string; controllerClass: TClass);
begin
  inherited Add(TRoute.Create(route, controllerClass));
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

end.
