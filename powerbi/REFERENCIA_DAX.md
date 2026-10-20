# Referência de DAX

Fórmulas reconstruídas a partir do desenvolvimento acompanhado. Não são uma exportação das expressões atuais do PBIX. Criar cada objeto separadamente; adaptar o nome da tabela caso difira no modelo. As medidas podem ficar na tabela organizacional `Medidas`.

## Medidas

```dax
Total Pedidos = COUNTROWS('vw_analise_compras')

Pecas Aceitas = SUM('vw_analise_compras'[qtd_aceita])

Valor Liquido Materiais = SUM('vw_analise_compras'[valor_liquido_materiais_brl])

Custo Total = SUM('vw_analise_compras'[custo_total_brl])

Frete Total = SUM('vw_analise_compras'[frete_brl])

Participacao Frete = DIVIDE([Frete Total], [Custo Total])

Entregas no Prazo % =
DIVIDE(
    CALCULATE([Total Pedidos],
        KEEPFILTERS('vw_analise_compras'[entrega_no_prazo] = TRUE())),
    [Total Pedidos]
)

OTIF % =
DIVIDE(
    CALCULATE([Total Pedidos],
        KEEPFILTERS('vw_analise_compras'[otif_fisico] = TRUE())),
    [Total Pedidos]
)

Preco por Peca =
IF(HASONEVALUE('vw_analise_compras'[id_material]),
    DIVIDE([Valor Liquido Materiais], [Pecas Aceitas]))

Frete por Peca =
IF(HASONEVALUE('vw_analise_compras'[id_material]),
    DIVIDE([Frete Total], [Pecas Aceitas]))

Custo por Peca =
IF(HASONEVALUE('vw_analise_compras'[id_material]),
    DIVIDE([Custo Total], [Pecas Aceitas]))
```

Formatar as razões como percentual; não multiplicar por 100 e também aplicar formato percentual. Moeda por peça: quatro casas. Valores totais: duas casas. Contagens: zero casas. Conferir precisão das medidas no modelo, especialmente se houver conversões de decimal fixo ou `ROUND` adicionais.

## Colunas na tabela analítica

```dax
Data Pedido =
DATE(YEAR('vw_analise_compras'[data_pedido]),
     MONTH('vw_analise_compras'[data_pedido]),
     DAY('vw_analise_compras'[data_pedido]))

Fornecedor Curto =
TRIM(SUBSTITUTE(SUBSTITUTE('vw_analise_compras'[fornecedor],
    "Fornecedor ", ""), " (fictício)", ""))
```

Definir `Data Pedido` como Data.

## Tabela calendário

```dax
Calendario =
ADDCOLUMNS(
    CALENDAR(DATE(2025,1,1), DATE(2025,12,31)),
    "Ano", YEAR([Date]),
    "Mes Numero", MONTH([Date]),
    "Mes", FORMAT([Date], "mmm", "pt-BR"),
    "Ano Mes", FORMAT([Date], "yyyy-MM"),
    "Mes Ano", FORMAT([Date], "mmm/yyyy", "pt-BR"),
    "Ordem Mes Ano", YEAR([Date])*100 + MONTH([Date])
)
```

Marcar como tabela de datas usando `[Date]`, definir tipo Data e ordenar `Mes Ano` por `Ordem Mes Ano`. Relacionar `Calendario[Date]` (1) com `[Data Pedido]` (*), filtro simples e relação ativa.

## Nota sugerida para OTIF

> OTIF físico: percentual de pedidos recebidos no prazo e com a quantidade pedida integral. Rejeições de qualidade são acompanhadas separadamente. Período baseado na emissão do pedido.
