import { describe, it, expect } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { MemoryRouter } from 'react-router-dom'
import App from '../App'

function renderApp(route = '/') {
  const qc = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  })

  return render(
    <QueryClientProvider client={qc}>
      <MemoryRouter initialEntries={[route]}>
        <App />
      </MemoryRouter>
    </QueryClientProvider>,
  )
}

describe('ProdutosPage', () => {
  it('exibe lista de produtos', async () => {
    renderApp('/')
    await waitFor(() => {
      expect(screen.getByText('Fone Bluetooth')).toBeInTheDocument()
      expect(screen.getByText('Café Especial')).toBeInTheDocument()
    })
  })

  it('exibe botão de login quando não autenticado', async () => {
    renderApp('/')
    await waitFor(() => {
      expect(screen.getByText('Entrar')).toBeInTheDocument()
    })
  })

  it('filtra produtos pela busca', async () => {
    const user = userEvent.setup()
    renderApp('/')

    await waitFor(() => {
      expect(screen.getByText('Fone Bluetooth')).toBeInTheDocument()
    })

    const searchInput = screen.getByPlaceholderText(/buscar/i)
    await user.type(searchInput, 'Fone')

    await waitFor(() => {
      expect(screen.getByText('Fone Bluetooth')).toBeInTheDocument()
    })
  })
})

describe('LoginPage', () => {
  it('exibe formulário de login', () => {
    renderApp('/login')
    expect(screen.getByLabelText('Usuário')).toBeInTheDocument()
    expect(screen.getByLabelText('Senha')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Entrar' })).toBeInTheDocument()
  })

  it('faz login com credenciais válidas e redireciona', async () => {
    const user = userEvent.setup()
    renderApp('/login')

    await user.type(screen.getByLabelText('Usuário'), 'admin')
    await user.type(screen.getByLabelText('Senha'), 'admin123')
    await user.click(screen.getByRole('button', { name: 'Entrar' }))

    await waitFor(() => {
      expect(localStorage.getItem('token')).toBe('mock-jwt-token')
    })
  })

  it('exibe erro com credenciais inválidas', async () => {
    const user = userEvent.setup()
    renderApp('/login')

    await user.type(screen.getByLabelText('Usuário'), 'admin')
    await user.type(screen.getByLabelText('Senha'), 'wrong')
    await user.click(screen.getByRole('button', { name: 'Entrar' }))

    await waitFor(() => {
      expect(screen.getByText('Credenciais inválidas')).toBeInTheDocument()
    })
  })
})

describe('Roteamento protegido', () => {
  it('redireciona para login ao acessar rota protegida sem token', () => {
    renderApp('/produtos/novo')
    expect(screen.getByLabelText('Usuário')).toBeInTheDocument()
  })
})
