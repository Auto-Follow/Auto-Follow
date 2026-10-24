#!/usr/bin/env bash
# Agent OS'u SABIT v2.1.1 surumuyle ~/agent-os'a kurar.
# NOT: Resmi base-install.sh dosyalari 'main' branch'inden indirir (main = v3) - KULLANMAYIN.
set -euo pipefail

AOS_TAG="v2.1.1"
AOS_COMMIT="6a6495111e9f7f9cdab3c172814a7476e83a8ec9"
AOS_DIR="$HOME/agent-os"

CATI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILLER="$CATI_ROOT/agent-os-profilleri"

if [ -d "$AOS_DIR" ]; then
  have=$(git -C "$AOS_DIR" rev-parse HEAD 2>/dev/null || echo "git-degil")
  if [ "$have" != "$AOS_COMMIT" ]; then
    echo "HATA: $AOS_DIR var ama ${AOS_TAG} degil ($have). Once yedekleyip kaldirin." >&2; exit 1
  fi
  echo "Agent OS ${AOS_TAG} zaten kurulu: $AOS_DIR"
else
  git -c advice.detachedHead=false clone -q --depth 1 --branch "$AOS_TAG" \
    https://github.com/buildermethods/agent-os.git "$AOS_DIR"
  have=$(git -C "$AOS_DIR" rev-parse HEAD)
  if [ "$have" != "$AOS_COMMIT" ]; then
    echo "HATA: indirilen commit ($have) beklenen ${AOS_TAG} commit'i degil. Kaldiriliyor." >&2
    rm -rf "$AOS_DIR"; exit 1
  fi
  git -C "$AOS_DIR" remote set-url --push origin no_push
  echo "Agent OS ${AOS_TAG} kuruldu: $AOS_DIR ($AOS_COMMIT)"
fi

# Tez profilleri cati repoda tutulur; ~/agent-os'a sembolik baglanti olarak eklenir
# (Agent OS'un orijinal dosyalari degismez).
#   auto-follow      -> cati repo (urun plani + ortak spec'ler)
#   auto-follow-repo -> Autopilot ve Vision (urun planini ../agent-os/product/'tan okur)
for profil in auto-follow auto-follow-repo; do
  ln -sfn "$PROFILLER/$profil" "$AOS_DIR/profiles/$profil"
  echo "Profil baglandi: $AOS_DIR/profiles/$profil -> $PROFILLER/$profil"
done
