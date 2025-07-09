unit User.Service;

interface

uses
  System.Hash,
  User.Dtos,
  User.UserDataClass,
  User.Repository;

type
  TUserService = class
  private
    userRepository: TUserRepository;
  public
    constructor Create();
    procedure createUser(userDto: TUserDto);
    procedure getUser(id: integer; var user: TUserDto);
  end;

implementation

constructor TUserService.Create();
begin
  inherited;
  self.userRepository := User.Repository.userRepository;
end;

procedure TUserService.createUser(userDto: TUserDto);
var
  user: TUser;
begin
  user := TUser.Create();
  try
    user.id := userDto.id;
    user.name := userDto.name;
    user.password := THash.GetRandomString(20);

    userRepository.add(user);
  except
    user.Free;
  end;
end;

procedure TUserService.getUser(id: integer; var user: TUserDto);
begin
  user := TUserDto(userRepository.get(id));
end;

end.
