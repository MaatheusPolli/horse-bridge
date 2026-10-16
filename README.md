# Horse Bridge

> API REST em Delphi (Horse) + Front-end React/TypeScript para catÃ¡logo de produtos.

Demonstra que Delphi entrega backend moderno â€” autenticaÃ§Ã£o JWT, validaÃ§Ã£o com erros RFC 7807, paginaÃ§Ã£o, documentaÃ§Ã£o OpenAPI e testes de integraÃ§Ã£o â€” consumido por um front React com TanStack Query.

## Arquitetura

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     HTTP/JSON      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚   React SPA â”‚ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–º â”‚  Horse (Delphi REST Framework)      â”‚
â”‚  TanStack Q â”‚ â—„â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ â”‚                                      â”‚
â”‚  Hook Form  â”‚                     â”‚  Middlewares: CORS, JWT, Logger,     â”‚
â”‚  Zod        â”‚                     â”‚              Error Handler (7807)    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                     â”‚                                      â”‚
                                    â”‚  Controllers â†’ Services â†’ Repos      â”‚
                                    â”‚                        â†“              â”‚
                                    â”‚                   FireDAC + SQLite    â”‚
                                    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## Rotas da API

| MÃ©todo | Rota | Auth | DescriÃ§Ã£o |
|--------|------|------|-----------|
| POST | `/auth/login` | â€” | Retorna JWT |
| GET | `/produtos` | â€” | Lista com paginaÃ§Ã£o e busca (?page, size, q, categoria) |
| GET | `/produtos/:id` | â€” | Detalhe do produto |
| POST | `/produtos` | JWT | Criar produto |
| PUT | `/produtos/:id` | JWT | Atualizar produto |
| DELETE | `/produtos/:id` | JWT | Soft delete |
| GET | `/categorias` | â€” | Listar categorias |
| POST | `/categorias` | JWT | Criar categoria |
| PUT | `/categorias/:id` | JWT | Atualizar categoria |
| DELETE | `/categorias/:id` | JWT | Soft delete |
| GET | `/health` | â€” | Health check |
| GET | `/swagger` | â€” | OpenAPI 3.0 spec |

## PrÃ©-requisitos

- **API:** Delphi 12 CE (ou RAD Studio) + [Boss](https://github.com/HashLoad/boss)
- **Front:** Node.js 20+
- **Docker** (opcional, para o front em container)

## Rodando localmente

### API (Delphi)

```bash
cd api
boss install
# Abra HorseBridge.dproj no Delphi e compile (F9)
# Ou via linha de comando:
msbuild HorseBridge.dproj /t:Build /p:Config=Debug /p:Platform=Win32
```

Copie `.env.example` para `.env` e ajuste se necessÃ¡rio:

```bash
cp .env.example .env
```

Execute o binÃ¡rio gerado. A API sobe na porta 9000 por padrÃ£o.

```bash
curl http://localhost:9000/health
# {"status":"ok","timestamp":"...","version":"1.0.0"}
```

### Front-end (React)

```bash
cd web
npm install
npm run dev
# Abra http://localhost:5173
```

O Vite faz proxy de `/api` para `localhost:9000`.

### Login

```
UsuÃ¡rio: admin
Senha: admin123
```

### Docker (front apenas)

Com a API rodando nativamente:

```bash
docker compose up --build
# Front disponÃ­vel em http://localhost:3000
```

## Testes

### API

```bash
cd api/tests
msbuild HorseBridgeTests.dproj /t:Build /p:Config=Debug /p:Platform=Win32
.\Win32\Debug\HorseBridgeTests.exe
```

Testes cobrem:
- **UnitÃ¡rios:** Validators (EAN-13, SKU), Services com repositÃ³rio mock
- **IntegraÃ§Ã£o:** Servidor Horse em memÃ³ria, chamadas HTTP reais validando status codes, corpo JSON e headers

### Front

```bash
cd web
npm test
```

Testes com Vitest + Testing Library + MSW cobrindo:
- Login (sucesso e erro)
- Listagem e busca de produtos
- Rotas protegidas

## Exemplos com curl

```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | jq -r .token)

# Listar produtos
curl http://localhost:9000/produtos?page=1&size=10

# Criar produto
curl -X POST http://localhost:9000/produtos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"sku":"NEW-001","nome":"Produto Novo","preco":99.90,"estoque":10,"categoria_id":1}'

# Buscar por nome
curl "http://localhost:9000/produtos?q=Fone"

# Swagger/OpenAPI
curl http://localhost:9000/swagger
```

## Stack

| Camada | Tecnologia |
|--------|-----------|
| API | Delphi 12 CE + Horse |
| Pacotes | Boss (horse, horse-jwt, horse-cors, horse-jhonson, delphi-jose-jwt) |
| Banco | SQLite via FireDAC |
| Testes API | DUnitX + System.Net.HttpClient |
| Front | React 18, Vite, TypeScript, TanStack Query, React Hook Form, Zod |
| Testes Front | Vitest, Testing Library, MSW |
| CI | GitHub Actions |

## Estrutura

```
horse-bridge/
â”œâ”€â”€ api/                          # Backend Delphi + Horse
â”‚   â”œâ”€â”€ src/
â”‚   â”‚   â”œâ”€â”€ App/                  # Bootstrap, config, DI, rotas
â”‚   â”‚   â”œâ”€â”€ Controllers/          # Endpoints HTTP
â”‚   â”‚   â”œâ”€â”€ Services/             # Regras de negÃ³cio
â”‚   â”‚   â”œâ”€â”€ Repositories/         # Acesso a dados (FireDAC)
â”‚   â”‚   â”œâ”€â”€ Domain/               # Entidades, validators, exceÃ§Ãµes
â”‚   â”‚   â”œâ”€â”€ DTO/                  # Request/Response objects
â”‚   â”‚   â”œâ”€â”€ Middlewares/          # Auth, Logger, Error Handler
â”‚   â”‚   â””â”€â”€ Infra/                # ConexÃ£o, Migrations, Swagger
â”‚   â”œâ”€â”€ migrations/               # SQL versionado
â”‚   â””â”€â”€ tests/                    # DUnitX
â””â”€â”€ web/                          # Frontend React + TypeScript
    â””â”€â”€ src/
        â”œâ”€â”€ api/                  # Client tipado + schema
        â”œâ”€â”€ hooks/                # TanStack Query hooks
        â”œâ”€â”€ pages/                # Login, Listagem, FormulÃ¡rio
        â”œâ”€â”€ components/           # Tabela, Form, PaginaÃ§Ã£o, Dialog
        â””â”€â”€ tests/                # Vitest + MSW
```

## LicenÃ§a

MIT


## Licença

### Uso Pessoal
Este projeto é licenciado sob a **Licença MIT** para uso pessoal, educacional e não comercial.

### Uso Comercial
Se você deseja usar este projeto comercialmente, deve obter uma licença comercial do autor.

**Uso comercial inclui:**
- Incorporar em um produto comercial
- Oferecer como serviço
- Usar em atividades com fins lucrativos
- Implantação empresarial

**Para obter uma licença comercial:**
Email: ma.polli@hotmail.com
