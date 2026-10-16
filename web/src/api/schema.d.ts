export interface ProdutoResponse {
  id: number
  sku: string
  ean: string
  nome: string
  descricao: string
  preco: number
  estoque: number
  categoria_id: number
  categoria_nome: string
  ativo: boolean
  criado_em: string
  atualizado_em: string
}

export interface ProdutoRequest {
  sku: string
  ean?: string
  nome: string
  descricao?: string
  preco: number
  estoque: number
  categoria_id?: number
}

export interface CategoriaResponse {
  id: number
  nome: string
  ativo: boolean
}

export interface CategoriaRequest {
  nome: string
}

export interface PaginatedResponse<T> {
  data: T[]
  meta: {
    page: number
    size: number
    total: number
    total_pages: number
  }
}

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  expires_in: number
  token_type: string
}

export interface ProblemDetail {
  type: string
  title: string
  status: number
  detail: string
  errors: string[]
}
