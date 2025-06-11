unit TestObjects;

interface

uses
  JSONMapper.Attributes;

type
  TUser = class
  public
    id: integer;
    name: string;
    isAdmin: boolean;
  end;

  TUserWithIgnoreAttribute = class
  public
    [IgnoreField]
    id: integer;

    name: string;
    isAdmin: boolean;
  end;

implementation

end.
