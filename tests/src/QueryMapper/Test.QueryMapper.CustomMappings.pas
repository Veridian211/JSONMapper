unit Test.QueryMapper.CustomMappings;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  QueryMapper,
  CustomMapper;

type
  TColor = (
    clRed,
    clGreen,
    clBlue,
    clNotMapped
  );

  TColorHelper = record helper for TColor
  private
  const
    COLOR_RED = 'red';
    COLOR_GREEN = 'green';
    COLOR_BLUE = 'blue';
  public
    class function fromString(value: string): TColor; static;
    function toString(): string;
  end;

  TColorMapper = class(TCustomMapper<TColor>)
  public
    class function fromField(field: TField): TColor; override;
  end;

  TColorWrapper = class
  public
    color: TColor;
  end;

  [TestFixture]
  TCustomTypesTest = class
  private
    dataset: TClientDataSet;
  public
    [Setup]
    procedure Setup();
    [TearDown]
    procedure TearDown();
    [Test]
    procedure Test();
    [Test]
    procedure TestException();
  end;

implementation

procedure TCustomTypesTest.Setup();
begin
  dataset := TClientDataSet.Create(nil);
  dataset.FieldDefs.Add('Color', ftString, 50);
  dataset.CreateDataSet;
end;

procedure TCustomTypesTest.TearDown();
begin
  dataset.Free();
end;

procedure TCustomTypesTest.Test();
var
  colorWrapper: TColorWrapper;
begin
  dataset.Append;
  dataset.FieldByName('Color').AsString := 'red';
  dataset.Post;

  colorWrapper := dataset.GetOne<TColorWrapper>();
  try
    Assert.AreEqual(clRed, colorWrapper.color);
  finally
    colorWrapper.Free;
  end;
end;

procedure TCustomTypesTest.TestException;
var
  colorWrapper: TColorWrapper;
begin
  dataset.Append;
  dataset.FieldByName('Color').AsString := 'not a color';
  dataset.Post;

  colorWrapper := nil;
  try
    try
      colorWrapper := dataset.GetOne<TColorWrapper>();
    except
      on e: Exception do begin
        Assert.AreEqual(EQueryMapperUnknownType, e.ClassType);
      end;
    end;
  finally
    if Assigned(colorWrapper) then begin
      colorWrapper.Free;
    end;
  end;
end;

{ TColorHelper }

class function TColorHelper.fromString(value: string): TColor;
begin
  if value = COLOR_RED then exit(clRed)
  else if value = COLOR_GREEN then exit(clGreen)
  else if value = COLOR_BLUE then exit(clBlue);
  raise Exception.CreateFmt('String cannot be casted to TColor: %s', [value]);
end;

function TColorHelper.toString(): string;
begin
  case self of
    clRed: exit(COLOR_RED);
    clGreen: exit(COLOR_GREEN);
    clBlue: exit(COLOR_BLUE);
  end;
  raise Exception.CreateFmt('TColor cannot be casted to string: %d', [Ord(self)]);
end;

{ TColorMapper }

class function TColorMapper.fromField(field: TField): TColor;
begin
  Result := TColor.fromString(field.AsString);
end;

initialization
  TDUnitX.RegisterTestFixture(TCustomTypesTest);
  TCustomMapperRegistry.register<TColor>(TColorMapper);

end.
