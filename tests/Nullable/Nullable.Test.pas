unit Nullable.Test;

interface

uses
  DUnitX.TestFramework,
  Nullable;

type
  [TestFixture]
  TNullableTest = class
  public
    [Test]
    procedure Test;
  end;

implementation

procedure TNullableTest.Test();
var
  nullableInt: TNullInteger;
begin
  // FIXME: should not compile
  nullableInt := 1.2;
end;

initialization
  TDUnitX.RegisterTestFixture(TNullableTest);

end.
