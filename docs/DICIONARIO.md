# Dicionário de dados

Tipos abaixo descrevem o contrato pretendido da camada tratada. Tipos inferidos na leitura bruta do Excel podem diferir. Todos os campos da base local conferida estão preenchidos; isso não equivale a uma restrição `NOT NULL` no banco.

| Campo de origem | Tipo tratado | Significado / regra |
|---|---|---|
| id_pedido | STRING | Identificador único do pedido |
| data_pedido | TIMESTAMP_NTZ | Data e hora da emissão |
| data_prevista | TIMESTAMP_NTZ | Limite previsto de entrega, incluindo hora |
| data_entrega | TIMESTAMP_NTZ | Recebimento consolidado |
| id_unidade | STRING | Chave da unidade |
| unidade | STRING | Nome da unidade simulada |
| uf_unidade | STRING | UF da unidade |
| id_fornecedor | STRING | Chave do fornecedor |
| fornecedor | STRING | Nome fictício |
| id_material | STRING | Chave do material |
| material | STRING | Descrição e especificação |
| categoria | STRING | PET, Tampas ou Rótulos |
| unidade_medida | STRING | UN; uma peça, não milheiro |
| qtd_pedida | BIGINT | Peças contratadas |
| qtd_recebida | BIGINT | Peças fisicamente recebidas |
| qtd_rejeitada | BIGINT | Peças recebidas e rejeitadas |
| preco_unitario_brl | DECIMAL(12,4) | Preço de uma peça em reais |
| frete_brl | DECIMAL(14,2) | Frete total do pedido em reais |
| prazo_pagamento_dias | Inteiro | Prazo comercial em dias; não monetizado |
| tipo_compra | STRING | Programada ou Emergencial |

## Campos acrescentados pela view

| Campo | Tipo lógico | Fórmula / finalidade |
|---|---|---|
| qtd_aceita | Inteiro | Recebida − rejeitada |
| valor_liquido_materiais_brl | DECIMAL(18,2) | Aceita × preço; centavos por pedido |
| custo_total_brl | Decimal | Valor líquido + frete |
| atraso_horas | Decimal | Diferença positiva entre entrega e previsão, em horas |
| entrega_no_prazo | Booleano | Entrega ≤ previsão |
| entrega_completa | Booleano | Recebida = pedida |
| otif_fisico | Booleano | No prazo e completa |

## Campos acrescentados no Power BI

| Campo | Tipo | Finalidade |
|---|---|---|
| Data Pedido | Data | Chave diária para Calendario |
| Fornecedor Curto | Texto | Remove prefixo e indicação de fictício para rótulos |
| Calendario[Date] | Data | Data contínua do calendário |
| Ano | Inteiro | Agrupamento anual |
| Mes Numero | Inteiro | Ordenação de mês |
| Mes | Texto | Nome abreviado do mês |
| Ano Mes | Texto | Ano-mês, quando utilizado |
| Mes Ano | Texto | Rótulo como jan/2025 |
| Ordem Mes Ano | Inteiro | Ano × 100 + mês |

## Domínios

Materiais: M01 = Preforma PET 28 g; M02 = Tampa plástica 28 mm; M03 = Rótulo BOPP 200 × 100 mm.

Fornecedores: F01 = Alfa; F02 = Beta; F03 = Gama; F04 = Delta; F05 = Épsilon.

Unidades: U01 = Recife/PE; U02 = Fortaleza/CE; U03 = Manaus/AM. Todas simuladas.

Restrições de qualidade esperadas: IDs preenchidos e únicos na entidade correspondente; `0 ≤ rejeitada ≤ recebida ≤ pedida`; valores não negativos; previsão e entrega não anteriores à emissão; referências existentes nas dimensões.
