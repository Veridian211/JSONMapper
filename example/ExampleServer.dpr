program ExampleServer;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Logger in 'Logger.pas',
  Http.Server in 'HttpServer\Http.Server.pas',
  Http.Exceptions in 'HttpServer\common\Http.Exceptions.pas',
  Http.HTTPMethods in 'HttpServer\common\Http.HTTPMethods.pas',
  Http.Request in 'HttpServer\common\Http.Request.pas',
  HttpServer.ControllerAttribute in 'HttpServer\Router\Attributes\HttpServer.ControllerAttribute.pas',
  HttpServer.Router in 'HttpServer\Router\HttpServer.Router.pas',
  HttpServer.MethodAttributes in 'HttpServer\Router\Attributes\HttpServer.MethodAttributes.pas',
  HttpServer.ParamAttributes in 'HttpServer\Router\Attributes\HttpServer.ParamAttributes.pas',
  HttpServer.Router.Registration in 'HttpServer\Router\HttpServer.Router.Registration.pas',
  HttpServer.Router.Utils in 'HttpServer\Router\HttpServer.Router.Utils.pas',
  HttpServer.Router.Routes in 'HttpServer\Router\HttpServer.Router.Routes.pas',
  HttpServer.Router.Endpoint in 'HttpServer\Router\HttpServer.Router.Endpoint.pas',
  User.Controller in 'User\User.Controller.pas',
  User.UserDataClass in 'User\User.UserDataClass.pas',
  User.Repository in 'User\User.Repository.pas',
  User.Service in 'User\User.Service.pas',
  User.Dtos in 'User\User.Dtos.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
