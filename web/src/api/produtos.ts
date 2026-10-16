import { api } from './client'
import type { ProdutoResponse, ProdutoRequest, PaginatedResponse } from './schema'

export interface ProdutoParams {
  page?: number
  size?: number
  q?: string
  categoria?: string
}

export function fetchProdutos(params: ProdutoParams = {}) {
  const searchParams = new URLSearchParams()
  if (params.page) searchParams.set('page', String(params.page))
  if (params.size) searchParams.set('size', String(params.size))
  if (params.q) searchParams.set('q', params.q)
  if (params.categoria) searchParams.set('categoria', params.categoria)

  const qs = searchParams.toString()
  return api.get<PaginatedResponse<ProdutoResponse>>(`/produtos${qs ? `?${qs}` : ''}`)
}

export function fetchProduto(id: number) {
  return api.get<ProdutoResponse>(`/produtos/${id}`)
}

export function createProduto(data: ProdutoRequest) {
  return api.post<ProdutoResponse>('/produtos', data)
}

export function updateProduto(id: number, data: ProdutoRequest) {
  return api.put<void>(`/produtos/${id}`, data)
}

export function deleteProduto(id: number) {
  return api.delete<void>(`/produtos/${id}`)
}
