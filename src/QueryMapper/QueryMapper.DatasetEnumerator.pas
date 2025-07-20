unit QueryMapper.DatasetEnumerator;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.Rtti,
  Data.DB,
  QueryMapper.RowMapper;

type
  TDatasetEnumerator<T: class, constructor> = class(TInterfacedObject, IEnumerator<T>)
  private
    dataset: TDataSet;
    datasetRowMapper: TDatasetRowMapper<T>;

    current: T;
    ownsCurrent: boolean;
  public
    constructor Create(
      const dataset: TDataSet;
      const datasetRowMapper: TDatasetRowMapper<T>
    );

    function GetCurrent(): TObject;
    function MoveNext(): Boolean;
    procedure Reset();

    function GetCurrentGeneric(): T;
    function IEnumerator<T>.GetCurrent = GetCurrentGeneric;

    destructor Destroy(); override;
  end;


  IEnumerableDataset<T: class> = interface(IEnumerable)
    function GetEnumerator(): IEnumerator<T>;

    function asList(): TList<T>;
    function asObjectList(): TObjectList<T>;
    procedure populateList(list: TList<T>);
  end;


  TEnumerableDataset<T: class, constructor> = class(TInterfacedObject, IEnumerableDataset<T>)
  private
    dataset: TDataSet;
    datasetRowMapper: TDatasetRowMapper<T>;
  public
    constructor Create(const dataset: TDataSet);
    function GetEnumerator(): IEnumerator;
    function GetEnumeratorGeneric(): IEnumerator<T>;

    function IEnumerableDataset<T>.GetEnumerator = GetEnumeratorGeneric;

    function asList(): TList<T>;
    function asObjectList(): TObjectList<T>;
    procedure populateList(list: TList<T>);

    destructor Destroy(); override;
  end;

implementation

{ TDatasetEnumerator<T> }

constructor TDatasetEnumerator<T>.Create(
  const dataset: TDataSet;
  const datasetRowMapper: TDatasetRowMapper<T>
);
begin
  inherited Create();
  self.dataset := dataset;
  self.datasetRowMapper := datasetRowMapper;

  current := nil;
  ownsCurrent := false;

  self.dataset.Open();
  self.dataset.First();
end;

function TDatasetEnumerator<T>.GetCurrent(): TObject;
begin
  Result := GetCurrentGeneric();
end;

function TDatasetEnumerator<T>.GetCurrentGeneric(): T;
begin
  Result := current;
end;

function TDatasetEnumerator<T>.MoveNext(): Boolean;
begin
  if dataset.Eof then begin
    exit(false);
  end;

  if ownsCurrent then begin
    FreeAndNil(current);
  end;

  ownsCurrent := true;
  current := datasetRowMapper.mapRow(dataset);

  dataset.Next();
  Result := true;
end;

procedure TDatasetEnumerator<T>.Reset();
begin
  if ownsCurrent then begin
    FreeAndNil(current);
  end;
  ownsCurrent := false;

  dataset.First();
end;

destructor TDatasetEnumerator<T>.Destroy();
begin
  if ownsCurrent then begin
    FreeAndNil(current);
  end;

  self.dataset.Close();
  inherited;
end;

{ TEnumerableDataset<T> }

constructor TEnumerableDataset<T>.Create(const dataset: TDataSet);
begin
  inherited Create();
  self.dataset := dataset;
  self.datasetRowMapper := TDatasetRowMapperFactory.createRowMapper<T>();
end;

function TEnumerableDataset<T>.GetEnumerator(): IEnumerator;
begin
  Result := GetEnumeratorGeneric();
end;

function TEnumerableDataset<T>.GetEnumeratorGeneric(): IEnumerator<T>;
begin
  Result := TDatasetEnumerator<T>.Create(dataset, datasetRowMapper);
end;

function TEnumerableDataset<T>.asList(): TList<T>;
var
  item: T;
begin
  Result := TList<T>.Create();
  try
    populateList(Result);
  except
    for item in Result do begin
      item.Free();
    end;
    Result.Free();
    raise;
  end;
end;

function TEnumerableDataset<T>.asObjectList(): TObjectList<T>;
var
  item: T;
begin
  Result := TObjectList<T>.Create();
  try
    populateList(Result);
  except
    Result.Free();
    raise;
  end;
end;

procedure TEnumerableDataset<T>.populateList(list: TList<T>);
begin
  try
    dataset.Open();
    dataset.First();
    while not dataset.Eof do begin
      list.Add(datasetRowMapper.mapRow(dataset));
      dataset.Next();
    end;
  finally
    dataset.Close();
  end;
end;

destructor TEnumerableDataset<T>.Destroy();
begin
  datasetRowMapper.Free();
  inherited;
end;

end.

