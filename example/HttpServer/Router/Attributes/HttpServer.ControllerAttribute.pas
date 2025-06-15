unit HttpServer.ControllerAttribute;

interface

type
  ControllerAttribute = class(TCustomAttribute)
  public
    path: string;
    constructor Create(route: string);
  end;

implementation

constructor ControllerAttribute.Create(route: string);
begin
  self.path := route;
end;

end.
