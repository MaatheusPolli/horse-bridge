import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { loginSchema, type LoginFormData } from '../lib/validation'
import { useAuth } from '../hooks/useAuth'
import { ApiError } from '../api/client'

export default function LoginPage() {
  const { login } = useAuth()
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  async function onSubmit(data: LoginFormData) {
    setError('')
    setLoading(true)
    try {
      await login(data)
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.detail)
      } else {
        setError('Erro ao conectar com a API')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="login-page">
      <div className="card login-card">
        <h2>Horse Bridge</h2>
        <p style={{ textAlign: 'center', color: 'var(--color-text-muted)', marginBottom: '1.5rem' }}>
          Faça login para gerenciar produtos
        </p>

        {error && <div className="alert alert-error">{error}</div>}

        <form onSubmit={handleSubmit(onSubmit)}>
          <div className="form-group">
            <label htmlFor="username">Usuário</label>
            <input id="username" {...register('username')} autoFocus />
            {errors.username && <div className="form-error">{errors.username.message}</div>}
          </div>

          <div className="form-group">
            <label htmlFor="password">Senha</label>
            <input id="password" type="password" {...register('password')} />
            {errors.password && <div className="form-error">{errors.password.message}</div>}
          </div>

          <button type="submit" className="btn btn-primary" style={{ width: '100%' }} disabled={loading}>
            {loading && <span className="spinner" />}
            Entrar
          </button>
        </form>
      </div>
    </div>
  )
}
