#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.24.5"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"
FLUTTER_ROOT="/opt/flutter"
FLUTTER_DIR="${FLUTTER_ROOT}/flutter"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Este script precisa de privilégios de root (use sudo)." >&2
  exit 1
fi

echo "[1/6] Atualizando índice APT..."
apt-get update

echo "[2/6] Instalando dependências base..."
apt-get install -y curl git unzip xz-utils zip libglu1-mesa

echo "[3/6] Instalando toolchain Linux para Flutter..."
apt-get install -y libgtk-3-dev clang cmake ninja-build pkg-config

echo "[4/6] Instalando Chromium para Flutter Web..."
apt-get install -y chromium-browser || apt-get install -y chromium
if [[ ! -e /usr/bin/google-chrome ]]; then
  ln -s /usr/bin/chromium-browser /usr/bin/google-chrome || true
fi

echo "[5/6] Instalando Flutter SDK ${FLUTTER_VERSION}..."
mkdir -p "${FLUTTER_ROOT}"
if [[ ! -x "${FLUTTER_DIR}/bin/flutter" ]]; then
  cd "${FLUTTER_ROOT}"
  curl -L "${FLUTTER_URL}" -o flutter.tar.xz
  tar xf flutter.tar.xz
  rm -f flutter.tar.xz
fi

git config --global --add safe.directory "${FLUTTER_DIR}" || true
"${FLUTTER_DIR}/bin/flutter" --version

echo "[6/6] Verificação final com flutter doctor..."
"${FLUTTER_DIR}/bin/flutter" doctor -v

echo "Concluído."
echo "Dica: adicione ao PATH -> export PATH=/opt/flutter/flutter/bin:\$PATH"
