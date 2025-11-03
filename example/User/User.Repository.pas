unit User.Repository;

interface

uses
  System.Generics.Collections,
  User.Model;

type
  TUserRepository = class
  private
    list: TObjectList<TUser>;
  public
    constructor Create();
    procedure add(user: TUser);
    function get(id: integer): TUser;
    function getAll(): TObjectList<TUser>;
    destructor Destroy(); override;
  end;

var
  userRepository: TUserRepository;

implementation

constructor TUserRepository.Create();
begin
  inherited Create();
  list := TObjectList<TUser>.Create();
end;

procedure TUserRepository.add(user: TUser);
var
  newUser: TUser;
begin
  newUser := TUser.Create();
  try
    newUser.id := user.id;
    newUser.name := user.name;
    newUser.password := user.password;
    list.Add(newUser);
  except
    newUser.Free;
    raise;
  end;
end;

function TUserRepository.get(id: integer): TUser;
var
  userWithId: TUser;
  user: TUser;
begin
  userWithId := nil;
  for user in list do begin
    if (user.id = id) then begin
      userWithId := user;
    end;
  end;

  if userWithId = nil then begin
    exit(nil);
  end;

  Result := TUser.Create();
  try
    Result.id := userWithId.id;
    Result.name := userWithId.name;
    Result.password := userWithId.password;
    exit();
  except
    Result.Free;
    raise;
  end;
end;

function TUserRepository.getAll: TObjectList<TUser>;
var
  user: TUser;
  resultUser: TUser;
begin
  Result := TObjectList<TUser>.Create;
  try
    for user in list do begin
      resultUser := TUser.Create();
      Result.Add(resultUser);

      resultUser.id := user.id;
      resultUser.name := user.name;
      resultUser.password := user.password;
    end;
  except
    Result.Free;
    raise;
  end;
end;

destructor TUserRepository.Destroy();
begin
  list.Free;
  inherited;
end;

initialization
  userRepository := TUserRepository.Create();

finalization
  userRepository.Free;

end.
