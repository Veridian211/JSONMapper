unit Logger.Contract;

interface

uses
  System.SysUtils;

type
  ILogger = interface
    procedure clear();
    procedure log(msg: string = ''); overload;
    procedure log(e: Exception); overload;
    procedure logFmt(msg: string; const Args: array of const);
  end;

implementation

end.
