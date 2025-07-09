unit JSONMapper.DateFormatter;

interface

uses
  System.DateUtils,
  System.SysUtils;

type
  TDateFormatter = class;
  TDateFormatterClass = class of TDateFormatter;

  TDateFormatter = class abstract
  public
    class function toDateTime(dateTime: string): TDateTime; virtual; abstract;
    class function dateTimeToString(dateTime: TDateTime): string; virtual; abstract;
    class function dateToString(date: TDate): string; virtual; abstract;
  end;


  /// <summary> ISO 8601 conform date conversion </summary>
  TDateFormatter_ISO8601 = class(TDateFormatter)
  public
    class function toDateTime(dateTime: string): TDateTime; override;
    class function dateTimeToString(dateTime: TDateTime): string; override;
    class function dateToString(date: TDate): string; override;
  end;

  /// <summary> uses current FormatSettings for date conversion </summary>
  TDateFormatter_Local = class(TDateFormatter)
  public
    class function toDateTime(dateTime: string): TDateTime; override;
    class function dateTimeToString(dateTime: TDateTime): string; override;
    class function dateToString(date: TDate): string; override;
  end;

implementation

{ TDateFormatter_ISO8601 }

class function TDateFormatter_ISO8601.toDateTime(dateTime: string): TDateTime;
begin
  Result := ISO8601ToDate(dateTime);
end;

class function TDateFormatter_ISO8601.dateTimeToString(dateTime: TDateTime): string;
begin
  Result := DateToISO8601(dateTime);
end;

class function TDateFormatter_ISO8601.dateToString(date: TDate): string;
var
  formatSettings: TFormatSettings;
begin
  formatSettings := TFormatSettings.Create();
  formatSettings.DateSeparator := '-';
  formatSettings.ShortDateFormat := 'yyyy-MM-dd';

  Result := DateToStr(date, formatSettings);
end;

{ TDateFormatter_Local }

class function TDateFormatter_Local.toDateTime(dateTime: string): TDateTime;
begin
  Result := StrToDateTime(dateTime);
end;

class function TDateFormatter_Local.dateTimeToString(dateTime: TDateTime): string;
begin
  Result := DateTimeToStr(dateTime);
end;

class function TDateFormatter_Local.dateToString(date: TDate): string;
begin
  Result := DateToStr(date);
end;

end.
