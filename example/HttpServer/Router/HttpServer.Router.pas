unit HttpServer.Router;

interface

uses
  System.Rtti,
  System.JSON,
  Logger,
  Http.Exceptions,
  HttpServer.Router.Utils,
  HttpServer.Router.Registration,
  HttpServer.Router.Routes,
  HttpServer.ControllerAttribute,
  HttpServer.MethodAttributes;

type
  THttpRouter = class
  private
    logger: TLogger;
    routes: TRoutes;
    procedure discoverHttpResources();
    function findEndpoint(controllerClass: TRttiType): TRttiMethod;
  public
    constructor Create(logger: TLogger);
    procedure handleRequest(
      uri: string;
      request: TJSONObject;
      response: TJSONObject
    );
    class procedure register(httpResource: TClass);
    destructor Destroy(); override;
  end;

implementation

constructor THttpRouter.Create(logger: TLogger);
begin
  inherited Create();        
  self.logger := logger;
  
  routes := TRoutes.Create();
  
  discoverHttpResources();
end;

procedure THttpRouter.discoverHttpResources();
var
  rttiContext: TRttiContext;  
  httpResource: TRttiInstanceType;

  i: integer;
  path: string;
  controllerClass: TClass;
begin
  rttiContext := TRttiContext.Create();
  try
    for i := 0 to httpRouterRegistry.Count - 1 do begin 
      httpResource := rttiContext.GetType(httpRouterRegistry[i]) as TRttiInstanceType;
      
      if httpResource.HasAttribute(ControllerAttribute) then begin
        path := httpResource.GetAttribute<ControllerAttribute>().path;
        controllerClass := httpResource.MetaclassType;

        routes.Add(path, controllerClass);
      end;
    end;
  finally
    rttiContext.Free();
  end;
end;

procedure THttpRouter.handleRequest(
  uri: string;
  request: TJSONObject;
  response: TJSONObject
);
var
  requestURISegments: TRouteURISegments;
  route: TRoute;

  doesMatch: boolean;
  i: Integer;
  
  rttiContext: TRttiContext;
  controllerCLass: TRttiType;
  endpointMethod: TRttiMethod;
  remainingRouteSegments: TRouteURISegments;
begin
  requestURISegments := getRouteURISegments(uri);

  for route in routes do begin
    if Length(requestURISegments) < Length(route.routeSegments) then begin
      continue;
    end;

    doesMatch := true;
    for i := 0 to Length(requestURISegments) - 1 do begin
      if requestURISegments[i] <> route.routeSegments[i] then begin
        doesMatch := false;
        break;
      end;
    end;

    if doesMatch then begin
      break;
    end;
  end;

  if not doesMatch then begin
    raise ENotFoundException.Create();
  end;

  rttiContext := TRttiContext.Create();
  try
    controllerClass := rttiContext.GetType(route.controllerClass);

    endpointMethod := findEndpoint(controllerClass);
  finally
    rttiContext.Free;
  end;
end; 

function THttpRouter.findEndpoint(
  controllerClass: TRttiType
): TRttiMethod;
begin

end; 

class procedure THttpRouter.register(httpResource: TClass);
begin
  httpRouterRegistry.registerResource(httpResource);
end;

destructor THttpRouter.Destroy();
begin
  routes.Free;
  inherited;
end;

end.
