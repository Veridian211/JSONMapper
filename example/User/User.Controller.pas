unit User.Controller;

interface

uses
  System.JSON,
  HttpServer.ControllerAttribute,
  HttpServer.MethodAttributes,
  HttpServer.ParamAttributes,
  HttpServer.Router,
  User.UserDataClass,
  User.UserDto;

type
  [Controller('user')]
  TUserController = class
  public
    [Post('create-user')]
    procedure createUser(
      [Request] request: TJSONObject;
      [Response] user: TUserDto
    );
  end;

implementation

procedure TUserController.createUser(
  [Request] request: TJSONObject;
  [Response] user: TUserDto
);
begin
  user.id := 1;
  user.name := 'John Doe';
end;

initialization
  THttpRouter.register(TUserController);

end.
