unit Logger;

interface

uses
  Vcl.StdCtrls, SysUtils;

type
  TLogger = class
  private
    memo: TMemo;
  public
    constructor Create(memo: TMemo); reintroduce;

    procedure clear();
    procedure log(msg: string = ''); overload;
    procedure log(e: Exception); overload;
    procedure logFmt(msg: string; const Args: array of const);
  end;

implementation

constructor TLogger.Create(memo: TMemo);
begin
  inherited Create();
  self.memo := memo;
end;

procedure TLogger.clear();
begin
  memo.Lines.Clear();
end;

procedure TLogger.log(msg: string);
begin
  memo.Lines.Add(msg);
end;

procedure TLogger.log(e: Exception);
begin
  memo.Lines.Add('Error: ' + e.Message);
end;

procedure TLogger.logFmt(msg: string; const Args: array of const);
begin
  memo.Lines.Add(Format(msg, Args));
end;

end.
