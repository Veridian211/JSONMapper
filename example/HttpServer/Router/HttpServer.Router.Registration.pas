unit HttpServer.Router.Registration;

interface

uses
  System.Generics.Collections;

type
  TRegisteredHttpResources = TList<TClass>;

  THttpRouterRegistration = class
  private
    registeredHttpResources: TRegisteredHttpResources;
    function getCount(): integer;
    function getItem(index: integer): TClass;
  public
    constructor Create();
    procedure registerResource(cls: TClass);
    destructor Destroy(); override;

    property Count: integer read getCount;
    property Items[index: Integer]: TClass read getItem; default;
  end;

var
  // Singleton
  httpRouterRegistry: THttpRouterRegistration;

implementation

constructor THttpRouterRegistration.Create;
begin
  inherited;
  registeredHttpResources := TRegisteredHttpResources.Create();
end;

procedure THttpRouterRegistration.registerResource(cls: TClass);
begin
  registeredHttpResources.Add(cls);
end;

destructor THttpRouterRegistration.Destroy;
begin
  registeredHttpResources.Free();
  inherited;
end;

function THttpRouterRegistration.getCount: integer;
begin
  exit(registeredHttpResources.Count);
end;

function THttpRouterRegistration.getItem(index: integer): TClass;
begin
  exit(registeredHttpResources[index]);
end;

initialization
  httpRouterRegistry := THttpRouterRegistration.Create();

finalization
  httpRouterRegistry.Free;

end.
