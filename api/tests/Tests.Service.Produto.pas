unit Tests.Service.Produto;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TProdutoServiceTest = class
  public
    [Test]
    procedure Create_ComDadosValidos_RetornaProduto;
    [Test]
    procedure Create_SemNome_LancaValidationError;
    [Test]
    procedure Create_SKUInvalido_LancaValidationError;
    [Test]
    procedure Create_EANInvalido_LancaValidationError;
    [Test]
    procedure Create_PrecoNegativo_LancaValidationError;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections,
  Domain.Produto, Domain.Exceptions, DTO.Produto, DTO.Paginacao,
  Repository.Produto, Service.Produto;

type
  TMockProdutoRepository = class(TInterfacedObject, IProdutoRepository)
  private
    FItems: TList<TProduto>;
    FNextId: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function FindPaginated(const APaginacao: TPaginacaoRequest): TPaginatedResult;
    function FindById(AId: Integer): TProduto;
    function ExistsBySku(const ASku: string; AExcludeId: Integer = 0): Boolean;
    function Insert(const AProduto: TProduto): Integer;
    procedure Update(const AProduto: TProduto);
    procedure SoftDelete(AId: Integer);
  end;

{ TMockProdutoRepository }

constructor TMockProdutoRepository.Create;
begin
  inherited;
  FItems := TList<TProduto>.Create;
  FNextId := 1;
end;

destructor TMockProdutoRepository.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TMockProdutoRepository.FindPaginated(const APaginacao: TPaginacaoRequest): TPaginatedResult;
begin
  Result.Items := TList<TProduto>.Create;
  Result.Items.AddRange(FItems);
  Result.Total := FItems.Count;
end;

function TMockProdutoRepository.FindById(AId: Integer): TProduto;
var
  LP: TProduto;
begin
  for LP in FItems do
    if LP.Id = AId then
      Exit(LP);
  raise ENotFoundError.CreateFmt('Produto %d não encontrado', [AId]);
end;

function TMockProdutoRepository.ExistsBySku(const ASku: string; AExcludeId: Integer): Boolean;
var
  LP: TProduto;
begin
  Result := False;
  for LP in FItems do
    if (LP.Sku.ToUpper = ASku.ToUpper) and (LP.Id <> AExcludeId) then
      Exit(True);
end;

function TMockProdutoRepository.Insert(const AProduto: TProduto): Integer;
var
  LP: TProduto;
begin
  LP := AProduto;
  LP.Id := FNextId;
  LP.Ativo := True;
  LP.CriadoEm := '2024-01-01T00:00:00';
  LP.AtualizadoEm := LP.CriadoEm;
  Inc(FNextId);
  FItems.Add(LP);
  Result := LP.Id;
end;

procedure TMockProdutoRepository.Update(const AProduto: TProduto);
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Id = AProduto.Id then
    begin
      FItems[I] := AProduto;
      Exit;
    end;
end;

procedure TMockProdutoRepository.SoftDelete(AId: Integer);
var
  I: Integer;
  LP: TProduto;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I].Id = AId then
    begin
      LP := FItems[I];
      LP.Ativo := False;
      FItems[I] := LP;
      Exit;
    end;
end;

{ TProdutoServiceTest }

procedure TProdutoServiceTest.Create_ComDadosValidos_RetornaProduto;
var
  LRepo: IProdutoRepository;
  LService: IProdutoService;
  LRequest: TProdutoRequest;
  LResult: TProdutoResponse;
begin
  LRepo := TMockProdutoRepository.Create;
  LService := TProdutoService.Create(LRepo);

  LRequest := Default(TProdutoRequest);
  LRequest.Sku := 'TEST-001';
  LRequest.Nome := 'Produto Teste';
  LRequest.Preco := 99.90;
  LRequest.Estoque := 10;

  LResult := LService.Create_(LRequest);
  Assert.AreEqual('TEST-001', LResult.Sku);
  Assert.AreEqual('Produto Teste', LResult.Nome);
end;

procedure TProdutoServiceTest.Create_SemNome_LancaValidationError;
var
  LRepo: IProdutoRepository;
  LService: IProdutoService;
  LRequest: TProdutoRequest;
begin
  LRepo := TMockProdutoRepository.Create;
  LService := TProdutoService.Create(LRepo);

  LRequest := Default(TProdutoRequest);
  LRequest.Sku := 'TEST-001';
  LRequest.Preco := 10;

  Assert.WillRaise(
    procedure
    begin
      LService.Create_(LRequest);
    end,
    EValidationError);
end;

procedure TProdutoServiceTest.Create_SKUInvalido_LancaValidationError;
var
  LRepo: IProdutoRepository;
  LService: IProdutoService;
  LRequest: TProdutoRequest;
begin
  LRepo := TMockProdutoRepository.Create;
  LService := TProdutoService.Create(LRepo);

  LRequest := Default(TProdutoRequest);
  LRequest.Sku := 'ab';
  LRequest.Nome := 'Produto';
  LRequest.Preco := 10;

  Assert.WillRaise(
    procedure
    begin
      LService.Create_(LRequest);
    end,
    EValidationError);
end;

procedure TProdutoServiceTest.Create_EANInvalido_LancaValidationError;
var
  LRepo: IProdutoRepository;
  LService: IProdutoService;
  LRequest: TProdutoRequest;
begin
  LRepo := TMockProdutoRepository.Create;
  LService := TProdutoService.Create(LRepo);

  LRequest := Default(TProdutoRequest);
  LRequest.Sku := 'TEST-001';
  LRequest.Nome := 'Produto';
  LRequest.Ean := '1234567890123';
  LRequest.Preco := 10;

  Assert.WillRaise(
    procedure
    begin
      LService.Create_(LRequest);
    end,
    EValidationError);
end;

procedure TProdutoServiceTest.Create_PrecoNegativo_LancaValidationError;
var
  LRepo: IProdutoRepository;
  LService: IProdutoService;
  LRequest: TProdutoRequest;
begin
  LRepo := TMockProdutoRepository.Create;
  LService := TProdutoService.Create(LRepo);

  LRequest := Default(TProdutoRequest);
  LRequest.Sku := 'TEST-001';
  LRequest.Nome := 'Produto';
  LRequest.Preco := -1;

  Assert.WillRaise(
    procedure
    begin
      LService.Create_(LRequest);
    end,
    EValidationError);
end;

end.
