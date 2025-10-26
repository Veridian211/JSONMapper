unit HttpServer.Router.Registration;

interface

uses
  System.Generics.Collections;

type
  TRegisteredControllers = TList<TClass>;

  TControllerRegistry = class
  private
    registeredControllers: TRegisteredControllers;
    function getCount(): integer;
    function getItem(index: integer): TClass;
  public
    constructor Create();
    procedure registerController(controllerClass: TClass);
    destructor Destroy(); override;

    property Count: integer read getCount;
    property Items[index: Integer]: TClass read getItem; default;
  end;

var
  // Singleton
  controllerRegistry: TControllerRegistry;

implementation

constructor TControllerRegistry.Create;
begin
  inherited;
  registeredControllers := TRegisteredControllers.Create();
end;

procedure TControllerRegistry.registerController(controllerClass: TClass);
begin
  registeredControllers.Add(controllerClass);
end;

destructor TControllerRegistry.Destroy;
begin
  registeredControllers.Free();
  inherited;
end;

function TControllerRegistry.getCount: integer;
begin
  exit(registeredControllers.Count);
end;

function TControllerRegistry.getItem(index: integer): TClass;
begin
  exit(registeredControllers[index]);
end;

initialization
  controllerRegistry := TControllerRegistry.Create();

finalization
  controllerRegistry.Free;

end.
