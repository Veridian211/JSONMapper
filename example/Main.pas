unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, Vcl.StdCtrls, Http.Server, Logger;

type
  TForm1 = class(TForm)
    mLog: TMemo;
    bClearLog: TButton;
    bRestartServer: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bClearLogClick(Sender: TObject);
    procedure bRestartServerClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    httpServer: THttpServer;
    logger: TLogger;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  logger := TLogger.Create(mLog);
  httpServer := THttpServer.Create(3002, logger);
  httpServer.start();
end;

procedure TForm1.bClearLogClick(Sender: TObject);
begin
  logger.clear();
end;

procedure TForm1.bRestartServerClick(Sender: TObject);
begin
  httpServer.stop();
  httpServer.start();
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  httpServer.Free;
  logger.Free;
end;

end.
