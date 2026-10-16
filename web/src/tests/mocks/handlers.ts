import { http, HttpResponse } from 'msw'

const mockCategorias = [
  { id: 1, nome: 'Eletrônicos', ativo: true },
  { id: 2, nome: 'Alimentos', ativo: true },
]

const mockProdutos = [
  {
    id: 1,
    sku: 'ELEC-001',
    ean: '7891234567890',
    nome: 'Fone Bluetooth',
    descricao: 'Fone sem fio',
    preco: 199.9,
    estoque: 50,
    categoria_id: 1,
    categoria_nome: 'Eletrônicos',
    ativo: true,
    criado_em: '2024-01-01T00:00:00',
    atualizado_em: '2024-01-01T00:00:00',
  },
  {
    id: 2,
    sku: 'ALIM-001',
    ean: '7891234567892',
    nome: 'Café Especial',
    descricao: 'Café arábica',
    preco: 32.5,
    estoque: 200,
    categoria_id: 2,
    categoria_nome: 'Alimentos',
    ativo: true,
    criado_em: '2024-01-01T00:00:00',
    atualizado_em: '2024-01-01T00:00:00',
  },
]

export const handlers = [
  http.post('/api/auth/login', async ({ request }) => {
    const body = (await request.json()) as { username: string; password: string }
    if (body.username === 'admin' && body.password === 'admin123') {
      return HttpResponse.json({
        token: 'mock-jwt-token',
        expires_in: 3600,
        token_type: 'Bearer',
      })
    }
    return HttpResponse.json(
      { type: 'about:blank', title: 'Unauthorized', status: 401, detail: 'Credenciais inválidas', errors: [] },
      { status: 401 },
    )
  }),

  http.get('/api/produtos', ({ request }) => {
    const url = new URL(request.url)
    const q = url.searchParams.get('q')?.toLowerCase()
    let filtered = mockProdutos

    if (q) {
      filtered = mockProdutos.filter(
        (p) => p.nome.toLowerCase().includes(q) || p.sku.toLowerCase().includes(q),
      )
    }

    return HttpResponse.json({
      data: filtered,
      meta: { page: 1, size: 20, total: filtered.length, total_pages: 1 },
    })
  }),

  http.get('/api/produtos/:id', ({ params }) => {
    const produto = mockProdutos.find((p) => p.id === Number(params.id))
    if (!produto) {
      return HttpResponse.json(
        { type: 'about:blank', title: 'Not Found', status: 404, detail: 'Produto não encontrado', errors: [] },
        { status: 404 },
      )
    }
    return HttpResponse.json(produto)
  }),

  http.post('/api/produtos', async ({ request }) => {
    const body = (await request.json()) as Record<string, unknown>
    return HttpResponse.json(
      { id: 99, ...body, ativo: true, criado_em: new Date().toISOString(), atualizado_em: new Date().toISOString() },
      { status: 201 },
    )
  }),

  http.put('/api/produtos/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),

  http.delete('/api/produtos/:id', () => {
    return new HttpResponse(null, { status: 204 })
  }),

  http.get('/api/categorias', () => {
    return HttpResponse.json(mockCategorias)
  }),

  http.get('/api/health', () => {
    return HttpResponse.json({ status: 'ok', version: '1.0.0' })
  }),
]
