#!/usr/bin/env bash
# Auto-Follow calisma alanini hazirlar (tekrar calistirmak guvenlidir):
#   1) Autopilot ve Vision repolarini bu klasorun icine klonlar (yoksa)
#   2) Agent OS v2.1.1'i ~/agent-os'a kurar ve tez profillerini baglar
# PX4/Gazebo bagimliliklari ve Vision Python ortami icin: Autopilot/TEZ_README.md ve Vision/README.md
set -euo pipefail

CATI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORG="https://github.com/Auto-Follow"

klonla() {  # $1 = repo adi, $2... = ek git clone secenekleri
  local ad=$1; shift
  local hedef="$CATI_ROOT/$ad"
  if [ -d "$hedef/.git" ]; then
    local url; url=$(git -C "$hedef" remote get-url origin)
    case "$url" in
      "$ORG/$ad.git"|"$ORG/$ad"|"git@github.com:Auto-Follow/$ad.git") echo "$ad zaten klonlu: $hedef" ;;
      *) echo "HATA: $hedef baska bir adrese bagli ($url). Beklenen: $ORG/$ad.git" >&2; exit 1 ;;
    esac
  elif [ -e "$hedef" ]; then
    echo "HATA: $hedef var ama git reposu degil. Tasiyip tekrar deneyin." >&2; exit 1
  else
    git clone "$@" "$ORG/$ad.git" "$hedef"
  fi
}

command -v git >/dev/null || { echo "HATA: git kurulu degil (sudo apt install -y git)" >&2; exit 1; }

klonla Autopilot --recurse-submodules
klonla Vision
"$CATI_ROOT/kurulum/install-agent-os.sh"

echo
echo "Hazir. Siradaki adimlar:"
echo "  - PX4 + Gazebo kurulumu: Autopilot/TEZ_README.md ('Yeni ekip uyesi: kurulum sirasi', 2. adimdan itibaren)"
echo "  - Vision Python ortami: Vision/README.md"
