import { useQuery } from '@tanstack/react-query'
import { fetchProdutos, fetchProduto, type ProdutoParams } from '../api/produtos'
import { fetchCategorias } from '../api/categorias'

export function useProdutos(params: ProdutoParams = {}) {
  return useQuery({
    queryKey: ['produtos', params],
    queryFn: () => fetchProdutos(params),
  })
}

export function useProduto(id: number | undefined) {
  return useQuery({
    queryKey: ['produto', id],
    queryFn: () => fetchProduto(id!),
    enabled: !!id,
  })
}

export function useCategorias() {
  return useQuery({
    queryKey: ['categorias'],
    queryFn: fetchCategorias,
    staleTime: 60_000,
  })
}
