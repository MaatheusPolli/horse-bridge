unit Repository.Produto;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Domain.Produto, DTO.Paginacao;

type
  IProdutoRepository = interface
    ['{B3C4D5E6-F7A8-9012-3456-789ABCDEF012}']
    function FindPaginated(const APaginacao: TPaginacaoRequest): TPaginatedResult;
    function FindById(AId: Integer): TProduto;
    function ExistsBySku(const ASku: string; AExcludeId: Integer = 0): Boolean;
    function Insert(const AProduto: TProduto): Integer;
    procedure Update(const AProduto: TProduto);
    procedure SoftDelete(AId: Integer);
  end;

  TPaginatedResult = record
    Items: TList<TProduto>;
    Total: Integer;
  end;

  TProdutoRepository = class(TInterfacedObject, IProdutoRepository)
  private
    FConn: TFDConnection;
    function MapRow(AQuery: TFDQuery): TProduto;
  public
    constructor Create(AConn: TFDConnection);
    function FindPaginated(const APaginacao: TPaginacaoRequest): TPaginatedResult;
    function FindById(AId: Integer): TProduto;
    function ExistsBySku(const ASku: string; AExcludeId: Integer = 0): Boolean;
    function Insert(const AProduto: TProduto): Integer;
    procedure Update(const AProduto: TProduto);
    procedure SoftDelete(AId: Integer);
  end;

implementation

uses
  System.SysUtils, Domain.Exceptions;

{ TProdutoRepository }

constructor TProdutoRepository.Create(AConn: TFDConnection);
begin
  inherited Create;
  FConn := AConn;
end;

function TProdutoRepository.MapRow(AQuery: TFDQuery): TProduto;
begin
  Result.Id := AQuery.FieldByName('id').AsInteger;
  Result.Sku := AQuery.FieldByName('sku').AsString;
  Result.Ean := AQuery.FieldByName('ean').AsString;
  Result.Nome := AQuery.FieldByName('nome').AsString;
  Result.Descricao := AQuery.FieldByName('descricao').AsString;
  Result.Preco := AQuery.FieldByName('preco').AsCurrency;
  Result.Estoque := AQuery.FieldByName('estoque').AsInteger;
  Result.CategoriaId := AQuery.FieldByName('categoria_id').AsInteger;
  Result.Ativo := AQuery.FieldByName('ativo').AsInteger = 1;
  Result.CriadoEm := AQuery.FieldByName('criado_em').AsString;
  Result.AtualizadoEm := AQuery.FieldByName('atualizado_em').AsString;

  if AQuery.FindField('categoria_nome') <> nil then
    Result.CategoriaNome := AQuery.FieldByName('categoria_nome').AsString;
end;

function TProdutoRepository.FindPaginated(const APaginacao: TPaginacaoRequest): TPaginatedResult;
var
  LQuery: TFDQuery;
  LWhere, LCountSQL, LDataSQL: string;
  LOffset: Integer;
begin
  Result.Items := TList<TProduto>.Create;

  LWhere := 'WHERE p.ativo = 1';

  if not APaginacao.Query.IsEmpty then
    LWhere := LWhere + ' AND (p.nome LIKE :q OR p.sku LIKE :q OR p.ean LIKE :q)';

  if not APaginacao.Categoria.IsEmpty then
    LWhere := LWhere + ' AND c.nome = :categoria';

  LCountSQL := 'SELECT COUNT(*) AS total FROM produto p ' +
               'LEFT JOIN categoria c ON c.id = p.categoria_id ' + LWhere;

  LDataSQL := 'SELECT p.*, c.nome AS categoria_nome FROM produto p ' +
              'LEFT JOIN categoria c ON c.id = p.categoria_id ' +
              LWhere + ' ORDER BY p.nome LIMIT :limit OFFSET :offset';

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;

    LQuery.SQL.Text := LCountSQL;
    if not APaginacao.Query.IsEmpty then
      LQuery.ParamByName('q').AsString := '%' + APaginacao.Query + '%';
    if not APaginacao.Categoria.IsEmpty then
      LQuery.ParamByName('categoria').AsString := APaginacao.Categoria;
    LQuery.Open;
    Result.Total := LQuery.FieldByName('total').AsInteger;
    LQuery.Close;

    LOffset := (APaginacao.Page - 1) * APaginacao.Size;
    LQuery.SQL.Text := LDataSQL;
    if not APaginacao.Query.IsEmpty then
      LQuery.ParamByName('q').AsString := '%' + APaginacao.Query + '%';
    if not APaginacao.Categoria.IsEmpty then
      LQuery.ParamByName('categoria').AsString := APaginacao.Categoria;
    LQuery.ParamByName('limit').AsInteger := APaginacao.Size;
    LQuery.ParamByName('offset').AsInteger := LOffset;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      Result.Items.Add(MapRow(LQuery));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

