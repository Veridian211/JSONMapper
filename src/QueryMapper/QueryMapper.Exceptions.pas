unit QueryMapper.Exceptions;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  Data.DB;

type
  EQueryMapper = class(Exception)
  end;

  EQueryMapperNotExactlyOneRecord = class(EQueryMapper)
  public
    constructor Create(dataset: TDataSet); reintroduce;
  end;

  EQueryMapperNoEmptyConstructorFound = class(EQueryMapper)
  public
    constructor Create(classType: TClass); reintroduce;
  end;

  EQueryMapperCastingFromField = class(EQueryMapper)
  public
    constructor Create(field: TField; rttiType: TRttiType); reintroduce;
  end;

implementation

{ EQueryMapper_NotExactlyOneRecord }

constructor EQueryMapperNotExactlyOneRecord.Create(dataset: TDataSet);
begin
  inherited CreateFmt(
    'QueryMapper: Query "%s" did not return exactly one record.',
    [dataset.Name]
  );
end;

{ EQueryMapper_NoEmptyConstructorFound }

constructor EQueryMapperNoEmptyConstructorFound.Create(classType: TClass);
begin
  inherited CreateFmt(
    'QueryMapper: "%s" has no empty constructor.',
    [classType.QualifiedClassName]
  );
end;

{ EQueryMapperCastingFromField }

constructor EQueryMapperCastingFromField.Create(field: TField; rttiType: TRttiType);
begin
  inherited CreateFmt(
    'QueryMapper: Failed to map field "%s" into type "%s".',
    [field.Name, rttiType.Name]
  );
end;

end.
