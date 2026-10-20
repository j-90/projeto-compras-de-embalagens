# SQL do projeto

Scripts reconstruídos a partir das consultas desenvolvidas durante o projeto, conforme solicitado pelo autor. Mantêm a organização utilizada no Databricks. Não são uma exportação direta do workspace e não foram executados contra o serviço nesta revisão.

1. `01_preparacao_compras.sql`: referência de carga inicial e view.
2. `02_validacao_compras.sql`: conferências somente leitura.
3. `03_analise_compras.sql`: análises somente leitura.

Executar instruções individualmente e conferir os resultados. A preparação é para ambiente novo: `CREATE TABLE` falhará se as tabelas já existirem. Isso evita substituir tabelas existentes inadvertidamente. A view utiliza `CREATE OR REPLACE`; revisar antes de executar sobre a implementação atual. A leitura nativa de Excel precisa estar disponível no ambiente escolhido.

Não executar todo o arquivo de preparação para simplesmente abrir ou atualizar o relatório. A fonte usada é a aba `Base_Compras`, intervalo `A1:T1081`; ampliar o intervalo se houver mais linhas.