function TProdutoRepository.FindById(AId: Integer): TProduto;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text :=
      'SELECT p.*, c.nome AS categoria_nome FROM produto p ' +
      'LEFT JOIN categoria c ON c.id = p.categoria_id ' +
      'WHERE p.id = :id AND p.ativo = 1';
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.Open;
    if LQuery.IsEmpty then
      raise ENotFoundError.CreateFmt('Produto %d não encontrado', [AId]);
    Result := MapRow(LQuery);
  finally
    LQuery.Free;
  end;
end;

function TProdutoRepository.ExistsBySku(const ASku: string; AExcludeId: Integer): Boolean;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'SELECT COUNT(*) AS cnt FROM produto WHERE UPPER(sku) = UPPER(:sku) AND ativo = 1 AND id <> :excludeId';
    LQuery.ParamByName('sku').AsString := ASku;
    LQuery.ParamByName('excludeId').AsInteger := AExcludeId;
    LQuery.Open;
    Result := LQuery.FieldByName('cnt').AsInteger > 0;
  finally
    LQuery.Free;
  end;
end;

function TProdutoRepository.Insert(const AProduto: TProduto): Integer;
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text :=
      'INSERT INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id) ' +
      'VALUES (:sku, :ean, :nome, :descricao, :preco, :estoque, :categoria_id)';
    LQuery.ParamByName('sku').AsString := AProduto.Sku;
    LQuery.ParamByName('ean').AsString := AProduto.Ean;
    LQuery.ParamByName('nome').AsString := AProduto.Nome;
    LQuery.ParamByName('descricao').AsString := AProduto.Descricao;
    LQuery.ParamByName('preco').AsCurrency := AProduto.Preco;
    LQuery.ParamByName('estoque').AsInteger := AProduto.Estoque;
    LQuery.ParamByName('categoria_id').AsInteger := AProduto.CategoriaId;
    LQuery.ExecSQL;

    LQuery.SQL.Text := 'SELECT last_insert_rowid() AS id';
    LQuery.Open;
    Result := LQuery.FieldByName('id').AsInteger;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepository.Update(const AProduto: TProduto);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text :=
      'UPDATE produto SET sku = :sku, ean = :ean, nome = :nome, descricao = :descricao, ' +
      'preco = :preco, estoque = :estoque, categoria_id = :categoria_id, ' +
      'atualizado_em = datetime(''now'') WHERE id = :id';
    LQuery.ParamByName('sku').AsString := AProduto.Sku;
    LQuery.ParamByName('ean').AsString := AProduto.Ean;
    LQuery.ParamByName('nome').AsString := AProduto.Nome;
    LQuery.ParamByName('descricao').AsString := AProduto.Descricao;
    LQuery.ParamByName('preco').AsCurrency := AProduto.Preco;
    LQuery.ParamByName('estoque').AsInteger := AProduto.Estoque;
    LQuery.ParamByName('categoria_id').AsInteger := AProduto.CategoriaId;
    LQuery.ParamByName('id').AsInteger := AProduto.Id;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

procedure TProdutoRepository.SoftDelete(AId: Integer);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := 'UPDATE produto SET ativo = 0, atualizado_em = datetime(''now'') WHERE id = :id';
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.ExecSQL;
  finally
    LQuery.Free;
  end;
end;

end.
