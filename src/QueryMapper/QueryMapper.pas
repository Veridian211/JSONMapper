unit DBQueryMapper;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  RTTI,
  OracleData,
  Data.DB,
  DBQueryMapper.Attributes;

type
  TDBMapper = class
  protected
    class procedure setzeObjektFelder<T: class, constructor>(element: T; dataSet: TOracleDataset); static;
    class function istPublic(rttiField: TRttiField): boolean; static;
    class function istEinfacherDatentyp(rttiField: TRttiField): boolean; static;
    class function holeDBFeldName(rttiField: TRttiField): string; static;
    class function holeDBFeldPrefix(rttiField: TRttiField): string; static;
    class procedure setzeObjektFeld<T: class>(element: T; rttiField: TRttiField; dataset: TOracleDataset); static;
  public
    class function mappeFelderInObjektList<T: class, constructor>(dataset: TOracleDataset): TObjectList<T>;
  end;

  DBFeldAttribute = DBQueryMapper.Attributes.DBFeldAttribute;
  DBFeldPrefixAttribute = DBQueryMapper.Attributes.DBFeldPrefixAttribute;

implementation

{ DBFeldAttribute }

constructor DBFeldAttribute.Create(const feldName: string);
begin
  inherited Create;
  self.feldName := feldName;
end;

{ DBFeldPrefixAttribute }

constructor DBFeldPrefixAttribute.Create(const prefix: string);
begin
  inherited Create;
  self.prefix := prefix;
end;

{ TDBMapper }

class function TDBMapper.mappeFelderInObjektList<T>(dataset: TOracleDataset): TObjectList<T>;
var
  element: T;
begin
  Result := TObjectList<T>.Create(true);
  try
    try
      dataset.Open;
      dataset.First;
      while not dataset.Eof do begin
        element := T.Create();
        Result.Add(element);

        setzeObjektFelder<T>(element, dataset);

        dataset.Next;
      end;
    finally
      dataset.Close;
    end;
  except
    result.Free;
    raise;
  end;
end;

class procedure TDBMapper.setzeObjektFelder<T>(element: T; dataSet: TOracleDataset);
var
  rttiContext: TRttiContext;
  rttiInstanceType: TRttiInstanceType;
  rttiField: TRttiField;
begin
  rttiContext := TRttiContext.Create;
  try
    rttiInstanceType := rttiContext.GetType(T) as TRttiInstanceType;

    for rttiField in rttiInstanceType.GetFields() do begin
      if not istPublic(rttiField)
      or not istEinfacherDatentyp(rttiField) then begin
        continue;
      end;
      setzeObjektFeld<T>(element, rttiField, dataset);
    end;
  finally
    rttiContext.Free;
  end;
end;

class function TDBMapper.istPublic(rttiField: TRttiField): boolean;
begin
  exit(rttiField.Visibility in [mvPublic, mvPublished]);
end;

class function TDBMapper.istEinfacherDatentyp(rttiField: TRttiField): boolean;
begin
  case rttiField.FieldType.TypeKind of
    tkInteger,
    tkInt64,
    tkFloat,
    tkChar,
    tkWChar,
    tkString,
    tkLString,
    tkWString,
    tkUString,
    tkVariant: begin
      exit(true);
    end
    else begin
      exit(false);
    end;
  end;
end;

class procedure TDBMapper.setzeObjektFeld<T>(
  element: T;
  rttiField: TRttiField;
  dataset: TOracleDataset
);
var
  dbFeldName: string;
  dbFeld: TField;
  wert: variant;
  buffer: TValue;
  rttiFieldType: PTypeInfo;
  value: TValue;
begin
  dbFeldName := holeDBFeldName(rttiField);

  dbFeld := dataset.Fields.FindField(dbFeldName);
  if not Assigned(dbFeld) then begin
    // TODO: evtl. Exception "Query-Feld <FeldName> nicht gefunden."
    exit();
  end;
  wert := dbFeld.AsVariant;

  buffer := TValue.FromVariant(dbFeld.AsVariant);
  rttiFieldType := rttiField.FieldType.Handle;
  if not buffer.TryCast(rttiFieldType, value) then begin
    // TODO: evtl. Exception "Query-Feld <FeldName> ist nicht vom Typ <typ>."
    exit();
  end;

  rttiField.SetValue(TObject(element), buffer);
end;

class function TDBMapper.holeDBFeldName(rttiField: TRttiField): string;
var
  attribut: TCustomAttribute;
begin
  for attribut in rttiField.GetAttributes() do begin
    if attribut is DBFeldAttribute then begin
      exit(DBFeldAttribute(attribut).feldName);
    end;
  end;
  exit(rttiField.Name);
end;

class function TDBMapper.holeDBFeldPrefix(rttiField: TRttiField): string;
var
  attribut: TCustomAttribute;
begin
  for attribut in rttiField.GetAttributes() do begin
    if attribut is DBFeldPrefixAttribute then begin
      exit(DBFeldPrefixAttribute(attribut).prefix);
    end;
  end;
  exit(EmptyStr);
end;

end.

