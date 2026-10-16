# Horse Bridge

> API REST em Delphi (Horse) + Front-end React/TypeScript para catálogo de produtos.

Demonstra que Delphi entrega backend moderno — autenticação JWT, validação com erros RFC 7807, paginação, documentação OpenAPI e testes de integração — consumido por um front React com TanStack Query.

## Arquitetura

```
┌─────────────┐     HTTP/JSON      ┌──────────────────────────────────────┐
│   React SPA │ ──────────────────► │  Horse (Delphi REST Framework)      │
│  TanStack Q │ ◄────────────────── │                                      │
│  Hook Form  │                     │  Middlewares: CORS, JWT, Logger,     │
│  Zod        │                     │              Error Handler (7807)    │
└─────────────┘                     │                                      │
                                    │  Controllers → Services → Repos      │
                                    │                        ↓              │
                                    │                   FireDAC + SQLite    │
                                    └──────────────────────────────────────┘
```

## Rotas da API

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| POST | `/auth/login` | — | Retorna JWT |
| GET | `/produtos` | — | Lista com paginação e busca (?page, size, q, categoria) |
| GET | `/produtos/:id` | — | Detalhe do produto |
| POST | `/produtos` | JWT | Criar produto |
| PUT | `/produtos/:id` | JWT | Atualizar produto |
| DELETE | `/produtos/:id` | JWT | Soft delete |
| GET | `/categorias` | — | Listar categorias |
| POST | `/categorias` | JWT | Criar categoria |
| PUT | `/categorias/:id` | JWT | Atualizar categoria |
| DELETE | `/categorias/:id` | JWT | Soft delete |
| GET | `/health` | — | Health check |
| GET | `/swagger` | — | OpenAPI 3.0 spec |

## Pré-requisitos

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

Copie `.env.example` para `.env` e ajuste se necessário:

```bash
cp .env.example .env
```

Execute o binário gerado. A API sobe na porta 9000 por padrão.

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
Usuário: admin
Senha: admin123
```

### Docker (front apenas)

Com a API rodando nativamente:

```bash
docker compose up --build
# Front disponível em http://localhost:3000
```

## Testes

### API

```bash
cd api/tests
msbuild HorseBridgeTests.dproj /t:Build /p:Config=Debug /p:Platform=Win32
.\Win32\Debug\HorseBridgeTests.exe
```

Testes cobrem:
- **Unitários:** Validators (EAN-13, SKU), Services com repositório mock
- **Integração:** Servidor Horse em memória, chamadas HTTP reais validando status codes, corpo JSON e headers

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
├── api/                          # Backend Delphi + Horse
│   ├── src/
│   │   ├── App/                  # Bootstrap, config, DI, rotas
│   │   ├── Controllers/          # Endpoints HTTP
│   │   ├── Services/             # Regras de negócio
│   │   ├── Repositories/         # Acesso a dados (FireDAC)
│   │   ├── Domain/               # Entidades, validators, exceções
│   │   ├── DTO/                  # Request/Response objects
│   │   ├── Middlewares/          # Auth, Logger, Error Handler
│   │   └── Infra/                # Conexão, Migrations, Swagger
│   ├── migrations/               # SQL versionado
│   └── tests/                    # DUnitX
└── web/                          # Frontend React + TypeScript
    └── src/
        ├── api/                  # Client tipado + schema
        ├── hooks/                # TanStack Query hooks
        ├── pages/                # Login, Listagem, Formulário
        ├── components/           # Tabela, Form, Paginação, Dialog
        └── tests/                # Vitest + MSW
```

## Licença

MIT
