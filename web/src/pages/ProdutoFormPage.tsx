import { useState } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import { useProduto } from '../hooks/useProdutos'
import { useCreateProduto, useUpdateProduto } from '../hooks/useProdutoMutations'
import ProdutoForm from '../components/ProdutoForm'
import { ApiError } from '../api/client'
import type { ProdutoFormData } from '../lib/validation'

export default function ProdutoFormPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const isEditing = !!id
  const produtoId = id ? Number(id) : undefined

  const { data: produto, isLoading } = useProduto(produtoId)
  const createMutation = useCreateProduto()
  const updateMutation = useUpdateProduto(produtoId ?? 0)

  const [serverErrors, setServerErrors] = useState<string[]>([])

  const mutation = isEditing ? updateMutation : createMutation

  async function handleSubmit(data: ProdutoFormData) {
    setServerErrors([])
    try {
      await mutation.mutateAsync(data)
      navigate('/')
    } catch (err) {
      if (err instanceof ApiError) {
        setServerErrors(err.errors.length > 0 ? err.errors : [err.detail])
      } else {
        setServerErrors(['Erro inesperado'])
      }
    }
  }

  if (isEditing && isLoading) {
    return (
      <div className="container" style={{ paddingTop: '2rem' }}>
        <div className="empty-state">
          <span className="spinner" /> Carregando...
        </div>
      </div>
    )
  }

  return (
    <>
      <header className="header">
        <div className="header-inner">
          <h1>
            <Link to="/" style={{ textDecoration: 'none', color: 'inherit' }}>
              Horse Bridge
            </Link>
          </h1>
        </div>
      </header>

      <main className="container">
        <div className="card" style={{ maxWidth: '640px' }}>
          <h2 style={{ marginBottom: '1.5rem' }}>
            {isEditing ? 'Editar Produto' : 'Novo Produto'}
          </h2>

          <ProdutoForm
            defaultValues={produto}
            onSubmit={handleSubmit}
            isPending={mutation.isPending}
            serverErrors={serverErrors}
          />

          <div style={{ marginTop: '1rem' }}>
            <Link to="/" className="btn">
              Voltar
            </Link>
          </div>
        </div>
      </main>
    </>
  )
}
