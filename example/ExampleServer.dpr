program ExampleServer;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  Http.Server in 'HttpServer\Http.Server.pas',
  Logger in 'Logger.pas',
  Http.Exceptions in 'HttpServer\Http.Exceptions.pas',
  HttpServer.ControllerAttribute in 'HttpServer\Router\Attributes\HttpServer.ControllerAttribute.pas',
  HttpServer.Router in 'HttpServer\Router\HttpServer.Router.pas',
  HttpServer.MethodAttributes in 'HttpServer\Router\Attributes\HttpServer.MethodAttributes.pas',
  User.Controller in 'User\User.Controller.pas',
  User.UserDto in 'User\User.UserDto.pas',
  User.UserDataClass in 'User\User.UserDataClass.pas',
  HttpServer.ParamAttributes in 'HttpServer\Router\Attributes\HttpServer.ParamAttributes.pas',
  HttpServer.Router.Registration in 'HttpServer\Router\HttpServer.Router.Registration.pas',
  HttpServer.Router.Utils in 'HttpServer\Router\HttpServer.Router.Utils.pas',
  HttpServer.Router.Routes in 'HttpServer\Router\HttpServer.Router.Routes.pas',
  HttpServer.Router.Endpoint in 'HttpServer\Router\HttpServer.Router.Endpoint.pas',
  Http.HTTPMethods in 'HttpServer\Http.HTTPMethods.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
