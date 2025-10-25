unit JSONMapper.Settings;

interface

uses
  JSONMapper.DateTimeFormatter,
  JSONMapper.CustomMapping;

type
  TJSONMapperSettings = record
  public
    dateFormatter: TDateFormatterClass;
    customMapping: TCustomMappers;
  end;

implementation

end.
