-- REFERÊNCIA RECONSTRUÍDA: conferências somente leitura.
SELECT COUNT(*) AS linhas, COUNT(DISTINCT id_pedido) AS pedidos_unicos,
       COUNT_IF(id_pedido IS NULL) AS ids_nulos
FROM workspace.compras_embalagens.pedidos_compras;
-- Esperado na base atual: 1080, 1080, 0.

SELECT id_fornecedor, COUNT(*) AS registros
FROM workspace.compras_embalagens.fornecedores
GROUP BY id_fornecedor HAVING COUNT(*) > 1;
SELECT id_unidade, COUNT(*) AS registros
FROM workspace.compras_embalagens.unidades
GROUP BY id_unidade HAVING COUNT(*) > 1;
SELECT id_material, COUNT(*) AS registros
FROM workspace.compras_embalagens.materiais
GROUP BY id_material HAVING COUNT(*) > 1;
-- Esperado: nenhuma linha nas três consultas de duplicidade.

SELECT COUNT(*) AS linhas_apos_join,
       COUNT(DISTINCT p.id_pedido) AS pedidos_unicos,
       COUNT_IF(f.id_fornecedor IS NULL) AS fornecedor_orfao,
       COUNT_IF(u.id_unidade IS NULL) AS unidade_orfa,
       COUNT_IF(m.id_material IS NULL) AS material_orfao
FROM workspace.compras_embalagens.pedidos_compras p
LEFT JOIN workspace.compras_embalagens.fornecedores f ON p.id_fornecedor=f.id_fornecedor
LEFT JOIN workspace.compras_embalagens.unidades u ON p.id_unidade=u.id_unidade
LEFT JOIN workspace.compras_embalagens.materiais m ON p.id_material=m.id_material;

SELECT
  COUNT_IF(qtd_pedida IS NULL OR qtd_recebida IS NULL OR qtd_rejeitada IS NULL
    OR qtd_rejeitada < 0 OR qtd_recebida < qtd_rejeitada
    OR qtd_pedida < qtd_recebida) AS quantidades_invalidas,
  COUNT_IF(data_pedido IS NULL OR data_prevista IS NULL OR data_entrega IS NULL
    OR data_prevista < data_pedido OR data_entrega < data_pedido) AS datas_invalidas,
  COUNT_IF(preco_unitario_brl IS NULL OR frete_brl IS NULL
    OR preco_unitario_brl < 0 OR frete_brl < 0) AS valores_invalidos
FROM workspace.compras_embalagens.pedidos_compras;

SELECT COUNT(*) AS linhas_view, COUNT(DISTINCT id_pedido) AS pedidos_unicos,
       SUM(custo_total_brl) AS custo_total,
       SUM(frete_brl) AS frete_total,
       COUNT_IF(entrega_no_prazo) AS pedidos_no_prazo,
       COUNT_IF(otif_fisico) AS pedidos_otif
FROM workspace.compras_embalagens.vw_analise_compras;
-- Esperado: 1080 / 1080 / 23332772.37 / 2140169.07 / 822 / 770.

SELECT id_pedido, data_prevista, data_entrega, atraso_horas,
       entrega_no_prazo, entrega_completa, otif_fisico
FROM workspace.compras_embalagens.vw_analise_compras
ORDER BY id_pedido LIMIT 10;
