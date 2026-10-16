unit App.Routes;

interface

procedure RegisterRoutes;

implementation

uses
  Horse,
  Controller.Health,
  Controller.Auth,
  Controller.Produto,
  Controller.Categoria,
  Middleware.Auth;

procedure RegisterRoutes;
begin
  TControllerHealth.RegisterRoutes;
  TControllerAuth.RegisterRoutes;
  TControllerProduto.RegisterRoutes;
  TControllerCategoria.RegisterRoutes;
end;

end.
