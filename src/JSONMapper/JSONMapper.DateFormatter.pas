unit JSONMapper.DateFormatter;

interface

uses
  System.DateUtils,
  System.SysUtils,
  JSONMapper.Exceptions;

type
  TDateFormatter = class;
  TDateFormatterClass = class of TDateFormatter;

  TDateFormatter = class abstract
  public
    class function tryStringToDateTime(dateTime: string): TDateTime;
    class function tryStringToDate(date: string): TDate;

    class function stringToDateTime(dateTime: string): TDateTime; virtual; abstract;
    class function stringToDate(date: string): TDate; virtual; abstract;
    class function dateTimeToString(dateTime: TDateTime): string; virtual; abstract;
    class function dateToString(date: TDate): string; virtual; abstract;
  end;


  /// <summary> ISO 8601 conform date conversion. </summary>
  TDateFormatter_ISO8601 = class(TDateFormatter)
  public
    class function stringToDateTime(dateTime: string): TDateTime; override;
    class function stringToDate(date: string): TDate; override;
    class function dateTimeToString(dateTime: TDateTime): string; override;
    class function dateToString(date: TDate): string; override;
  end;

  /// <summary> Uses current FormatSettings for date conversion. </summary>
  TDateFormatter_Local = class(TDateFormatter)
  public
    class function stringToDateTime(dateTime: string): TDateTime; override;
    class function stringToDate(date: string): TDate; override;
    class function dateTimeToString(dateTime: TDateTime): string; override;
    class function dateToString(date: TDate): string; override;
  end;

implementation

{ TDateFormatter }

class function TDateFormatter.tryStringToDateTime(dateTime: string): TDateTime;
begin
  try
    exit(stringToDateTime(dateTime));
  except
    raise EJSONMapperInvalidDateTime.Create(dateTime);
  end;
end;

class function TDateFormatter.tryStringToDate(date: string): TDate;
begin
  try
    exit(stringToDate(date));
  except
    raise EJSONMapperInvalidDate.Create(date);
  end;
end;

{ TDateFormatter_ISO8601 }

class function TDateFormatter_ISO8601.stringToDateTime(dateTime: string): TDateTime;
begin
  Result := ISO8601ToDate(dateTime);
end;

class function TDateFormatter_ISO8601.stringToDate(date: string): TDate;
begin
  Result := ISO8601ToDate(date);
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

class function TDateFormatter_Local.stringToDateTime(dateTime: string): TDateTime;
begin
  Result := StrToDateTime(dateTime);
end;

class function TDateFormatter_Local.stringToDate(date: string): TDate;
begin
  Result := StrToDate(date)
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
