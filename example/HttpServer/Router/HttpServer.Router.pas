unit HttpServer.Router;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.TypInfo,
  System.JSON,
  Logger,
  JSONMapper,
  Http.HTTPMethods,
  Http.Exceptions,
  Http.Request,
  HttpServer.Router.Utils,
  HttpServer.Router.Registration,
  HttpServer.Router.Routes,
  HttpServer.ControllerAttribute,
  HttpServer.MethodAttributes,
  HttpServer.ParamAttributes;

type
  THttpRouter = class
  private
    logger: TLogger;
    routes: TRoutes;
    procedure discoverHttpResources();
    procedure invokeMethod(
      rttiContext: TRttiContext;
      controllerClass: TClass;
      endpointMethod: TRttiMethod;
      request: TJSONObject;
      response: TJSONObject
    );
    function getEndpointMethod(
      rttiContext: TRttiContext;
      route: TRoute;
      httpMethod: THttpMethod;
      endpointPath: string
    ): TRttiMethod;
  public
    constructor Create(logger: TLogger);
    class procedure register(httpResource: TClass);
    procedure handleRequest(httpRequest: THttpRequest);
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

procedure THttpRouter.handleRequest(httpRequest: THttpRequest);
var
  rttiContext: TRttiContext;
  route: TRoute;
  endpointPath: string;
  endpointMethod: TRttiMethod;
begin
  route := routes.findRouteForURI(httpRequest.uri);
  endpointPath := getEndpointPath(httpRequest.uri, route.path);

  rttiContext := TRttiContext.Create();
  try
    endpointMethod := getEndpointMethod(
      rttiContext,
      route,
      httpRequest.httpMethod,
      endpointPath
    );

    invokeMethod(
      rttiContext,
      route.controllerClass,
      endpointMethod,
      httpRequest.request,
      httpRequest.response
    );
  finally
    rttiContext.Free;
  end;
end;

function THttpRouter.getEndpointMethod(
  rttiContext: TRttiContext;
  route: TRoute;
  httpMethod: THttpMethod;
  endpointPath: string
): TRttiMethod;
var
  controller: TRttiType;
  rttiMethod: TRttiMethod;
  methodAttr: MethodAttribute;
begin
  controller := rttiContext.GetType(route.controllerClass.ClassInfo) as TRttiInstanceType;

  for rttiMethod in controller.GetMethods() do begin
    if not rttiMethod.HasAttribute(MethodAttribute) then begin
      continue;
    end;

    methodAttr := rttiMethod.GetAttribute<MethodAttribute>();
    if (methodAttr.method <> httpMethod)
    or (trimSlashes(methodAttr.path) <> trimSlashes(endpointPath)) then begin
      continue;
    end;

    exit(rttiMethod);
  end;

  raise ENotFoundException.Create();
end;

procedure THttpRouter.invokeMethod(
  rttiContext: TRttiContext;
  controllerClass: TClass;
  endpointMethod: TRttiMethod;
  request: TJSONObject;
  response: TJSONObject
);
var
  endpointMethodParameters: TArray<TRttiParameter>;
  parameterValues: TArray<TValue>;

  i: integer;
  rttiParameter: TRttiParameter;
  parameterClass: PTypeInfo;
  rttiInstanceType: TRttiInstanceType;

  controllerInstance: TObject;
  requestObject: TObject;
  responseObject: TObject;
begin
  try
    endpointMethodParameters := endpointMethod.GetParameters();
    SetLength(parameterValues, Length(endpointMethodParameters));
    for i := 0 to Length(endpointMethodParameters) - 1 do begin
      rttiParameter := endpointMethodParameters[i];

      if not rttiParameter.HasAttribute(MethodParameterAttribute) then begin
        raise Exception.Create('Kein Method Parameter gefunden!');
      end;

      parameterClass := rttiParameter.ParamType.Handle;

      if rttiParameter.HasAttribute(RequestAttribute) then begin
        if parameterClass = TypeInfo(TJSONObject) then begin
          parameterValues[i] := request;
        end else begin
          rttiInstanceType := rttiContext.GetType(parameterClass) as TRttiInstanceType;
          requestObject := rttiInstanceType.MetaclassType.Create();
          parameterValues[i] := requestObject;
//          TJSONMapper.jsonToObject(request, requestObject);
        end;
        continue;
      end;

      if rttiParameter.HasAttribute(ResponseAttribute) then begin
        if parameterClass = TypeInfo(TJSONObject) then begin
          parameterValues[i] := response;
        end else begin
          rttiInstanceType := rttiContext.GetType(parameterClass) as TRttiInstanceType;
          responseObject := rttiInstanceType.MetaclassType.Create();
          parameterValues[i] := responseObject;
        end;
        continue;
      end;
    end;

    controllerInstance := controllerClass.Create();
    try
      endpointMethod.Invoke(
        controllerInstance,
        parameterValues
      );
    finally
      controllerInstance.Free;
    end;

    TJSONMapper.objectToJSON(responseObject, response);

  finally
    FreeAndNil(requestObject);
    FreeAndNil(responseObject);
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
