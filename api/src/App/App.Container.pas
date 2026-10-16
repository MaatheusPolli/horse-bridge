unit App.Container;

interface

uses
  Service.Produto, Service.Categoria, Service.Auth,
  Repository.Produto, Repository.Categoria;

type
  TContainer = class
  private
    class var FInstance: TContainer;
    FProdutoRepository: IProdutoRepository;
    FCategoriaRepository: ICategoriaRepository;
    FProdutoService: IProdutoService;
    FCategoriaService: ICategoriaService;
    FAuthService: IAuthService;
  public
    class function GetInstance: TContainer;
    class procedure ReleaseInstance;
    procedure Build;

    property ProdutoService: IProdutoService read FProdutoService;
    property CategoriaService: ICategoriaService read FCategoriaService;
    property AuthService: IAuthService read FAuthService;
  end;

implementation

uses
  System.SysUtils, Infra.Connection;

{ TContainer }

class function TContainer.GetInstance: TContainer;
begin
  if not Assigned(FInstance) then
    FInstance := TContainer.Create;
  Result := FInstance;
end;

class procedure TContainer.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

procedure TContainer.Build;
begin
  FProdutoRepository := TProdutoRepository.Create(TConnectionFactory.GetConnection);
  FCategoriaRepository := TCategoriaRepository.Create(TConnectionFactory.GetConnection);
  FProdutoService := TProdutoService.Create(FProdutoRepository);
  FCategoriaService := TCategoriaService.Create(FCategoriaRepository);
  FAuthService := TAuthService.Create;
end;

end.
