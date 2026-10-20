# Evidências, proveniência e limites da conferência

Conferência inicial realizada em 24/09/2026, sem alterar o PBIX, a planilha ou objetos do Databricks naquela etapa. A revisão local para publicação em 20/10/2026 está registrada abaixo.

| Item | Evidência | Status |
|---|---|---|
| Base de dados | Leitura da aba Base_Compras do Excel original e comparação após a revisão para publicação | Dados preservados; apenas a instrução de conexão na aba Leia_me foi atualizada |
| Indicadores gerais | Recálculo independente em Python/Decimal | Conferidos; resultados em validacao.json |
| Páginas do PBIX | Leitura de Report/Layout dentro do arquivo | Três páginas, todas 1920 × 1080 |
| Consultas salvas | Página inicial autenticada do Databricks | Nomes confirmados: 01_preparacao_compras, 02_validacao_compras, 03_analise_compras |
| Schema e volume | Recursos exibidos na página inicial | compras_embalagens e arquivos_origem confirmados |
| Conteúdo SQL salvo atual | Navegação automatizada bloqueada pelo Databricks | Não exportado nem conferido integralmente nesta revisão |
| Arquivo SQL local existente | Leitura binária/textual | Continha bytes nulos; não serviu como fonte SQL |
| Fórmulas DAX exatas do modelo | DataModel do PBIX não extraído | Referência reconstruída do desenvolvimento; requer conferência no Power BI |
| Interações, atualização e navegação do relatório | Capturas fornecidas e metadados | Sem teste interativo completo nesta revisão |

O site exibiu a mensagem de que o console não suporta controle automatizado e indicou Genie One MCP. Não havia conector Databricks disponível nesta sessão. A verificação não tentou contornar esse bloqueio.

## Validação independente

Arquivo de origem: Base_Compras_Embalagens_Simulada.xlsx.

SHA-256 da versão original, anterior ao ajuste da aba Leia_me: `b4c459545aaa76abbf03b0fb350f1bb5818b8f50acde8b6f988aac72fb7ff839`.

SHA-256 da versão preparada para publicação em `data/`, após o ajuste da instrução de conexão: `369d9ce95f89a74e9011e8157102edc2b1bd82a700b2fb6d585458169d3f7b0f`. Este é o hash registrado em [validacao.json](../validacao.json).

Resultado: zero IDs duplicados, zero campos nulos entre as linhas lidas, zero inconsistências na ordem das quantidades, zero datas anteriores à emissão e zero preços/fretes negativos. A validação verifica a base disponível, não impõe restrições futuras no Databricks.

O script usa Decimal e arredondamento comercial a centavos por pedido. Isso evita diferenças de centavos decorrentes de ponto flutuante ou de arredondar apenas o total final.

## Revisão para publicação em 20/10/2026

- Documentação, scripts e arquivos finais organizados na raiz, com a base em `data/` e o dashboard em `powerbi/`.
- Referências aos documentos removidos pelo autor excluídas do README e do guia de reprodução.
- Instrução de `Leia_me!B10` atualizada para o fluxo Excel → Databricks (SQL) → Power BI, usando a view `vw_analise_compras`.
- Comparação entre a versão original e a revisada confirmou uma única célula com valor alterado, sem mudanças na aba Base_Compras, na formatação das células ou nos nomes e intervalos das tabelas.
- Validação Python executada novamente: mesmos indicadores e zero inconsistências nos cinco controles existentes.
- PBIX e scripts SQL/DAX preservados. Esta revisão local não executou consultas no Databricks nem testou a atualização do relatório.
- Capturas finais ainda não incluídas; as orientações estão em [assets/README.md](../assets/README.md).

## Para fechar a rastreabilidade

1. Exportar manualmente as três consultas SQL salvas no Databricks.
2. Confrontar com os scripts de referência deste pacote e substituir pela versão exportada quando pertinente.
3. Conferir medidas, tipos e relacionamento no Power BI; exportar definições se desejado.
4. Testar filtros, seleção de material, navegação e atualização com credenciais próprias.
5. Inserir capturas finais das três páginas no repositório.

Este documento registra a situação da revisão. Não declara auditoria completa do workspace nem execução bem-sucedida dos scripts reconstruídos.
