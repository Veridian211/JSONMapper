unit Nullable;

interface

uses
  System.SysUtils,
  System.Variants,
  System.TypInfo,
  System.Generics.Defaults,
  System.Rtti;

type
  TNullable<T> = record
  private
    fValue: T;
    fIsNull: Boolean;
    function getValue(): T;
  public
    constructor Create(const value: T);
    class function Null(): TNullable<T>; static;
    class function fromVariant(const value: Variant): TNullable<T>; static;

    function getValueOrDefault(): T; overload;
    function getValueOrDefault(const default: T): T; overload;
    function isNull(): Boolean;
    function toVariant(): Variant;
    function toString(): string;

    property value: T read getValue;

    // :=
    class operator Implicit(value: T): TNullable<T>; overload;
    class operator Implicit(value: TNullable<T>): T; overload;

    // =
    function equals(const value: TNullable<T>): Boolean; overload;
    function equals(const value: T): Boolean; overload;
    class operator Equal(left: TNullable<T>; right: TNullable<T>): boolean; overload;
    class operator Equal(left: TNullable<T>; right: T): boolean; overload;
    class operator Equal(left: T; right: TNullable<T>): boolean; overload;

    // <>
    class operator NotEqual(left: TNullable<T>; right: TNullable<T>): boolean; overload;
    class operator NotEqual(left: TNullable<T>; right: T): Boolean; overload;
    class operator NotEqual(left: T; right: TNullable<T>): Boolean; overload;
  end;

  TNullString = TNullable<string>;
  TNullInteger = TNullable<Integer>;
  TNullDouble = TNullable<Double>;
  TNullBoolean = TNullable<Boolean>;
  TNullDateTime = TNullable<TDateTime>;


  ENullableException = class(Exception);

  ENullable_ValueIsNull = class(ENullableException)
  public
    constructor Create(); reintroduce;
  end;

  ENullable_VariantIsNotFromTypeT = class(ENullableException)
  public
    constructor Create(typInfo: PTypeInfo); reintroduce;
  end;

implementation

{ TNullable }

constructor TNullable<T>.Create(const value: T);
begin
  fValue := value;
  fIsNull := False;
end;

class function TNullable<T>.Null(): TNullable<T>;
begin
  Result.fIsNull := true;
end;

class function TNullable<T>.fromVariant(const value: Variant): TNullable<T>;
var
  valueAsTValue: TValue;
  valueAsT: T;
begin
  if value = System.Variants.Null then begin
    Result.fIsNull := true;
    exit();
  end;

  valueAsTValue := TValue.FromVariant(value);
  if not valueAsTValue.TryAsType<T>(valueAsT) then begin
    raise ENullable_VariantIsNotFromTypeT.Create(TypeInfo(T));
  end;

  Result := TNullable<T>.Create(valueAsT);
end;

function TNullable<T>.getValue(): T;
begin
  if fIsNull then begin
    raise ENullable_ValueIsNull.Create();
  end;
  Result := fValue;
end;

function TNullable<T>.getValueOrDefault(): T;
begin
  Result := getValueOrDefault(Default(T));
end;

function TNullable<T>.getValueOrDefault(const default: T): T;
begin
  if fIsNull then begin
    exit(default);
  end;
  Result := fValue;
end;

function TNullable<T>.isNull(): Boolean;
begin
  Result := fIsNull;
end;

function TNullable<T>.toVariant(): Variant;
begin
  if fIsNull then begin
    exit(System.Variants.Null);
  end;
  exit(TValue.From<T>(fValue).AsVariant);
end;

function TNullable<T>.toString(): string;
begin
  if fIsNull then begin
    exit(EmptyStr);
  end;
  exit(TValue.From<T>(fValue).ToString);
end;

class operator TNullable<T>.Implicit(value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(value);
end;

class operator TNullable<T>.Implicit(value: TNullable<T>): T;
begin
  Result := value.getValue();
end;

function TNullable<T>.equals(const value: TNullable<T>): Boolean;
begin
  if (not isNull) and (not value.isNull) then begin
    exit(TEqualityComparer<T>.Default.Equals(self.Value, value.Value));
  end;
  Result := (isNull) = (value.isNull);
end;

function TNullable<T>.equals(const value: T): Boolean;
begin
  if fIsNull then begin
    exit(false);
  end;
  exit(TEqualityComparer<T>.Default.Equals(self.value, value));
end;

class operator TNullable<T>.Equal(left: TNullable<T>; right: TNullable<T>): boolean;
begin
  Result := left.equals(right);
end;

class operator TNullable<T>.Equal(left: TNullable<T>; right: T): Boolean;
begin
  Result := left.equals(right);
end;

class operator TNullable<T>.Equal(left: T; right: TNullable<T>): Boolean;
begin
  Result := right.equals(left);
end;

class operator TNullable<T>.NotEqual(left, right: TNullable<T>): boolean;
begin
  Result := not left.equals(right);
end;

class operator TNullable<T>.NotEqual(left: TNullable<T>; right: T): Boolean;
begin
  Result := not left.equals(right);
end;

class operator TNullable<T>.NotEqual(left: T; right: TNullable<T>): Boolean;
begin
  Result := not right.equals(left);
end;

{ ENullable_ValueIsNull }

constructor ENullable_ValueIsNull.Create();
begin
  inherited Create('TNullable is null.');
end;

{ ENullable_VariantIsNotFromTypeT }

constructor ENullable_VariantIsNotFromTypeT.Create(typInfo: PTypeInfo);
begin
  inherited CreateFmt('Variant is not from type "%s"', [typInfo.Name]);
end;

end.
