"""Validação independente, somente leitura. Uso: python validar_base.py caminho.xlsx"""
import sys, json, hashlib
from pathlib import Path
from decimal import Decimal, ROUND_HALF_UP
from collections import Counter
import openpyxl

p = Path(sys.argv[1])
w = openpyxl.load_workbook(p, read_only=True, data_only=True)
it = iter(w['Base_Compras'].values)
rows = [dict(zip(next_header, r)) for next_header in [next(it)] for r in it if r[0]]
def dec(v): return Decimal(str(v))
def metrics(rs):
    freight = sum((dec(r['frete_brl']).quantize(Decimal('.01')) for r in rs), Decimal(0))
    net = sum(((dec(r['qtd_recebida'])-dec(r['qtd_rejeitada'])) * dec(r['preco_unitario_brl']).quantize(Decimal('.0001'))).quantize(Decimal('.01'), rounding=ROUND_HALF_UP) for r in rs)
    ontime = sum(r['data_entrega'] <= r['data_prevista'] for r in rs)
    otif = sum(r['data_entrega'] <= r['data_prevista'] and r['qtd_recebida']==r['qtd_pedida'] for r in rs)
    accepted = sum(r['qtd_recebida']-r['qtd_rejeitada'] for r in rs)
    delays = [(r['data_entrega']-r['data_prevista']).total_seconds()/3600 for r in rs if r['data_entrega']>r['data_prevista']]
    return dict(pedidos=len(rs), custo_total=str(net+freight), frete_total=str(freight), valor_liquido=str(net), pecas_aceitas=accepted, no_prazo=ontime, otif=otif, no_prazo_pct=100*ontime/len(rs), otif_pct=100*otif/len(rs), frete_pct=float(100*freight/(net+freight)), atraso_medio_horas=sum(delays)/len(delays) if delays else 0, custo_peca=str((net+freight)/accepted))
checks = {
    'id_duplicado': len(rows)-len({r['id_pedido'] for r in rows}),
    'campos_nulos': sum(v is None for r in rows for v in r.values()),
    'quantidades_invalidas': sum(not(0 <= r['qtd_rejeitada'] <= r['qtd_recebida'] <= r['qtd_pedida']) for r in rows),
    'datas_invalidas': sum(r['data_prevista']<r['data_pedido'] or r['data_entrega']<r['data_pedido'] for r in rows),
    'valores_negativos': sum(r['frete_brl']<0 or r['preco_unitario_brl']<0 for r in rows)
}
out = {'arquivo':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'validacoes':checks,'geral':metrics(rows),'materiais':{k:metrics([r for r in rows if r['id_material']==k]) for k in sorted({r['id_material'] for r in rows})},'fornecedores':{k:metrics([r for r in rows if r['id_fornecedor']==k]) for k in sorted({r['id_fornecedor'] for r in rows})},'preforma_por_fornecedor':{k:metrics([r for r in rows if r['id_fornecedor']==k and r['id_material']=='M01']) for k in sorted({r['id_fornecedor'] for r in rows})}}
print(json.dumps(out,ensure_ascii=False,indent=2))
assert not any(checks.values()), checks
