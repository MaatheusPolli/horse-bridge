import { useState, useEffect } from 'react'

interface SearchBarProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
}

export default function SearchBar({ value, onChange, placeholder = 'Buscar por nome, SKU ou EAN...' }: SearchBarProps) {
  const [local, setLocal] = useState(value)

  useEffect(() => {
    setLocal(value)
  }, [value])

  useEffect(() => {
    const timer = setTimeout(() => {
      if (local !== value) onChange(local)
    }, 400)
    return () => clearTimeout(timer)
  }, [local, value, onChange])

  return (
    <div className="search-bar">
      <input
        type="text"
        value={local}
        onChange={(e) => setLocal(e.target.value)}
        placeholder={placeholder}
      />
    </div>
  )
}
