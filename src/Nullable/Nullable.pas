unit Nullable;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Generics.Defaults,
  System.Rtti;

type
  TNullable<T> = record
  private
    _value: T;
    _isNull: Boolean;
  public
    constructor Create(const value: T); overload;
    constructor Create(const value: Variant); overload;

    function getValue(): T;
    function getValueOrDefault(): T; overload;
    function getValueOrDefault(const default: T): T; overload;
    function isNull(): Boolean;
    function asVariant(): Variant;

    class operator Implicit(value: T): TNullable<T>; overload;
    class operator Implicit(value: Variant): TNullable<T>; overload;
    class operator Implicit(value: TNullable<T>): T; overload;
    class operator Explicit(nullable: TNullable<T>): T;

    // =
    function equals(const value: TNullable<T>): Boolean; overload;
    function equals(const value: T): Boolean; overload;
    class operator Equal(left: TNullable<T>; right: TNullable<T>): boolean; overload;
    class operator Equal(left: TNullable<T>; right: T): boolean; overload;
    class operator Equal(left: T; right: TNullable<T>): boolean; overload;
    class operator Equal(left: TNullable<T>; right: Variant): boolean; overload;
    class operator Equal(left: Variant; right: TNullable<T>): boolean; overload;

    // <>
    class operator NotEqual(left: TNullable<T>; right: TNullable<T>): boolean; overload;
    class operator NotEqual(left: TNullable<T>; right: T): Boolean; overload;
    class operator NotEqual(left: T; right: TNullable<T>): Boolean; overload;
    class operator NotEqual(left: TNullable<T>; right: Variant): Boolean; overload;
    class operator NotEqual(left: Variant; right: TNullable<T>): Boolean; overload;

    property value: T read getValue;
  end;

  TNullString = TNullable<string>;
  TNullInteger = TNullable<Integer>;
  TNullDouble = TNullable<Double>;
  TNullBoolean = TNullable<Boolean>;
  TNullDateTime = TNullable<TDateTime>;

  ENullableIsNull = class(Exception)
  public
    constructor Create(); reintroduce;
  end;

implementation

{ TNullable }

constructor TNullable<T>.Create(const value: T);
begin
  _value := value;
  _isNull := False;
end;

constructor TNullable<T>.Create(const value: Variant);
begin
  _isNull := True;
end;

function TNullable<T>.getValue(): T;
begin
  if _isNull then begin
    raise ENullableIsNull.Create();
  end;
  Result := _value;
end;

function TNullable<T>.getValueOrDefault(): T;
begin
  Result := getValueOrDefault(Default(T));
end;

function TNullable<T>.getValueOrDefault(const default: T): T;
begin
  if _isNull then begin
    exit(default);
  end;
  Result := _value;
end;

function TNullable<T>.isNull(): Boolean;
begin
  Result := _isNull;
end;

function TNullable<T>.asVariant(): Variant;
begin
  if _isNull then begin
    exit(null);
  end;
  exit(TValue.From<T>(_value).AsVariant);
end;

class operator TNullable<T>.Implicit(value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(value);
end;

class operator TNullable<T>.Implicit(value: Variant): TNullable<T>;
begin
  Result := TNullable<T>.Create(value);
end;

class operator TNullable<T>.Implicit(value: TNullable<T>): T;
begin
  Result := value.getValue();
end;

class operator TNullable<T>.Explicit(nullable: TNullable<T>): T;
begin
  Result := nullable.getValue();
end;

function TNullable<T>.equals(const value: TNullable<T>): Boolean;
begin
  if (not isNull) and (not Value.isNull) then begin
    exit(TEqualityComparer<T>.Default.Equals(Self.Value, Value.Value));
  end;
  Result := (not isNull) = (not Value.isNull);
end;

function TNullable<T>.equals(const value: T): Boolean;
begin
  if _isNull then begin
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

class operator TNullable<T>.Equal(left: TNullable<T>; right: Variant): Boolean;
var
  val: TValue;
begin
  if left.isNull then begin
    if (right = Null)then begin
      exit(true);
    end;
    exit(false);
  end;

  val := TValue.From<T>(left.getValue());
  exit(val.AsVariant = right);
end;

class operator TNullable<T>.Equal(left: Variant; right: TNullable<T>): Boolean;
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

class operator TNullable<T>.NotEqual(left: TNullable<T>; right: Variant): Boolean;
begin
  Result := not left.equals(right);
end;

class operator TNullable<T>.NotEqual(left: Variant; right: TNullable<T>): Boolean;
begin
  Result := not right.equals(left);
end;

{ ENullableIsNull }

constructor ENullableIsNull.Create();
begin
  inherited Create('TNullable: Value is null');
end;

end.
