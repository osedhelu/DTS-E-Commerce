import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '.tmp_parts'))
from tmp_data_nodes import NODES
from tmp_data_edges_a import EDGES_PART1
from tmp_data_edges_b import EDGES_PART2

OUT = "/Volumes/Datos/dts-app-ecommerce/graphify-out/.graphify_chunk_02.json"

def node_dict(t):
    nid, label, ftype, src = t
    return {
        "id": nid,
        "label": label,
        "file_type": ftype,
        "source_file": src,
        "source_location": None,
        "source_url": None,
        "captured_at": None,
        "author": None,
        "contributor": None,
    }

def edge_dict(e):
    s, t, rel, conf, score, src = e
    return {
        "source": s,
        "target": t,
        "relation": rel,
        "confidence": conf,
        "confidence_score": score,
        "source_file": src,
        "source_location": None,
        "weight": 1.0,
    }

hyperedges = [
    {
        "id": "media_storage_backend_implementations",
        "label": "Backends de almacenamiento implementan StorageBackend protocol",
        "nodes": [
            "docs_media_storage_local_backend",
            "docs_media_storage_s3_backend",
            "docs_media_storage_cloudinary_backend",
            "docs_media_storage_storage_protocol",
        ],
        "relation": "implement",
        "confidence": "EXTRACTED",
        "confidence_score": 1.0,
        "source_file": "/Volumes/Datos/dts-app-ecommerce/docs/MEDIA_STORAGE.md",
    },
    {
        "id": "fase_8_accounting_pipeline",
        "label": "Flujo contable por capas (pago → movimientos → asientos → reportes)",
        "nodes": [
            "docs_evolucion_finanzas_contabilidad_pagos_paymentmethodconfig",
            "docs_evolucion_finanzas_contabilidad_pagos_financialmovement",
            "docs_evolucion_finanzas_contabilidad_pagos_postingengine",
            "docs_evolucion_finanzas_contabilidad_pagos_accounting_ledger",
        ],
        "relation": "participate_in",
        "confidence": "EXTRACTED",
        "confidence_score": 1.0,
        "source_file": "/Volumes/Datos/dts-app-ecommerce/docs/EVOLUCION_FINANZAS_CONTABILIDAD_PAGOS.md",
    },
    {
        "id": "fase_blocks_execution_workflow",
        "label": "Workflow de ejecución por bloques Cursor + Make + PROGRESS",
        "nodes": [
            "docs_fase4_blocks_fase4_blocks",
            "docs_fase6_blocks_fase6_blocks",
            "docs_fase7_blocks_fase7_blocks",
            "docs_progress_progress_tracking",
        ],
        "relation": "form",
        "confidence": "INFERRED",
        "confidence_score": 0.85,
        "source_file": "/Volumes/Datos/dts-app-ecommerce/docs/FASE4_BLOCKS.md",
    },
]

edges = EDGES_PART1 + EDGES_PART2

node_ids = {n[0] for n in NODES}
bad = []
for e in edges:
    if e[0] not in node_ids:
        bad.append(e[0])
    if e[1] not in node_ids:
        bad.append(e[1])
for h in hyperedges:
    for n in h["nodes"]:
        if n not in node_ids:
            bad.append(n)
if bad:
    raise SystemExit("MISSING NODE REFS: " + ",".join(sorted(set(bad))))

payload = {
    "nodes": [node_dict(t) for t in NODES],
    "edges": [edge_dict(t) for t in edges],
    "hyperedges": hyperedges,
    "input_tokens": 0,
    "output_tokens": 0,
}

with open(OUT, "w", encoding="utf-8") as fh:
    json.dump(payload, fh, ensure_ascii=False, indent=2)
print("WROTE", OUT, "nodes", len(payload["nodes"]), "edges", len(payload["edges"]), "hyperedges", len(payload["hyperedges"]))