unit HttpServer.MethodAttributes;

interface

uses
  Http.HTTPMethods;

type
  MethodAttribute = class(TCustomAttribute)
  public
    path: string;
    method: THttpMethod;
    constructor Create(path: string; method: THttpMethod);
  end;

  GetAttribute = class(MethodAttribute)
  public
    constructor Create(path: string); reintroduce;
  end;

  PostAttribute = class(MethodAttribute)
  public
    constructor Create(path: string); reintroduce;
  end;

  PutAttribute = class(MethodAttribute)
  public
    constructor Create(path: string); reintroduce;
  end;

  DeleteAttribute = class(MethodAttribute)
  public
    constructor Create(path: string); reintroduce;
  end;

implementation

{ MethodAttribute }

constructor MethodAttribute.Create(path: string; method: THttpMethod);
begin
  self.path := path;
  self.method := method;
end;

{ GetAttribute }

constructor GetAttribute.Create(path: string);
begin
  inherited Create(path, rmGet);
end;

{ PostAttribute }

constructor PostAttribute.Create(path: string);
begin
  inherited Create(path, rmPost);
end;

{ PutAttribute }

constructor PutAttribute.Create(path: string);
begin
  inherited Create(path, rmPut);
end;

{ DeleteAttribute }

constructor DeleteAttribute.Create(path: string);
begin
  inherited Create(path, rmDelete);
end;

end.
