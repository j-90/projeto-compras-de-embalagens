-- REFERÊNCIA RECONSTRUÍDA. Percentuais em escala 0 a 100 neste SQL.
-- As medidas DAX usam frações 0 a 1 com formatação percentual.

-- VISÃO GERAL
SELECT COUNT(*) AS total_pedidos,
       SUM(custo_total_brl) AS custo_total_brl,
       SUM(frete_brl) AS frete_total_brl,
       ROUND(100.0*SUM(frete_brl)/NULLIF(SUM(custo_total_brl),0),2) AS participacao_frete_pct,
       ROUND(100.0*COUNT_IF(entrega_no_prazo)/NULLIF(COUNT(*),0),2) AS no_prazo_pct,
       ROUND(100.0*COUNT_IF(otif_fisico)/NULLIF(COUNT(*),0),2) AS otif_pct
FROM workspace.compras_embalagens.vw_analise_compras;

-- DESEMPENHO POR FORNECEDOR
SELECT id_fornecedor, fornecedor, COUNT(*) AS total_pedidos,
       SUM(custo_total_brl) AS custo_total_brl,
       COUNT_IF(atraso_horas > 0) AS pedidos_atrasados,
       ROUND(100.0*COUNT_IF(entrega_no_prazo)/NULLIF(COUNT(*),0),2) AS no_prazo_pct,
       ROUND(100.0*COUNT_IF(otif_fisico)/NULLIF(COUNT(*),0),2) AS otif_pct,
       ROUND(AVG(CASE WHEN atraso_horas > 0 THEN atraso_horas END),2) AS atraso_medio_horas,
       ROUND(100.0*SUM(qtd_rejeitada)/NULLIF(SUM(qtd_recebida),0),2) AS rejeicao_pct
FROM workspace.compras_embalagens.vw_analise_compras
GROUP BY id_fornecedor, fornecedor ORDER BY otif_pct;

-- CUSTO E DESEMPENHO POR MATERIAL E FORNECEDOR
SELECT id_material, material, fornecedor,
       COUNT(*) AS total_pedidos, SUM(qtd_aceita) AS quantidade_aceita,
       ROUND(SUM(valor_liquido_materiais_brl)/NULLIF(SUM(qtd_aceita),0),4) AS preco_unitario_ponderado_brl,
       ROUND(SUM(frete_brl)/NULLIF(SUM(qtd_aceita),0),4) AS frete_por_unidade_brl,
       ROUND(SUM(custo_total_brl)/NULLIF(SUM(qtd_aceita),0),4) AS custo_unitario_total_brl,
       ROUND(100.0*COUNT_IF(otif_fisico)/NULLIF(COUNT(*),0),2) AS otif_pct
FROM workspace.compras_embalagens.vw_analise_compras
GROUP BY id_material, material, id_fornecedor, fornecedor
ORDER BY id_material, custo_unitario_total_brl;

-- DESEMPENHO POR UNIDADE E MATERIAL: RECORTE DE COMPRA PROGRAMADA
SELECT unidade, fornecedor, id_material, material,
       COUNT(*) AS total_pedidos, SUM(qtd_aceita) AS pecas_aceitas,
       ROUND(SUM(valor_liquido_materiais_brl)/NULLIF(SUM(qtd_aceita),0),4) AS preco_unitario_ponderado_brl,
       ROUND(SUM(frete_brl)/NULLIF(SUM(qtd_aceita),0),4) AS frete_por_peca_brl,
       ROUND(SUM(custo_total_brl)/NULLIF(SUM(qtd_aceita),0),4) AS custo_por_peca_brl,
       ROUND(100.0*COUNT_IF(otif_fisico)/NULLIF(COUNT(*),0),2) AS otif_pct
FROM workspace.compras_embalagens.vw_analise_compras
WHERE tipo_compra = 'Programada'
GROUP BY id_unidade, unidade, id_fornecedor, fornecedor, id_material, material
ORDER BY id_material, unidade, custo_por_peca_brl;
