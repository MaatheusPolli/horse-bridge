import { Routes, Route, Navigate } from 'react-router-dom'
import { useAuth } from './hooks/useAuth'
import LoginPage from './pages/LoginPage'
import ProdutosPage from './pages/ProdutosPage'
import ProdutoFormPage from './pages/ProdutoFormPage'

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  return <>{children}</>
}

export default function App() {
  return (
    <div className="app">
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<ProdutosPage />} />
        <Route
          path="/produtos/novo"
          element={
            <ProtectedRoute>
              <ProdutoFormPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/produtos/:id/editar"
          element={
            <ProtectedRoute>
              <ProdutoFormPage />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </div>
  )
}
