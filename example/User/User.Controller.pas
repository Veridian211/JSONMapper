unit User.Controller;

interface

uses
  System.Generics.Collections,
  System.JSON,
  HttpServer.Router,
  User.Service,
  User.Model,
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
    procedure getUser([Request] idDto: TIdDto; [Response] user: TUser);

    [Get('all-users')]
    procedure getAllUsers([Response] users: TObjectList<TUser>);
  end;

implementation

constructor TUserController.Create();
begin
  inherited Create();
  userService := TUserService.Create();
end;

procedure TUserController.createUser(user: TUserDto);
begin
  userService.createUser(user.id, user.name);
end;

procedure TUserController.getUser(idDto: TIdDto; user: TUser);
begin
  user := userService.getUser(idDto.id);
end;

procedure TUserController.getAllUsers(users: TObjectList<TUser>);
begin
  users := userService.getAllUsers();
end;

initialization
  THttpRouter.register(TUserController);

end.
