unit User.Service;

interface

uses
  System.Hash,
  System.Generics.Collections,
  User.Model,
  User.Repository;

type
  TUserService = class
  private
    userRepository: TUserRepository;
  public
    constructor Create();
    procedure createUser(id: integer; name: string);
    function getUser(id: integer): TUser;
    function getAllUsers(): TObjectList<TUser>;
  end;

implementation

constructor TUserService.Create();
begin
  inherited;
  self.userRepository := User.Repository.userRepository;
end;

procedure TUserService.createUser(id: integer; name: string);
var
  user: TUser;
begin
  user := TUser.Create();
  try
    user.id := id;
    user.name := name;
    user.password := THash.GetRandomString(20);

    userRepository.add(user);
  except
    user.Free;
    raise;
  end;
end;

function TUserService.getUser(id: integer): TUser;
begin
  Result := userRepository.get(id);
end;

function TUserService.getAllUsers(): TObjectList<TUser>;
begin
  Result := userRepository.getAll();
end;

end.
