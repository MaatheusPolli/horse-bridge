program HorseBridge;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  App.Server in 'src\App\App.Server.pas',
  App.Config in 'src\App\App.Config.pas',
  App.Container in 'src\App\App.Container.pas',
  App.Routes in 'src\App\App.Routes.pas',
  Middleware.ErrorHandler in 'src\Middlewares\Middleware.ErrorHandler.pas',
  Middleware.Logger in 'src\Middlewares\Middleware.Logger.pas',
  Middleware.Auth in 'src\Middlewares\Middleware.Auth.pas',
  Controller.Auth in 'src\Controllers\Controller.Auth.pas',
  Controller.Produto in 'src\Controllers\Controller.Produto.pas',
  Controller.Categoria in 'src\Controllers\Controller.Categoria.pas',
  Controller.Health in 'src\Controllers\Controller.Health.pas',
  Service.Produto in 'src\Services\Service.Produto.pas',
  Service.Categoria in 'src\Services\Service.Categoria.pas',
  Service.Auth in 'src\Services\Service.Auth.pas',
  Repository.Base in 'src\Repositories\Repository.Base.pas',
  Repository.Produto in 'src\Repositories\Repository.Produto.pas',
  Repository.Categoria in 'src\Repositories\Repository.Categoria.pas',
  Domain.Produto in 'src\Domain\Domain.Produto.pas',
  Domain.Categoria in 'src\Domain\Domain.Categoria.pas',
  Domain.Exceptions in 'src\Domain\Domain.Exceptions.pas',
  Domain.Validators in 'src\Domain\Domain.Validators.pas',
  DTO.Produto in 'src\DTO\DTO.Produto.pas',
  DTO.Paginacao in 'src\DTO\DTO.Paginacao.pas',
  DTO.Problem in 'src\DTO\DTO.Problem.pas',
  Infra.Connection in 'src\Infra\Infra.Connection.pas',
  Infra.Migrations in 'src\Infra\Infra.Migrations.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    TAppServer.Start;
  except
    on E: Exception do
    begin
      Writeln('Erro fatal: ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
