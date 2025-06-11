program ObjectMapper;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  JSONMapper in 'src\JSONMapper\JSONMapper.pas',
  RttiUtils in 'src\JSONMapper\RttiUtils.pas',
  JSONMapper.Attributes in 'src\JSONMapper\JSONMapper.Attributes.pas',
  PublicFieldIterator in 'src\JSONMapper\PublicFieldIterator.pas';

begin
  try
    { TODO -oUser -cConsole Main : Code hier einfügen }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
