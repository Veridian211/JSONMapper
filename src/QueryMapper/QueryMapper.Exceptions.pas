unit QueryMapper.Exceptions;

interface

uses
  System.SysUtils,
  Data.DB;

type
  EQueryMapper = class(Exception)
  end;

  EQueryMapper_NotExactlyOneRecord = class(EQueryMapper)
  public
    constructor Create(dataset: TDataSet); reintroduce;
  end;

  EQueryMapper_NoEmptyConstructorFound = class(Exception)
  public
    constructor Create(classType: TClass); reintroduce;
  end;

implementation

{ EQueryMapper_NotExactlyOneRecord }

constructor EQueryMapper_NotExactlyOneRecord.Create(dataset: TDataSet);
begin
  inherited CreateFmt('QueryMapper: Query "%s" did not return exactly one record.', [dataset.Name]);
end;

{ EQueryMapper_NoEmptyConstructorFound }

constructor EQueryMapper_NoEmptyConstructorFound.Create(classType: TClass);
begin
  inherited CreateFmt('QueryMapper: "%s" has no empty constructor.', [classType.QualifiedClassName]);
end;

end.
