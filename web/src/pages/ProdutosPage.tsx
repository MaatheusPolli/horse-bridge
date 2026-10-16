import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useProdutos } from '../hooks/useProdutos'
import { useAuth } from '../hooks/useAuth'
import ProdutoTable from '../components/ProdutoTable'
import SearchBar from '../components/SearchBar'
import Pagination from '../components/Pagination'

export default function ProdutosPage() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const { token, logout } = useAuth()

  const { data, isLoading, error } = useProdutos({
    page,
    size: 20,
    q: search || undefined,
  })

  function handleSearch(q: string) {
    setSearch(q)
    setPage(1)
  }

  return (
    <>
      <header className="header">
        <div className="header-inner">
          <h1>Horse Bridge</h1>
          <div className="header-actions">
            {token ? (
              <>
                <Link to="/produtos/novo" className="btn btn-primary">
                  + Novo Produto
                </Link>
                <button className="btn" onClick={logout}>
                  Sair
                </button>
              </>
            ) : (
              <Link to="/login" className="btn btn-primary">
                Entrar
              </Link>
            )}
          </div>
        </div>
      </header>

      <main className="container">
        <SearchBar value={search} onChange={handleSearch} />

        <div className="card">
          {isLoading ? (
            <div className="empty-state">
              <span className="spinner" /> Carregando...
            </div>
          ) : error ? (
            <div className="alert alert-error">Erro ao carregar produtos.</div>
          ) : data ? (
            <>
              <ProdutoTable produtos={data.data} isLoggedIn={!!token} />
              <Pagination
                page={page}
                totalPages={data.meta.total_pages}
                onPageChange={setPage}
              />
            </>
          ) : null}
        </div>
      </main>
    </>
  )
}
