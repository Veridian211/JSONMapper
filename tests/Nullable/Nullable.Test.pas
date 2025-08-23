unit Nullable.Test;

interface

uses
  DUnitX.TestFramework,
  System.Variants,
  Nullable;

type
  [TestFixture]
  TNullableTest = class
  public
    [Test]
    procedure TestVariant();
    [Test]
    procedure TestEquality();
  end;

implementation

procedure TNullableTest.TestVariant();
var
  variantInt: Variant;
  nullableInt: TNullInteger;
begin
  Assert.WillNotRaise(
    procedure
    begin
      variantInt := 123;
      nullableInt := TNullInteger.fromVariant(variantInt);
    end
  );

  Assert.WillRaise(
    procedure
    begin
      variantInt := 123.456;
      nullableInt := TNullInteger.fromVariant(variantInt);
    end,
    ENullable_VariantIsNotFromTypeT
  );
end;

procedure TNullableTest.TestEquality();
var
  nullableInt_A: TNullInteger;
  nullableInt_B: TNullInteger;
begin
  nullableInt_A := 123;
  nullableInt_B := 123;
  Assert.IsTrue(nullableInt_A = nullableInt_B);
  Assert.IsTrue(nullableInt_A = 123);

  nullableInt_A := 123;
  nullableInt_B := 456;
  Assert.IsTrue(nullableInt_A <> nullableInt_B);
  Assert.IsTrue(nullableInt_A <> 456);

  nullableInt_A := TNullInteger.Null;
  nullableInt_B := TNullInteger.Null;
  Assert.IsTrue(nullableInt_A = nullableInt_B);

  nullableInt_A := 123;
  nullableInt_B := TNullInteger.Null;
  Assert.IsTrue(nullableInt_A <> nullableInt_B);
end;

initialization
  TDUnitX.RegisterTestFixture(TNullableTest);

end.
