import { z } from 'zod'

export const produtoSchema = z.object({
  sku: z
    .string()
    .min(3, 'SKU deve ter pelo menos 3 caracteres')
    .max(20, 'SKU deve ter no máximo 20 caracteres')
    .regex(/^[A-Z0-9-]+$/, 'SKU: apenas letras maiúsculas, números e hífen'),
  ean: z
    .string()
    .optional()
    .refine((v) => !v || /^\d{13}$/.test(v), 'EAN deve ter 13 dígitos'),
  nome: z.string().min(1, 'Nome é obrigatório'),
  descricao: z.string().optional(),
  preco: z.coerce.number().min(0, 'Preço deve ser maior ou igual a zero'),
  estoque: z.coerce.number().int().min(0, 'Estoque deve ser maior ou igual a zero'),
  categoria_id: z.coerce.number().optional(),
})

export type ProdutoFormData = z.infer<typeof produtoSchema>

export const loginSchema = z.object({
  username: z.string().min(1, 'Usuário é obrigatório'),
  password: z.string().min(1, 'Senha é obrigatória'),
})

export type LoginFormData = z.infer<typeof loginSchema>
