program HorseBridgeTests;

{$APPTYPE CONSOLE}

{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  Tests.Validators in 'Tests.Validators.pas',
  Tests.Service.Produto in 'Tests.Service.Produto.pas',
  Tests.Api.Auth in 'Tests.Api.Auth.pas',
  Tests.Api.Produto in 'Tests.Api.Produto.pas',
  Tests.TestSetup in 'Tests.TestSetup.pas',
  Domain.Validators in '..\src\Domain\Domain.Validators.pas',
  Domain.Exceptions in '..\src\Domain\Domain.Exceptions.pas',
  Domain.Produto in '..\src\Domain\Domain.Produto.pas',
  Domain.Categoria in '..\src\Domain\Domain.Categoria.pas',
  DTO.Produto in '..\src\DTO\DTO.Produto.pas',
  DTO.Paginacao in '..\src\DTO\DTO.Paginacao.pas',
  DTO.Problem in '..\src\DTO\DTO.Problem.pas',
  Service.Produto in '..\src\Services\Service.Produto.pas',
  Service.Categoria in '..\src\Services\Service.Categoria.pas',
  Service.Auth in '..\src\Services\Service.Auth.pas',
  Repository.Produto in '..\src\Repositories\Repository.Produto.pas',
  Repository.Categoria in '..\src\Repositories\Repository.Categoria.pas',
  Repository.Base in '..\src\Repositories\Repository.Base.pas',
  Controller.Health in '..\src\Controllers\Controller.Health.pas',
  Controller.Auth in '..\src\Controllers\Controller.Auth.pas',
  Controller.Produto in '..\src\Controllers\Controller.Produto.pas',
  Controller.Categoria in '..\src\Controllers\Controller.Categoria.pas',
  Middleware.ErrorHandler in '..\src\Middlewares\Middleware.ErrorHandler.pas',
  Middleware.Logger in '..\src\Middlewares\Middleware.Logger.pas',
  Middleware.Auth in '..\src\Middlewares\Middleware.Auth.pas',
  App.Config in '..\src\App\App.Config.pas',
  App.Container in '..\src\App\App.Container.pas',
  App.Routes in '..\src\App\App.Routes.pas',
  App.Server in '..\src\App\App.Server.pas',
  Infra.Connection in '..\src\Infra\Infra.Connection.pas',
  Infra.Migrations in '..\src\Infra\Infra.Migrations.pas',
  Infra.Swagger in '..\src\Infra\Infra.Swagger.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  ReportMemoryLeaksOnShutdown := True;
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);
    Runner.UseRTTI := True;

    Results := Runner.Execute;

    if not Results.AllPassed then
      ExitCode := 1;

    {$IFNDEF CI}
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      Write('Pressione ENTER para continuar...');
      Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
