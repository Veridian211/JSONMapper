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
    procedure TestFromVariantNull();
    [Test]
    procedure TestFromVariantValue();

    [Test]
    procedure TestEquality();
    [Test]
    procedure TestInequality();
    [Test]
    procedure TestNullEquality();
    [Test]
    procedure TestNullInequality();
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

procedure TNullableTest.TestFromVariantNull();
var
  variantInt: Variant;
  nullableInt: TNullInteger;
begin
  variantInt := Null;
  nullableInt := TNullInteger.fromVariant(variantInt);
  Assert.IsTrue(nullableInt.isNull);
end;

procedure TNullableTest.TestFromVariantValue();
var
  variantInt: Variant;
  nullableInt: TNullInteger;
begin
  variantInt := 123;
  nullableInt := TNullInteger.fromVariant(variantInt);
  Assert.IsTrue(nullableInt = 123);
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
end;

procedure TNullableTest.TestInequality();
var
  nullableInt_A: TNullInteger;
  nullableInt_B: TNullInteger;
begin
  nullableInt_A := 123;
  nullableInt_B := 456;
  Assert.IsTrue(nullableInt_A <> nullableInt_B);
  Assert.IsTrue(nullableInt_A <> 456);
end;

procedure TNullableTest.TestNullEquality();
var
  nullableInt_A: TNullInteger;
  nullableInt_B: TNullInteger;
begin
  nullableInt_A := TNullInteger.Null;
  nullableInt_B := TNullInteger.Null;
  Assert.IsTrue(nullableInt_A = nullableInt_B);
end;

procedure TNullableTest.TestNullInequality();
var
  nullableInt_A: TNullInteger;
  nullableInt_B: TNullInteger;
begin
  nullableInt_A := 123;
  nullableInt_B := TNullInteger.Null;
  Assert.IsTrue(nullableInt_A <> nullableInt_B);
end;

initialization
  TDUnitX.RegisterTestFixture(TNullableTest);

end.
