unit User.Controller;

interface

uses
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
    procedure createUser([Request] request: TUserDto);
  end;

implementation

procedure TUserController.createUser(request: TUserDto);
begin

end;

initialization
  THttpRouter.register(TUserController);

end.
