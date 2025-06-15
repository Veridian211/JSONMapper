unit HttpServer.Router.Endpoint;

interface

uses
  System.Rtti,
  System.JSON,
  System.Generics.Collections,
  Http.Exceptions,
  Http.HTTPMethods,
  HttpServer.Router.Utils;

type
  TEndpoint = class
  public
    httpMethod: THttpMethod;
    path: string;
    pathSegments: TURISegments;
    method: TRttiMethod;
    constructor Create(
      httpMethod: THttpMethod;
      path: string;
      method: TRttiMethod
    );
  end;

  TEndpoints = class(TList<TEndpoint>)
  public
    procedure add(
      httpMethod: THttpMethod;
      path: string;
      method: TRttiMethod
    ); reintroduce;
    function findEndpoint(httpMethod: THttpMethod; path: string): TEndpoint;
    destructor Destroy(); override;
  end;

implementation

{ TEndpoint }

constructor TEndpoint.Create(
  httpMethod: THttpMethod;
  path: string;
  method: TRttiMethod
);
begin
  inherited Create();
  self.httpMethod := httpMethod;
  self.path := path;
  self.pathSegments := getURISegments(path);
  self.method := method;
end;

{ TEndpoints }

procedure TEndpoints.add(
  httpMethod: THttpMethod;
  path: string;
  method: TRttiMethod
);
begin
  inherited Add(TEndpoint.Create(httpMethod, path, method));
end;

destructor TEndpoints.Destroy;
var
  endpoint: TEndpoint;
begin
  for endpoint in self do begin
    endpoint.Free;
  end;
  inherited;
end;

function TEndpoints.findEndpoint(httpMethod: THttpMethod; path: string): TEndpoint;
var
  endpoint: TEndpoint;
  endpointPath: string;
begin
  path := trimSlashes(path);

  for endpoint in self do begin
    endpointPath := trimSlashes(endpoint.Path);

    if (endpoint.httpMethod = httpMethod)
    and (endpointPath = path) then begin
      exit(endpoint);
    end;
  end;

  raise ENotFoundException.Create();
end;

end.
