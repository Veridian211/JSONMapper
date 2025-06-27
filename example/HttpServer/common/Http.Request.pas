unit Http.Request;

interface

uses
  System.JSON,
  Http.HTTPMethods;

type
  THttpRequest = class
    httpMethod: THttpMethod;
    uri: string;
    request: TJSONObject;
    response: TJSONObject;
    constructor Create(
      httpMethod: THttpMethod;
      uri: string;
      request: TJSONObject;
      response: TJSONObject
    );
  end;

implementation

{ THttpRequest }

constructor THttpRequest.Create(
  httpMethod: THttpMethod;
  uri: string;
  request: TJSONObject;
  response: TJSONObject
);
begin
  inherited Create();

  self.httpMethod := httpMethod;
  self.uri := uri;
  self.request := request;
  self.response := response;
end;

end.
