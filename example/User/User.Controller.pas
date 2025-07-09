unit User.Controller;

interface

uses
  System.JSON,
  HttpServer.ControllerAttribute,
  HttpServer.MethodAttributes,
  HttpServer.ParamAttributes,
  HttpServer.Router,
  User.Service,
  User.Dtos;

type
  [Controller('user')]
  TUserController = class
  private
    userService: TUserService;
  public
    constructor Create();

    [Post('create-user')]
    procedure createUser([Response] user: TUserDto);

    [Post('get-user')]
    procedure getUser([Request] idDto: TIdDto; [Response] user: TUserDto);
  end;

implementation

constructor TUserController.Create();
begin
  inherited Create();
  userService := TUserService.Create();
end;

procedure TUserController.createUser([Response] user: TUserDto);
begin
  userService.createUser(user);
end;

procedure TUserController.getUser([Response]idDto: TIdDto; [Response]user: TUserDto);
begin
  userService.getUser(idDto.id, user);
end;

initialization
  THttpRouter.register(TUserController);

end.
