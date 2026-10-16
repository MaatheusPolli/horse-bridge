import { api } from './client'
import type { CategoriaResponse, LoginRequest, LoginResponse } from './schema'

export function fetchCategorias() {
  return api.get<CategoriaResponse[]>('/categorias')
}

export function login(data: LoginRequest) {
  return api.post<LoginResponse>('/auth/login', data)
}
