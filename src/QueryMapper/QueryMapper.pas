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
  QueryMapper.RowMapper,
  QueryMapper.Attributes,
  QueryMapper.Exceptions;

type
  TDatasetHelper = class helper for TDataset
  public
    function Rows<T: class, constructor>(): IEnumerableDataset<T>;
    function GetFirst<T: class, constructor>(): T;

    /// <summary> Raises Exception, if RecordCount is not 1. </summary>
    function GetOne<T: class, constructor>(): T;

    ///  <summary> Opens the dataset, counts its records, and closes it. </summary>
    function Count(): integer;
    function IsEmpty(): boolean;
  end;

  FieldName = QueryMapper.Attributes.FieldNameAttribute;
  FieldNamePrefix = QueryMapper.Attributes.FieldNamePrefixAttribute;

  EQueryMapper = QueryMapper.Exceptions.EQueryMapper;
  EQueryMapper_EmptyDataset = QueryMapper.Exceptions.EQueryMapper_EmptyDataset;
  EQueryMapper_NoEmptyConstructorFound = Querymapper.Exceptions.EQueryMapper_NoEmptyConstructorFound;

implementation

function TDatasetHelper.Rows<T>(): IEnumerableDataset<T>;
begin
  Result := TEnumerableDataset<T>.Create(self);
end;

function TDatasetHelper.GetFirst<T>(): T;
var
  rowMapper: TDatasetRowMapper<T>;
begin
  try
    self.Open();
    self.First();

    rowMapper := TDatasetRowMapperFactory.createRowMapper<T>();
    try
      Result := rowMapper.mapRow(self);
    finally
      rowMapper.Free();
    end;
  finally
    self.Close();
  end;
end;

function TDatasetHelper.GetOne<T>(): T;
var
  rowMapper: TDatasetRowMapper<T>;
begin
  try
    self.Open();
    self.First();

    if (self.RecordCount <> 1) then begin
      raise EQueryMapper_EmptyDataset.Create(self);
    end;

    rowMapper := TDatasetRowMapperFactory.createRowMapper<T>();
    try
      Result := rowMapper.mapRow(self);
    finally
      rowMapper.Free();
    end;
  finally
    self.Close();
  end;
end;

function TDatasetHelper.Count(): integer;
begin
  try
    self.Open();
    Result := self.RecordCount;
  finally
    self.Close();
  end;
end;

function TDatasetHelper.IsEmpty(): boolean;
begin
  Result := self.Count() = 0;
end;

end.

