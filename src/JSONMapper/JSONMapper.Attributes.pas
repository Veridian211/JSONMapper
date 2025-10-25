unit JSONMapper.Attributes;

interface

type
  IgnoreAttribute = class(TCustomAttribute)
  end;

  JSONKeyAttribute = class(TCustomAttribute)
  private
    key: string;
  public
    constructor Create(key: string);
    function getKey(): string;
  end;

implementation

{ JSONKeyAttribute }

constructor JSONKeyAttribute.Create(key: string);
begin
  inherited Create();
  self.key := key;
end;

function JSONKeyAttribute.getKey(): string;
begin
  exit(key);
end;

end.
