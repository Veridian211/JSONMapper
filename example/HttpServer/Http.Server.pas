unit Http.Server;

interface

uses
  IdHttpServer, IdCustomHTTPServer, IdContext, System.JSON, System.Classes, SysUtils,
  Logger,
  Http.HTTPMethods,
  Http.Exceptions,
  Http.Request,
  HttpServer.Router;

type
  THttpServer = class
  private
    httpServer: TidHttpServer;
    httpRouter: THttpRouter;

    logger: TLogger;
    procedure configureHttpServer(port: word);
    procedure onRequestReceived(
      context: TIdContext;
      request: TIdHTTPRequestInfo;
      response: TIdHTTPResponseInfo
    );
    function getRequestBody(request: TIdHTTPRequestInfo): string;
    procedure handleRequest(
      httpMethod: THttpMethod;
      uri: string;
      requestJSON: TJSONObject;
      responseJSON: TJSONObject
    );
    procedure answerRequest(
      response: TIdHTTPResponseInfo;
      responseJSON: TJSONObject
    );
    procedure handleRequestError(response: TIdHttpResponseInfo; e: Exception);
  public
    constructor Create(port: word; logger: TLogger);
    procedure start();
    procedure stop();
    destructor Destroy(); override;
  end;

implementation

constructor THttpServer.Create(port: word; logger: TLogger);
begin
  inherited Create();
  self.logger := logger;
  httpServer := TIdHTTPServer.Create();
  httpRouter := THttpRouter.Create(logger);

  configureHttpServer(port);
end;

procedure THttpServer.configureHttpServer(port: word);
begin
  httpServer.DefaultPort := port;
  httpServer.OnCommandGet := onRequestReceived;
end;

procedure THttpServer.start();
begin
  httpServer.Active := true;

  logger.log('Server started');
  logger.logFmt('Listening to port %d...', [httpServer.DefaultPort]);
end;

procedure THttpServer.stop();
begin
  httpServer.Active := false;

  logger.log();
  logger.log('Server stopped');
end;

procedure THttpServer.onRequestReceived(
  context: TIdContext;
  request: TIdHTTPRequestInfo;
  response: TIdHTTPResponseInfo
);
var
  httpMethod: THttpMethod;
  requestBody: string;

  requestJSON: TJSONObject;
  responseJSON: TJSONObject;
begin
  logger.log();
  logger.log('Request received.');

  try
    if not (request.ContentType = 'application/json') then begin
      raise EUnsupportedMediaTypeException.Create();
    end;

    try
      logger.logFmt('  %s %s', [request.Command, request.URI]);

      httpMethod := THttpMethod.fromIndyHttpCommand(request.CommandType);

      requestBody := getRequestBody(request);
      requestJSON := TJSONObject.ParseJSONValue(requestBody) as TJSONObject;
      responseJSON := TJSONObject.Create();

      if Assigned(requestJSON) then begin
        logger.log('Request Body: ' + requestJSON.ToJSON());
      end;

      handleRequest(
        httpMethod,
        request.URI,
        requestJSON,
        responseJSON
      );

      answerRequest(response, responseJSON);
    finally
      FreeAndNil(requestJSON);
      FreeAndNil(responseJSON);
    end;
  except
    on e: Exception do begin
      handleRequestError(response, e);
    end;
  end;
end;

function THttpServer.getRequestBody(request: TIdHTTPRequestInfo): string;
var
  stream: TStringStream;
begin
  stream := TStringStream.Create(EmptyStr, TEncoding.UTF8);
  try
    request.PostStream.Position := 0;
    stream.CopyFrom(request.PostStream, request.PostStream.Size);
    Result := stream.DataString;
  finally
    stream.Free();
  end;
end;

procedure THttpServer.handleRequest(
  httpMethod: THttpMethod;
  uri: string;
  requestJSON: TJSONObject;
  responseJSON: TJSONObject
);
var
  httpRequest: THttpRequest;
begin
  try
    httpRequest := THttpRequest.Create(
      httpMethod,
      uri,
      requestJSON,
      responseJSON
    );
    httpRouter.handleRequest(httpRequest);
  finally
    httpRequest.Free;
  end;
end;

procedure THttpServer.answerRequest(response: TIdHTTPResponseInfo; responseJSON: TJSONObject);
begin
  response.ResponseNo := 200;
  response.ContentType := 'application/json';
  response.ContentText := responseJSON.ToJSON();
end;

procedure THttpServer.handleRequestError(response: TIdHttpResponseInfo; e: Exception);
var
  httpException: EHttpException;
begin
  logger.log(e);

  if not (e is EHttpException) then begin
    response.ContentType := 'plain/text';
    response.ResponseNo := 500;
    response.ContentText := 'Internal Server Error';
    exit();
  end;

  httpException := EHttpException(e);
  response.ContentType := 'plain/text';
  response.ResponseNo := httpException.code;
  response.ContentText := httpException.text;
end;

destructor THttpServer.Destroy();
begin
  stop();
  httpServer.Free();
  httpRouter.Free();
  inherited;
end;

end.
