unit Http.HTTPMethods;

interface

uses
  Http.Exceptions,
  IdCustomHTTPServer;

type
  THttpMethod = (
    rmGet,
    rmPost,
    rmPut,
    rmDelete
  );

  THttpMethodHelper = record helper for THttpMethod
  public
    class function fromIndyHttpCommand(httpCommand: THTTPCommandType): THttpMethod; static;
  end;

implementation

{ THttpMethodHelper }

class function THttpMethodHelper.fromIndyHttpCommand(
  httpCommand: THTTPCommandType
): THttpMethod;
begin
  case httpCommand of
    hcGET:
      exit(rmGet);
    hcPOST:
      exit(rmPost);
    hcDELETE:
      exit(rmDelete);
    hcPUT:
      exit(rmPut);
    else
      raise EMethodNotAllowedException.Create();
  end;
end;

end.
