unit HttpServer.ParamAttributes;

interface

type
  MethodParameterAttribute = class(TCustomAttribute);

  RequestAttribute = class(MethodParameterAttribute);

  ResponseAttribute = class(MethodParameterAttribute);

implementation

end.
