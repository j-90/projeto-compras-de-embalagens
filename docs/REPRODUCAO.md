# Reprodução, validação e publicação

## Arquivos necessários

- [Base simulada em Excel](../data/Base_Compras_Embalagens_Simulada.xlsx), versão com datas e horas.
- [Relatório Power BI](../powerbi/analise-compras.pbix) para abrir o dashboard existente.
- Workspace Databricks com acesso ao catálogo, volume e capacidade de executar SQL.
- Power BI Desktop com acesso à fonte caso seja necessário atualizar.

A base e o PBIX estão incluídos no repositório. O dashboard está conectado ao Databricks; a planilha é a origem da carga nesse ambiente. Para atualizar os dados, o leitor precisa configurar uma conexão e autenticar-se em seu próprio workspace. Não inserir tokens ou senhas nos scripts ou na documentação.

## Databricks

1. Revisar [o status dos scripts](../sql/README.md).
2. Em ambiente novo, criar o schema e volume com as primeiras instruções de preparação.
3. Carregar o Excel no volume `workspace.compras_embalagens.arquivos_origem`.
4. Executar a leitura da aba Base_Compras e conferir as 1.080 linhas.
5. Criar dimensões, tabela transacional e view, nessa ordem.
6. Executar `02_validacao_compras.sql`; investigar qualquer resultado diferente do esperado antes de analisar.
7. Executar as consultas de `03_analise_compras.sql` separadamente.

Se a leitura nativa de Excel não estiver disponível, será necessário adaptar a ingestão à versão do ambiente. Uma conversão para CSV/Parquet seria uma alternativa futura, não o fluxo original documentado.

## Power BI

Para explorar o relatório existente, abrir `powerbi/analise-compras.pbix` no Power BI Desktop. Os passos abaixo orientam a reconstrução ou configuração da fonte no próprio ambiente; não é necessário recriar as páginas para visualizar o PBIX fornecido.

1. Conectar ao Databricks usando o hostname e HTTP Path do próprio ambiente.
2. Autenticar com a conta autorizada e selecionar `vw_analise_compras` em modo Import.
3. Conferir nomes, tipos, flags e quantidades no Power Query.
4. Carregar, criar a coluna diária de emissão e a tabela Calendario.
5. Marcar Calendario como tabela de datas e configurar a relação 1:* ativa, unidirecional.
6. Criar/conferir as medidas da [referência DAX](../powerbi/REFERENCIA_DAX.md).
7. Ordenar Mes Ano pela coluna numérica e conferir a sequência cronológica.
8. Montar as três páginas descritas no README ou utilizar o PBIX existente.

## Conferência funcional

| Teste | Resultado esperado |
|---|---|
| Todos os materiais/unidades/tipos, emissão em 2025 | 1.080 pedidos; custo R$ 23.332.772,37 |
| Frete sem filtros | R$ 2.140.169,07; participação 9,17% |
| Serviço sem filtros | No prazo 76,11%; OTIF 71,30% |
| Preforma PET 28 g | 360 pedidos; custo R$ 17.139.570,08 |
| Preforma + Gama | 47 pedidos; custo/peça R$ 0,3692; OTIF 44,68% |
| Vários materiais na matriz | Total de custo por peça vazio, se aplicada a proteção HASONEVALUE |
| Página de oportunidades | Um material selecionado; mesmo recorte nos dois gráficos |
| Navegação | Cada botão abre a página correspondente |
| Filtro de mês | Valores mudam segundo emissão do pedido |
| Limpeza dos filtros | Retorna aos totais de referência |

Os testes funcionais acima são roteiro de aceitação; não foram todos executados interativamente nesta revisão. A navegação pode exigir Ctrl+clique no modo de edição do Desktop.

## Validação independente em Python

Requer Python e `openpyxl`:

```bash
python -m pip install -r requirements.txt
python validar_base.py "data/Base_Compras_Embalagens_Simulada.xlsx"
```

O script lê a base sem modificá-la, aplica as regras financeiras e retorna JSON. A validação não extrai medidas DAX nem consulta o Databricks.

## Organização para o GitHub

A pasta do projeto já está organizada como raiz do repositório:

```text
README.md
.gitignore
.gitattributes
docs/
sql/
powerbi/
  analise-compras.pbix
  REFERENCIA_DAX.md
data/
  Base_Compras_Embalagens_Simulada.xlsx
assets/
  README.md                   # orientações para capturas opcionais
validar_base.py
validacao.json
requirements.txt
```

Antes de publicar, conferir se o PBIX contém apenas a base simulada e se o texto público não expõe identificadores pessoais de conexão. As credenciais do leitor não são fornecidas pelo projeto: para atualizar, ele precisa configurar sua própria fonte.

Adicionar capturas finais das páginas ao README facilita a avaliação sem abrir o Desktop. Elas são opcionais para publicar o repositório e ainda não estão incluídas. Consulte [as orientações de captura](../assets/README.md).

Ao criar o repositório no GitHub, enviar o conteúdo desta raiz, incluindo `data/`, `powerbi/`, `sql/`, `docs/`, `assets/`, `.gitignore` e `.gitattributes`. Não recriar a pasta intermediária `documentacao_compras/`. A licença de distribuição deve ser escolhida pelo autor; nenhuma licença foi atribuída automaticamente.
