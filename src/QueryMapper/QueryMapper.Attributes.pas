unit QueryMapper.Attributes;

interface

uses
  System.Rtti;

type
  FieldNameAttribute = Class(TCustomAttribute)
  public
    fieldName: string;
    constructor Create(Const fieldName: String);
  end;

  FieldNamePrefixAttribute = Class(TCustomAttribute)
  public
    prefix: string;
    constructor Create(Const prefix: String);
  end;

implementation

{ FieldNameAttribute }

constructor FieldNameAttribute.Create(const fieldName: string);
begin
  inherited Create;
  self.fieldName := fieldName;
end;

{ FieldNamePrefixAttribute }

constructor FieldNamePrefixAttribute.Create(const prefix: string);
begin
  inherited Create;
  self.prefix := prefix;
end;

end.