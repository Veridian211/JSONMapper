unit DBQueryMapper.Attributes;

interface

uses
  RTTI;

type
  DBFeldAttribute = Class(TCustomAttribute)
    Public 
      feldName: string;
      constructor Create(Const feldName: String);
  End;

  DBFeldPrefixAttribute = Class(TCustomAttribute)
    Public 
      prefix: string;
      constructor Create(Const prefix: String);
  End;

implementation

end.