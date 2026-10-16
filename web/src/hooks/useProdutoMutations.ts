import { useMutation, useQueryClient } from '@tanstack/react-query'
import { createProduto, updateProduto, deleteProduto } from '../api/produtos'
import type { ProdutoRequest } from '../api/schema'

export function useCreateProduto() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: ProdutoRequest) => createProduto(data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['produtos'] }),
  })
}

export function useUpdateProduto(id: number) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: ProdutoRequest) => updateProduto(id, data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['produtos'] })
      qc.invalidateQueries({ queryKey: ['produto', id] })
    },
  })
}

export function useDeleteProduto() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: number) => deleteProduto(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['produtos'] }),
  })
}
