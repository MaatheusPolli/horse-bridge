unit App.Server;

interface

type
  TAppServer = class
  public
    class procedure Start;
  end;

implementation

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  App.Config,
  App.Container,
  App.Routes,
  Middleware.ErrorHandler,
  Middleware.Logger,
  Infra.Connection,
  Infra.Migrations,
  Infra.Swagger;

{ TAppServer }

class procedure TAppServer.Start;
var
  LConfig: TAppConfig;
begin
  LConfig := TAppConfig.GetInstance;
  LConfig.LoadFromEnv;

  TConnectionFactory.Initialize(LConfig.DbPath);
  TMigrationRunner.Execute(TConnectionFactory.GetConnection);

  TContainer.GetInstance.Build;

  THorse
    .Use(Jhonson)
    .Use(CORS)
    .Use(TMiddlewareLogger.Execute)
    .Use(TMiddlewareErrorHandler.Execute);

  RegisterRoutes;
  TSwaggerSetup.Register;

  Writeln(Format('Horse Bridge API rodando na porta %d', [LConfig.ServerPort]));
  THorse.Listen(LConfig.ServerPort);
end;

end.
