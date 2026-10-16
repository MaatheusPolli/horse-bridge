INSERT OR IGNORE INTO categoria (id, nome) VALUES (1, 'Eletrônicos');
INSERT OR IGNORE INTO categoria (id, nome) VALUES (2, 'Alimentos');
INSERT OR IGNORE INTO categoria (id, nome) VALUES (3, 'Vestuário');
INSERT OR IGNORE INTO categoria (id, nome) VALUES (4, 'Livros');

INSERT OR IGNORE INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id)
VALUES ('ELEC-001', '7891234567890', 'Fone Bluetooth', 'Fone de ouvido sem fio com cancelamento de ruído', 199.90, 50, 1);

INSERT OR IGNORE INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id)
VALUES ('ELEC-002', '7891234567891', 'Teclado Mecânico', 'Teclado mecânico RGB switch blue', 349.90, 30, 1);

INSERT OR IGNORE INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id)
VALUES ('ALIM-001', '7891234567892', 'Café Especial 250g', 'Café arábica torrado e moído', 32.50, 200, 2);

INSERT OR IGNORE INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id)
VALUES ('VEST-001', '7891234567893', 'Camiseta Dev', 'Camiseta 100% algodão estampa código', 59.90, 100, 3);

INSERT OR IGNORE INTO produto (sku, ean, nome, descricao, preco, estoque, categoria_id)
VALUES ('LIVR-001', '7891234567894', 'Clean Code', 'Robert C. Martin - Código Limpo', 89.90, 40, 4);
