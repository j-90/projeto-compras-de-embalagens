# Documentação de negócio

## Objetivo e público

Apoiar a avaliação de compras de embalagens com uma visão conjunta de custos e serviço. O público são analistas de compras, compradores e gestores interessados em priorizar negociações e investigar desempenho de fornecedores.

O projeto demonstra capacidade de transformar uma pergunta de negócio em regras mensuráveis, preparar dados em SQL, construir medidas e comunicar resultados. A base é sintética: não é uma amostra real de mercado e não mede o desempenho da Solar Coca-Cola.

## Contexto e premissas

- Materiais: preforma PET 28 g, tampa plástica 28 mm e rótulo BOPP 200 × 100 mm.
- Fornecedores fictícios: Alfa, Beta, Gama, Delta e Épsilon.
- Unidades simuladas: Recife, Fortaleza e Manaus. Os nomes não afirmam correspondência com operações reais.
- Tipos de compra: Programada e Emergencial.
- 360 pedidos por material; 1.080 no total.
- Cada pedido possui um material e um recebimento consolidado. Não há modelagem de entregas parciais sucessivas.
- Pedidos encerrados: saldo não recebido cancelado; peças rejeitadas integralmente creditadas; frete não estornado.
- Todos os horários seguem a convenção de Brasília no conjunto simulado, inclusive Manaus. Os campos não armazenam fuso horário.
- Os perfis de preço, frete e desempenho foram construídos na simulação. As relações observadas não constituem evidência externa de causalidade.

## Contrato dos indicadores

| Indicador | Regra | Interpretação |
|---|---|---|
| Total de pedidos | Contagem de linhas, após validar unicidade de `id_pedido` | Volume de transações |
| Quantidade aceita | Recebida − rejeitada | Peças utilizáveis |
| Valor líquido de materiais | Quantidade aceita × preço unitário, arredondado a centavos por pedido | Valor dos materiais após créditos de rejeição |
| Custo total | Valor líquido de materiais + frete | Custo considerado no estudo; não é TCO completo |
| Participação do frete | Soma do frete / soma do custo total | Peso logístico no gasto |
| Preço por peça aceita | Soma do valor líquido / soma da quantidade aceita | Razão ponderada pelo volume aceito |
| Frete por peça aceita | Soma do frete / soma da quantidade aceita | Distribuição do frete sobre peças aproveitáveis |
| Custo por peça aceita | Soma do custo total / soma da quantidade aceita | Base comparável dentro de um material |
| Entregas no prazo | Pedidos com entrega ≤ previsão / total de pedidos | Considera data e hora |
| Entrega completa | Quantidade recebida = quantidade pedida | Critério físico de quantidade |
| OTIF físico | Pedidos simultaneamente no prazo e completos / total de pedidos | On Time In Full |
| Atraso médio | Média das horas positivas de atraso | Somente pedidos atrasados |
| Rejeição | Soma da quantidade rejeitada / soma da recebida | Taxa ponderada por peças |

**OTIF não inclui qualidade nesta implementação.** Um pedido entregue integralmente e no prazo pode conter peças rejeitadas e ainda ser OTIF físico. Qualidade é acompanhada separadamente. Se o contrato de negócio exigir quantidade aceita, a regra deve ser redefinida e os resultados recalculados.

Percentuais de serviço contam pedidos, não peças. Uma média simples dos percentuais dos fornecedores seria incorreta quando as quantidades de pedidos diferem. O Power BI deve recalcular numerador e denominador no contexto de cada filtro.

## Resultados gerais

| Medida | Resultado |
|---|---:|
| Pedidos | 1.080 |
| Peças aceitas | 133.922.677 |
| Custo total | R$ 23.332.772,37 |
| Frete | R$ 2.140.169,07 |
| Participação do frete | 9,17% |
| No prazo | 76,11% |
| OTIF físico | 71,30% |
| Atraso médio entre atrasados | 82,10 horas |

Foram identificados 258 pedidos atrasados. A diferença entre os 822 pedidos no prazo e os 770 OTIF representa 52 pedidos pontuais que não cumpriram a quantidade física integral.

## Exemplo de decisão: preforma PET 28 g

Recorte: todas as unidades, todos os tipos de compra, emissão em 2025.

| Fornecedor | Pedidos | Preço/peça | Frete/peça | Custo/peça | OTIF |
|---|---:|---:|---:|---:|---:|
| Gama | 47 | R$ 0,3390 | R$ 0,0303 | R$ 0,3692 | 44,68% |
| Beta | 87 | R$ 0,3550 | R$ 0,0194 | R$ 0,3744 | 79,31% |
| Delta | 115 | R$ 0,3609 | R$ 0,0182 | R$ 0,3790 | 79,13% |
| Épsilon | 51 | R$ 0,3682 | R$ 0,0289 | R$ 0,3971 | 80,39% |
| Alfa | 60 | R$ 0,3255 | R$ 0,0767 | R$ 0,4022 | 66,67% |

Valores exibidos arredondados: a soma dos componentes visíveis pode diferir na última casa do custo calculado com precisão integral.

### Hipóteses sustentadas pelo recorte

**Frete pode inverter a vantagem de preço.** Alfa tem o menor preço do material e o maior custo final por peça. A análise sugere investigar condições de frete, consolidação de entregas e negociação comercial.

**Menor custo não implica melhor nível de serviço.** Gama é o mais barato, mas possui o menor OTIF. Beta custa aproximadamente 1,4% a mais por peça e apresenta cerca de 34,6 pontos percentuais a mais de OTIF nesse recorte. Isso justifica aprofundar a comparação, não transferir automaticamente volumes.

**As diferenças dependem do material.** Beta lidera o OTIF em rótulos; Delta apresenta o maior OTIF em tampas na visão histórica disponível. Um ranking global não substitui a análise por material, unidade, período e modalidade de compra.

## Uso das três páginas

1. Visão geral: identificar magnitude do gasto e comportamento de serviço.
2. Custos e fornecedores: conferir valores e diferenças dentro de cada material.
3. Oportunidades de compras: explorar o efeito do frete e o compromisso entre custo e OTIF. Na dispersão, a região superior esquerda combina menor custo e maior OTIF.

## O que uma decisão real exigiria

Antes de recomendar mudança de fornecedor: verificar capacidade disponível, especificação e homologação do material, qualidade, prazos de pagamento, distância, frequência de entrega, volume negociado e condições contratuais. A base contém prazo de pagamento, mas não converte esse prazo em custo financeiro.

Não se deve multiplicar uma diferença histórica de preço pelo volume total e chamar o resultado de economia garantida. Seria uma simulação sujeita a premissas de preço, capacidade e volume, ainda não implementada.

## Evoluções possíveis — fora do escopo atual

Comparação de compra emergencial versus programada com controle de material/unidade; qualidade junto ao OTIF; análise financeira dos prazos; metas acordadas de serviço; histórico de cotações; recebimentos parciais; cenários de alocação de volume com restrições. Nenhuma dessas evoluções deve ser anunciada como funcionalidade entregue.
