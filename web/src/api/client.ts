const API_BASE = import.meta.env.VITE_API_URL ?? '/api'

export class ApiError extends Error {
  constructor(
    public status: number,
    public title: string,
    public detail: string,
    public errors: string[] = [],
  ) {
    super(detail)
    this.name = 'ApiError'
  }
}

function getToken(): string | null {
  return localStorage.getItem('token')
}

export function setToken(token: string | null) {
  if (token) {
    localStorage.setItem('token', token)
  } else {
    localStorage.removeItem('token')
  }
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const token = getToken()
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...((options.headers as Record<string, string>) ?? {}),
  }

  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  })

  if (!res.ok) {
    if (res.status === 401) {
      setToken(null)
    }

    let body: { title?: string; detail?: string; errors?: string[] } = {}
    try {
      body = await res.json()
    } catch {
      // resposta sem corpo
    }

    throw new ApiError(
      res.status,
      body.title ?? 'Erro',
      body.detail ?? `Erro ${res.status}`,
      body.errors ?? [],
    )
  }

  if (res.status === 204) {
    return undefined as T
  }

  return res.json()
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, data: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(data) }),
  put: <T>(path: string, data: unknown) =>
    request<T>(path, { method: 'PUT', body: JSON.stringify(data) }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
}
