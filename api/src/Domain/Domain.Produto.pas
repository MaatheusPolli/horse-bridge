unit Domain.Produto;

interface

type
  TProduto = record
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
  end;

implementation

end.
