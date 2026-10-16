unit Service.Produto;

interface

uses
  System.JSON,
  Domain.Produto, DTO.Produto, DTO.Paginacao,
  Repository.Produto;

type
  IProdutoService = interface
    ['{E6F7A8B9-C0D1-2345-6789-ABCDEF012345}']
    function List(const APaginacao: TPaginacaoRequest): TJSONObject;
    function GetById(AId: Integer): TProdutoResponse;
    function Create_(const ARequest: TProdutoRequest): TProdutoResponse;
    procedure Update(AId: Integer; const ARequest: TProdutoRequest);
    procedure Delete(AId: Integer);
  end;

  TProdutoService = class(TInterfacedObject, IProdutoService)
  private
    FRepo: IProdutoRepository;
    function ToResponse(const AProduto: TProduto): TProdutoResponse;
    procedure Validate(const ARequest: TProdutoRequest; AExcludeId: Integer = 0);
  public
    constructor Create(ARepo: IProdutoRepository);
    function List(const APaginacao: TPaginacaoRequest): TJSONObject;
    function GetById(AId: Integer): TProdutoResponse;
    function Create_(const ARequest: TProdutoRequest): TProdutoResponse;
    procedure Update(AId: Integer; const ARequest: TProdutoRequest);
    procedure Delete(AId: Integer);
  end;

implementation

uses
  System.SysUtils, System.Math, System.Generics.Collections,
  Domain.Exceptions, Domain.Validators;

{ TProdutoService }

constructor TProdutoService.Create(ARepo: IProdutoRepository);
begin
  inherited Create;
  FRepo := ARepo;
end;

function TProdutoService.ToResponse(const AProduto: TProduto): TProdutoResponse;
begin
  Result.Id := AProduto.Id;
  Result.Sku := AProduto.Sku;
  Result.Ean := AProduto.Ean;
  Result.Nome := AProduto.Nome;
  Result.Descricao := AProduto.Descricao;
  Result.Preco := AProduto.Preco;
  Result.Estoque := AProduto.Estoque;
  Result.CategoriaId := AProduto.CategoriaId;
  Result.CategoriaNome := AProduto.CategoriaNome;
  Result.Ativo := AProduto.Ativo;
  Result.CriadoEm := AProduto.CriadoEm;
  Result.AtualizadoEm := AProduto.AtualizadoEm;
end;

procedure TProdutoService.Validate(const ARequest: TProdutoRequest; AExcludeId: Integer);
var
  LErrors: TList<string>;
begin
  LErrors := TList<string>.Create;
  try
    if ARequest.Nome.Trim.IsEmpty then
      LErrors.Add('Nome é obrigatório');

    if not TValidators.IsValidSKU(ARequest.Sku) then
      LErrors.Add('SKU inválido (3-20 caracteres, letras maiúsculas, números e hífen)');

    if (not ARequest.Ean.IsEmpty) and (not TValidators.IsValidEAN13(ARequest.Ean)) then
      LErrors.Add('EAN-13 inválido');

    if ARequest.Preco < 0 then
      LErrors.Add('Preço deve ser maior ou igual a zero');

    if ARequest.Estoque < 0 then
      LErrors.Add('Estoque deve ser maior ou igual a zero');

    if FRepo.ExistsBySku(ARequest.Sku, AExcludeId) then
      LErrors.Add('SKU já cadastrado');

    if LErrors.Count > 0 then
      raise EValidationError.Create(LErrors.ToArray);
  finally
    LErrors.Free;
  end;
end;

function TProdutoService.List(const APaginacao: TPaginacaoRequest): TJSONObject;
var
  LResult: TPaginatedResult;
  LData: TJSONArray;
  LProduto: TProduto;
  LMeta: TPaginacaoMeta;
  LPaginated: TPaginatedResponse;
begin
  LResult := FRepo.FindPaginated(APaginacao);
  try
    LData := TJSONArray.Create;
    for LProduto in LResult.Items do
      LData.Add(ToResponse(LProduto).ToJSON);

    LMeta.Page := APaginacao.Page;
    LMeta.Size := APaginacao.Size;
    LMeta.Total := LResult.Total;
    LMeta.TotalPages := Ceil(LResult.Total / APaginacao.Size);

    LPaginated.Data := LData;
    LPaginated.Meta := LMeta;
    Result := LPaginated.ToJSON;
  finally
    LResult.Items.Free;
  end;
end;

function TProdutoService.GetById(AId: Integer): TProdutoResponse;
begin
  Result := ToResponse(FRepo.FindById(AId));
end;

function TProdutoService.Create_(const ARequest: TProdutoRequest): TProdutoResponse;
var
  LProduto: TProduto;
  LId: Integer;
begin
  Validate(ARequest);

  LProduto := Default(TProduto);
  LProduto.Sku := ARequest.Sku;
  LProduto.Ean := ARequest.Ean;
  LProduto.Nome := ARequest.Nome.Trim;
  LProduto.Descricao := ARequest.Descricao;
  LProduto.Preco := ARequest.Preco;
  LProduto.Estoque := ARequest.Estoque;
  LProduto.CategoriaId := ARequest.CategoriaId;

  LId := FRepo.Insert(LProduto);
  Result := ToResponse(FRepo.FindById(LId));
end;

procedure TProdutoService.Update(AId: Integer; const ARequest: TProdutoRequest);
var
  LProduto: TProduto;
begin
  FRepo.FindById(AId);
  Validate(ARequest, AId);

  LProduto := Default(TProduto);
  LProduto.Id := AId;
  LProduto.Sku := ARequest.Sku;
  LProduto.Ean := ARequest.Ean;
  LProduto.Nome := ARequest.Nome.Trim;
  LProduto.Descricao := ARequest.Descricao;
  LProduto.Preco := ARequest.Preco;
  LProduto.Estoque := ARequest.Estoque;
  LProduto.CategoriaId := ARequest.CategoriaId;
  FRepo.Update(LProduto);
end;

procedure TProdutoService.Delete(AId: Integer);
begin
  FRepo.FindById(AId);
  FRepo.SoftDelete(AId);
end;

end.
