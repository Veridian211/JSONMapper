unit TestObjects;

interface

uses
  JSONMapper.Attributes,
  System.Generics.Collections;

type
  TUser = class
  public
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

  TNestedUser = class
  public
    user: TUser;
    constructor Create();
    destructor Destroy(); override;
  end;

  TUserWithList = class
  public
    userList: TList<TUser>;
  end;

implementation

{ TNestedUser }

constructor TNestedUser.Create;
begin
  inherited;
  user := TUser.Create();
end;

destructor TNestedUser.Destroy;
begin
  user.Free;
  inherited;
end;

end.
