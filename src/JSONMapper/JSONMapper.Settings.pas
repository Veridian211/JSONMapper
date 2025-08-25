unit JSONMapper.Settings;

interface

uses
  JSONMapper.DateFormatter,
  JSONMapper.CustomMapping;

type
  TJSONMapperSettings = record
  public
    dateFormatter: TDateFormatterClass;
    customMapping: TCustomMappings;
  end;

implementation

end.
