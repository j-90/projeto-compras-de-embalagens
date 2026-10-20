-- REFERÊNCIA RECONSTRUÍDA. Carga inicial para ambiente novo.
-- Não executado no Databricks durante a revisão documental.
CREATE SCHEMA IF NOT EXISTS workspace.compras_embalagens;
CREATE VOLUME IF NOT EXISTS workspace.compras_embalagens.arquivos_origem;

-- Antes desta instrução, carregar manualmente o Excel no volume.
CREATE TABLE workspace.compras_embalagens.compras_brutas
USING DELTA AS
SELECT * FROM read_files(
  '/Volumes/workspace/compras_embalagens/arquivos_origem/Base_Compras_Embalagens_Simulada.xlsx',
  format => 'excel',
  headerRows => 1,
  dataAddress => 'Base_Compras!A1:T1081',
  schemaEvolutionMode => 'none'
);

CREATE TABLE workspace.compras_embalagens.fornecedores USING DELTA AS
SELECT DISTINCT id_fornecedor, fornecedor
FROM workspace.compras_embalagens.compras_brutas;

CREATE TABLE workspace.compras_embalagens.unidades USING DELTA AS
SELECT DISTINCT id_unidade, unidade, uf_unidade
FROM workspace.compras_embalagens.compras_brutas;

CREATE TABLE workspace.compras_embalagens.materiais USING DELTA AS
SELECT DISTINCT id_material, material, categoria, unidade_medida
FROM workspace.compras_embalagens.compras_brutas;

CREATE TABLE workspace.compras_embalagens.pedidos_compras USING DELTA AS
SELECT id_pedido, data_pedido, data_prevista, data_entrega,
       id_fornecedor, id_unidade, id_material,
       qtd_pedida, qtd_recebida, qtd_rejeitada,
       CAST(preco_unitario_brl AS DECIMAL(12,4)) AS preco_unitario_brl,
       CAST(frete_brl AS DECIMAL(14,2)) AS frete_brl,
       prazo_pagamento_dias, tipo_compra
FROM workspace.compras_embalagens.compras_brutas;

CREATE OR REPLACE VIEW workspace.compras_embalagens.vw_analise_compras AS
WITH valores AS (
  SELECT p.*,
    qtd_recebida - qtd_rejeitada AS qtd_aceita,
    CAST(ROUND((qtd_recebida - qtd_rejeitada) * preco_unitario_brl, 2)
      AS DECIMAL(18,2)) AS valor_liquido_materiais_brl
  FROM workspace.compras_embalagens.pedidos_compras p
)
SELECT p.*, f.fornecedor, u.unidade, u.uf_unidade,
       m.material, m.categoria, m.unidade_medida,
       p.valor_liquido_materiais_brl + p.frete_brl AS custo_total_brl,
       GREATEST(TIMESTAMPDIFF(SECOND,p.data_prevista,p.data_entrega),0)
         / 3600.0 AS atraso_horas,
       p.data_entrega <= p.data_prevista AS entrega_no_prazo,
       p.qtd_recebida = p.qtd_pedida AS entrega_completa,
       (p.data_entrega <= p.data_prevista AND p.qtd_recebida = p.qtd_pedida)
         AS otif_fisico
FROM valores p
LEFT JOIN workspace.compras_embalagens.fornecedores f
  ON p.id_fornecedor = f.id_fornecedor
LEFT JOIN workspace.compras_embalagens.unidades u
  ON p.id_unidade = u.id_unidade
LEFT JOIN workspace.compras_embalagens.materiais m
  ON p.id_material = m.id_material;
