unit QueryMapper.Exceptions;

interface

uses
  System.SysUtils,
  Data.DB;

type
  EQueryMapper = class(Exception)
  public
  end;

  EQueryMapper_EmptyDataset = class(EQueryMapper)
  public
    constructor Create(dataset: TDataSet); reintroduce;
  end;

  EQueryMapper_NoEmptyConstructorFound = class(Exception)
  public
    constructor Create(metaClassType: TClass); reintroduce;
  end;

implementation

{ EQueryMapper_EmptyDataset }

constructor EQueryMapper_EmptyDataset.Create(dataset: TDataSet);
begin
  inherited CreateFmt('Query did not return one record (%s).', [dataset.Name]);
end;

{ EQueryMapper_NoEmptyConstructorFound }

constructor EQueryMapper_NoEmptyConstructorFound.Create(metaClassType: TClass);
begin
  inherited CreateFmt('"%s" has no empty constructor.', [metaClassType.QualifiedClassName]);
end;

end.
