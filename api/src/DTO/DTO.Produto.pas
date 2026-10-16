unit DTO.Produto;

interface

uses
  System.JSON;

type
  TProdutoRequest = record
    Sku: string;
    Ean: string;
    Nome: string;
    Descricao: string;
    Preco: Currency;
    Estoque: Integer;
    CategoriaId: Integer;
    class function FromJSON(AJSON: TJSONObject): TProdutoRequest; static;
  end;

  TProdutoResponse = record
    Id: Integer;
    Sku: string;
    Ean: string;
    Nome: string;
    Descricao: string;
    Preco: Currency;
    Estoque: Integer;
    CategoriaId: Integer;
    CategoriaNome: string;
    Ativo: Boolean;
    CriadoEm: string;
    AtualizadoEm: string;
    function ToJSON: TJSONObject;
  end;

  TCategoriaRequest = record
    Nome: string;
    class function FromJSON(AJSON: TJSONObject): TCategoriaRequest; static;
  end;

  TCategoriaResponse = record
    Id: Integer;
    Nome: string;
    Ativo: Boolean;
    function ToJSON: TJSONObject;
  end;

implementation

uses
  System.SysUtils;

{ TProdutoRequest }

class function TProdutoRequest.FromJSON(AJSON: TJSONObject): TProdutoRequest;
begin
  Result := Default(TProdutoRequest);
  if AJSON = nil then
    Exit;
  AJSON.TryGetValue<string>('sku', Result.Sku);
  AJSON.TryGetValue<string>('ean', Result.Ean);
  AJSON.TryGetValue<string>('nome', Result.Nome);
  AJSON.TryGetValue<string>('descricao', Result.Descricao);
  AJSON.TryGetValue<Currency>('preco', Result.Preco);
  AJSON.TryGetValue<Integer>('estoque', Result.Estoque);
  AJSON.TryGetValue<Integer>('categoria_id', Result.CategoriaId);
end;

{ TProdutoResponse }

function TProdutoResponse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(Id));
  Result.AddPair('sku', Sku);
  Result.AddPair('ean', Ean);
  Result.AddPair('nome', Nome);
  Result.AddPair('descricao', Descricao);
  Result.AddPair('preco', TJSONNumber.Create(Double(Preco)));
  Result.AddPair('estoque', TJSONNumber.Create(Estoque));
  Result.AddPair('categoria_id', TJSONNumber.Create(CategoriaId));
  Result.AddPair('categoria_nome', CategoriaNome);
  Result.AddPair('ativo', TJSONBool.Create(Ativo));
  Result.AddPair('criado_em', CriadoEm);
  Result.AddPair('atualizado_em', AtualizadoEm);
end;

{ TCategoriaRequest }

class function TCategoriaRequest.FromJSON(AJSON: TJSONObject): TCategoriaRequest;
begin
  Result := Default(TCategoriaRequest);
  if AJSON = nil then
    Exit;
  AJSON.TryGetValue<string>('nome', Result.Nome);
end;

{ TCategoriaResponse }

function TCategoriaResponse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('id', TJSONNumber.Create(Id));
  Result.AddPair('nome', Nome);
  Result.AddPair('ativo', TJSONBool.Create(Ativo));
end;

end.
