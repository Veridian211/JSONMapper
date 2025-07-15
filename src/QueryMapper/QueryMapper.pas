unit QueryMapper;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  System.Rtti,
  Data.DB,
  QueryMapper.DatasetEnumerator,
  QueryMapper.Attributes;

type
  TDatasetHelper = class helper for TDataset
  public
    function Rows<T: class, constructor>(): IEnumerable<T>;
    function GetFirst<T: class, constructor>(): T;
    function GetOne<T: class, constructor>(): T;
  end;

  FieldName = QueryMapper.Attributes.FieldNameAttribute;
  FieldNamePrefix = QueryMapper.Attributes.FieldNamePrefixAttribute;

implementation

{ TDatasetHelper }

function TDatasetHelper.Rows<T>(): IEnumerable<T>;
begin
  Result := TEnumerableDataset<T>.Create(self);
end;

function TDatasetHelper.GetFirst<T>(): T;
var
  item: T;
begin
  try
    self.Open();
    self.First();

    item := T.Create();
    try
      // TODO: map fields into item
      exit(item);
    except
      item.Free;
      raise;
    end;
  finally
    self.Close();
  end;
end;

function TDatasetHelper.GetOne<T>(): T;
begin
  if not (self.RecordCount = 1) then begin
    raise Exception.Create('Abfrage ergibt mehr als einen Eintrag.');
  end;

  exit(GetFirst<T>());
end;

end.

