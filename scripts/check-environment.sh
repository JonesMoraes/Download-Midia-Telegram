#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="/opt/flutter/flutter/bin/flutter"

ok() { echo "[OK] $*"; }
warn() { echo "[WARN] $*"; }
err() { echo "[ERRO] $*"; }

if [[ -x "${FLUTTER_BIN}" ]]; then
  ok "Flutter instalado em ${FLUTTER_BIN}"
  "${FLUTTER_BIN}" --version | head -n 1
else
  err "Flutter não encontrado em ${FLUTTER_BIN}"
  exit 1
fi

for cmd in clang cmake ninja pkg-config; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd disponível"
  else
    err "$cmd ausente"
    exit 1
  fi
done

if command -v google-chrome >/dev/null 2>&1 || command -v chromium-browser >/dev/null 2>&1; then
  ok "Browser para Flutter Web disponível"
else
  warn "Browser para Flutter Web não encontrado"
fi

"${FLUTTER_BIN}" doctor -v || true
ok "Verificação concluída"
