unit Test.CustomMapper.UUIDType;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestUUIDMapping = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test1;
  end;

implementation

procedure TTestUUIDMapping.Setup;
begin
end;

procedure TTestUUIDMapping.TearDown;
begin
end;

procedure TTestUUIDMapping.Test1;
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUUIDMapping);

end.
