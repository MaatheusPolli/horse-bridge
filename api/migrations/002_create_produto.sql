CREATE TABLE IF NOT EXISTS produto (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sku TEXT NOT NULL UNIQUE,
  ean TEXT,
  nome TEXT NOT NULL,
  descricao TEXT,
  preco REAL NOT NULL CHECK (preco >= 0),
  estoque INTEGER NOT NULL DEFAULT 0,
  categoria_id INTEGER REFERENCES categoria(id),
  ativo INTEGER NOT NULL DEFAULT 1,
  criado_em TEXT NOT NULL DEFAULT (datetime('now')),
  atualizado_em TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_produto_nome ON produto(nome);
CREATE INDEX IF NOT EXISTS idx_produto_sku ON produto(sku);
CREATE INDEX IF NOT EXISTS idx_produto_ean ON produto(ean);
