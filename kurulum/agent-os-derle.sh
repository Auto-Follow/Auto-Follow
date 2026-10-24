#!/usr/bin/env bash
# Profillerden (agent-os-profilleri/) uc yeri yeniden derler:
#   cati repo  -> auto-follow
#   Autopilot  -> auto-follow-repo
#   Vision     -> auto-follow-repo
# Sadece standart/profil degistiginde gerekir; derlenmis dosyalar repolarda zaten var.
# --re-install KULLANILMAZ: o agent-os/ klasorunu (specs/ ve product/ dahil) siler.
set -euo pipefail

CATI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE="$HOME/agent-os/scripts/project-update.sh"

[ -x "$UPDATE" ] || { echo "HATA: $UPDATE yok. Once kurulum/install-agent-os.sh calistirin." >&2; exit 1; }

derle() {  # $1 = klasor, $2 = profil
  [ -d "$1" ] || { echo "HATA: $1 yok. Once kurulum.sh ile repolari klonlayin." >&2; exit 1; }
  echo "== $1 ($2)"
  # Profil degisirse project-update onay sorar; specs/ ve product/ korunur.
  (cd "$1" && echo y | "$UPDATE" --profile "$2" --overwrite-all)
  if ! grep -qx "profile: $2" "$1/agent-os/config.yml"; then
    echo "HATA: $1 derlenemedi (agent-os/config.yml'de 'profile: $2' yok)." >&2; exit 1
  fi
}

derle "$CATI_ROOT"           auto-follow
derle "$CATI_ROOT/Autopilot" auto-follow-repo
derle "$CATI_ROOT/Vision"    auto-follow-repo

echo
echo "Bitti. Degisiklikleri her repoda ayri ayri kontrol edin (git status) ve PR ile gonderin."
