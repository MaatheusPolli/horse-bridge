import { useState } from 'react'
import { Link } from 'react-router-dom'
import type { ProdutoResponse } from '../api/schema'
import { useDeleteProduto } from '../hooks/useProdutoMutations'
import ConfirmDialog from './ConfirmDialog'
import { formatCurrency } from '../lib/format'

interface ProdutoTableProps {
  produtos: ProdutoResponse[]
  isLoggedIn: boolean
}

export default function ProdutoTable({ produtos, isLoggedIn }: ProdutoTableProps) {
  const [deleteId, setDeleteId] = useState<number | null>(null)
  const deleteMutation = useDeleteProduto()

  const produtoToDelete = produtos.find((p) => p.id === deleteId)

  function handleDelete() {
    if (!deleteId) return
    deleteMutation.mutate(deleteId, {
      onSuccess: () => setDeleteId(null),
    })
  }

  if (produtos.length === 0) {
    return <div className="empty-state">Nenhum produto encontrado.</div>
  }

  return (
    <>
      <div className="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>SKU</th>
              <th>Nome</th>
              <th>Categoria</th>
              <th>Preço</th>
              <th>Estoque</th>
              {isLoggedIn && <th>Ações</th>}
            </tr>
          </thead>
          <tbody>
            {produtos.map((p) => (
              <tr key={p.id}>
                <td><code>{p.sku}</code></td>
                <td>{p.nome}</td>
                <td>
                  {p.categoria_nome && (
                    <span className="badge badge-category">{p.categoria_nome}</span>
                  )}
                </td>
                <td className="price">{formatCurrency(p.preco)}</td>
                <td>{p.estoque}</td>
                {isLoggedIn && (
                  <td>
                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                      <Link to={`/produtos/${p.id}/editar`} className="btn btn-sm">
                        Editar
                      </Link>
                      <button
                        className="btn btn-sm btn-danger"
                        onClick={() => setDeleteId(p.id)}
                      >
                        Excluir
                      </button>
                    </div>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {deleteId !== null && produtoToDelete && (
        <ConfirmDialog
          title="Excluir produto"
          message={`Tem certeza que deseja excluir "${produtoToDelete.nome}"?`}
          onConfirm={handleDelete}
          onCancel={() => setDeleteId(null)}
          loading={deleteMutation.isPending}
        />
      )}
    </>
  )
}
