import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { produtoSchema, type ProdutoFormData } from '../lib/validation'
import { useCategorias } from '../hooks/useProdutos'
import type { ProdutoResponse } from '../api/schema'

interface ProdutoFormProps {
  defaultValues?: ProdutoResponse
  onSubmit: (data: ProdutoFormData) => void
  isPending: boolean
  serverErrors?: string[]
}

export default function ProdutoForm({ defaultValues, onSubmit, isPending, serverErrors }: ProdutoFormProps) {
  const { data: categorias } = useCategorias()

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ProdutoFormData>({
    resolver: zodResolver(produtoSchema),
    defaultValues: defaultValues
      ? {
          sku: defaultValues.sku,
          ean: defaultValues.ean || '',
          nome: defaultValues.nome,
          descricao: defaultValues.descricao || '',
          preco: defaultValues.preco,
          estoque: defaultValues.estoque,
          categoria_id: defaultValues.categoria_id || undefined,
        }
      : {
          sku: '',
          ean: '',
          nome: '',
          descricao: '',
          preco: 0,
          estoque: 0,
        },
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {serverErrors && serverErrors.length > 0 && (
        <div className="alert alert-error">
          <ul style={{ paddingLeft: '1rem' }}>
            {serverErrors.map((err, i) => (
              <li key={i}>{err}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="sku">SKU</label>
          <input id="sku" {...register('sku')} placeholder="ELEC-001" />
          {errors.sku && <div className="form-error">{errors.sku.message}</div>}
        </div>

        <div className="form-group">
          <label htmlFor="ean">EAN-13 (opcional)</label>
          <input id="ean" {...register('ean')} placeholder="7891234567890" />
          {errors.ean && <div className="form-error">{errors.ean.message}</div>}
        </div>
      </div>

      <div className="form-group">
        <label htmlFor="nome">Nome</label>
        <input id="nome" {...register('nome')} />
        {errors.nome && <div className="form-error">{errors.nome.message}</div>}
      </div>

      <div className="form-group">
        <label htmlFor="descricao">Descrição</label>
        <textarea id="descricao" rows={3} {...register('descricao')} />
      </div>

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="preco">Preço (R$)</label>
          <input id="preco" type="number" step="0.01" {...register('preco')} />
          {errors.preco && <div className="form-error">{errors.preco.message}</div>}
        </div>

        <div className="form-group">
          <label htmlFor="estoque">Estoque</label>
          <input id="estoque" type="number" {...register('estoque')} />
          {errors.estoque && <div className="form-error">{errors.estoque.message}</div>}
        </div>
      </div>

      <div className="form-group">
        <label htmlFor="categoria_id">Categoria</label>
        <select id="categoria_id" {...register('categoria_id')}>
          <option value="">Selecione...</option>
          {categorias?.map((cat) => (
            <option key={cat.id} value={cat.id}>
              {cat.nome}
            </option>
          ))}
        </select>
      </div>

      <div className="form-actions">
        <button type="submit" className="btn btn-primary" disabled={isPending}>
          {isPending && <span className="spinner" />}
          {defaultValues ? 'Salvar alterações' : 'Criar produto'}
        </button>
      </div>
    </form>
  )
}
