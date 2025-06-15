unit HttpServer.Router;

interface

uses
  System.Rtti,
  System.TypInfo,
  System.JSON,
  Logger,
  JSONMapper,
  Http.HTTPMethods,
  Http.Exceptions,
  HttpServer.Router.Utils,
  HttpServer.Router.Registration,
  HttpServer.Router.Routes,
  HttpServer.Router.Endpoint,
  HttpServer.ControllerAttribute,
  HttpServer.MethodAttributes,
  HttpServer.ParamAttributes,
  User.UserDataClass;

type
  THttpRouter = class
  private
    logger: TLogger;
    routes: TRoutes;
    procedure discoverHttpResources();
    procedure invokeMethod(
      controllerClass: TClass;
      endpoint: TEndpoint;
      request: TJSONObject;
      response: TJSONObject
    );
  public
    constructor Create(logger: TLogger);
    procedure handleRequest(
      httpMethod: THttpMethod;
      uri: string;
      request : TJSONObject;
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
  i: integer;

  httpResource: TRttiInstanceType;
  path: string;
  controllerClass: TClass;
  route: TRoute;

  endpointMethod: TRttiMethod;
begin
  rttiContext := TRttiContext.Create();
  try
    for i := 0 to httpRouterRegistry.Count - 1 do begin
      httpResource := rttiContext.GetType(httpRouterRegistry[i]) as TRttiInstanceType;

      if httpResource.HasAttribute(ControllerAttribute) then begin
        path := httpResource.GetAttribute<ControllerAttribute>().path;
        controllerClass := httpResource.MetaclassType;

        route := routes.Add(path, controllerClass);

        for endpointMethod in httpResource.GetMethods() do begin
          if endpointMethod.HasAttribute(GetAttribute) then begin
            route.endpoints.add(
              endpointMethod.GetAttribute<GetAttribute>().method,
              endpointMethod.GetAttribute<GetAttribute>().path,
              endpointMethod
            );
          end;
          if endpointMethod.HasAttribute(PostAttribute) then begin
            route.endpoints.add(
              endpointMethod.GetAttribute<PostAttribute>().method,
              endpointMethod.GetAttribute<PostAttribute>().path,
              endpointMethod
            );
          end;
          if endpointMethod.HasAttribute(PutAttribute) then begin
            route.endpoints.add(
              endpointMethod.GetAttribute<PutAttribute>().method,
              endpointMethod.GetAttribute<PutAttribute>().path,
              endpointMethod
            );
          end;
          if endpointMethod.HasAttribute(DeleteAttribute) then begin
            route.endpoints.add(
              endpointMethod.GetAttribute<DeleteAttribute>().method,
              endpointMethod.GetAttribute<DeleteAttribute>().path,
              endpointMethod
            );
          end;
        end;
      end;
    end;
  finally
    rttiContext.Free();
  end;
end;

procedure THttpRouter.handleRequest(
  httpMethod: THttpMethod;
  uri: string;
  request: TJSONObject;
  response: TJSONObject
);
var
  route: TRoute;
  endpointPath: string;
  endpoint: TEndpoint;
begin
  route := routes.findRouteForURI(uri);

  endpointPath := getEndpointPath(uri, route.path);

  endpoint := route.endpoints.findEndpoint(
    httpMethod,
    endpointPath
  );

  invokeMethod(
    route.controllerClass,
    endpoint,
    request,
    response
  );
end;

procedure THttpRouter.invokeMethod(
  controllerClass: TClass;
  endpoint: TEndpoint;
  request: TJSONObject;
  response: TJSONObject
);
var
  controllerInstance: TObject;

  rttiContext: TRttiContext;
  rttiType: TRttiType;
  rttiMethod: TRttiMethod;

  rttiMethodName: string;

  rttiParameter: TRttiParameter;
  rttiParameterName: string;

  endpointMethodName: string;

  requestParameterClass: PTypeInfo;
  reqeustParameterClass_ToString: string;

  requestValue: TValue;
  user: TUser;
begin
  controllerInstance := controllerClass.Create();
  try
    rttiContext := TRttiContext.Create();
    try
      rttiType := rttiContext.GetType(controllerClass.ClassInfo) as TRttiInstanceType;

      for rttiMethod in rttiType.GetMethods() do begin
        endpointMethodName := endpoint.method.Name;
        if rttiMethod.Name = endpoint.method.Name then begin
          rttiMethodName := rttiMethod.Name;
        end;
      end;

      for rttiParameter in endpoint.method.GetParameters() do begin
        rttiParameterName := rttiParameter.Name;
        if rttiParameter.HasAttribute(RequestAttribute) then begin
          requestParameterClass := rttiParameter.ParamType.Handle;
          reqeustParameterClass_ToString := requestParameterClass.Name;
        end;
      end;

      user := TUser.Create();
      TValue.Make(@request, request.ClassType.ClassInfo, requestValue);

      endpoint.method.Invoke(
        controllerInstance,
        [
          TValue.From<TJSONObject>(request),
          TValue.From<TUser>(user)
        ]
      );
    finally
      rttiContext.Free;
    end;

  finally
    controllerInstance.Free;
  end;
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
