import { useState, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import { setToken } from '../api/client'
import { login as apiLogin } from '../api/categorias'
import type { LoginRequest } from '../api/schema'

export function useAuth() {
  const [token, setTokenState] = useState(() => localStorage.getItem('token'))
  const navigate = useNavigate()

  const loginFn = useCallback(async (data: LoginRequest) => {
    const response = await apiLogin(data)
    setToken(response.token)
    setTokenState(response.token)
    navigate('/')
  }, [navigate])

  const logout = useCallback(() => {
    setToken(null)
    setTokenState(null)
    navigate('/login')
  }, [navigate])

  return { token, login: loginFn, logout }
}
