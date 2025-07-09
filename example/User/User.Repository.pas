unit User.Repository;

interface

uses
  System.Generics.Collections,
  User.UserDataClass;

type
  TUserRepository = class
  private
    liste: TList<TUser>;
  public
    constructor Create();
    procedure add(user: TUser);
    function get(id: integer): TUser;
    destructor Destroy(); override;
  end;

var
  userRepository: TUserRepository;

implementation

constructor TUserRepository.Create();
begin
  inherited Create();
  liste := TList<TUser>.Create();
end;

procedure TUserRepository.add(user: TUser);
begin
  liste.Add(user);
end;

function TUserRepository.get(id: integer): TUser;
var
  user: TUser;
begin
  for user in liste do begin
    if (user.id = id) then begin
      exit(user);
    end;
  end;
  exit(nil);
end;

destructor TUserRepository.Destroy();
var
  user: TUser;
begin
  for user in liste do begin
    user.Free;
  end;
  liste.Free;
  inherited;
end;

initialization
  userRepository := TUserRepository.Create();

finalization
  userRepository.Free;

end.
