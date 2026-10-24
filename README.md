# Auto-Follow

Lisans tezi: **Holybro X500 V2 + Pixhawk 6C + Raspberry Pi 5** ile görüntü işleme tabanlı otomatik takip (auto-follow).

Bu repo projenin **çatısıdır**: ürün planı, iki tarafı ilgilendiren ortak spec'ler ve Agent OS ayarları burada durur. Kod iki ayrı repodadır:

| Repo | İçerik |
|---|---|
| [`Auto-Follow/Auto-Follow`](https://github.com/Auto-Follow/Auto-Follow) (bu repo) | Ürün planı, ortak spec'ler (Pi ↔ Pixhawk arayüzü vb.), Agent OS profilleri, kurulum |
| [`Auto-Follow/Autopilot`](https://github.com/Auto-Follow/Autopilot) | PX4 v1.17.0 (kilitli) + tez PX4 kodu |
| [`Auto-Follow/Vision`](https://github.com/Auto-Follow/Vision) | Raspberry Pi 5 Python kodu (görüntü işleme, Pixhawk iletişimi) |

> **Nasıl çalıştığımızın anlatımı (önce bunu okuyun):** [`docs/01-ekip-rehberi.md`](docs/01-ekip-rehberi.md)
>
> Sabit yazılım sürümleri: [`docs/02-ortak-yazilim-surumleri.md`](docs/02-ortak-yazilim-surumleri.md)
>
> Ürün planı ve **yol haritası (işler buradan seçilir)**: [`agent-os/product/`](agent-os/product/) · [`roadmap.md`](agent-os/product/roadmap.md)

## Klasör yapısı (herkeste aynı)

```
~/Desktop/Projects/Auto-Follow/   ← bu repo
├── Autopilot/                    ← ayrı repo (bu reponun .gitignore'unda)
└── Vision/                       ← ayrı repo (bu reponun .gitignore'unda)
```

Üç klasör üç ayrı git reposudur. `git` komutunu hangi klasörde çalıştırırsan o repoya yazar.

## Kurulum

### Sıfırdan
```bash
mkdir -p ~/Desktop/Projects && cd ~/Desktop/Projects
git clone https://github.com/Auto-Follow/Auto-Follow.git
cd Auto-Follow
./kurulum.sh          # Autopilot + Vision'ı klonlar, Agent OS v2.1.1'i kurar
```
Sonra: PX4 + Gazebo için `Autopilot/TEZ_README.md`, Python ortamı için `Vision/README.md`.

### Zaten `~/Desktop/Projects/Auto-Follow/{Autopilot,Vision}` klasörün varsa
Klasör boş olmadığı için `git clone` çalışmaz; çatı repoyu mevcut klasöre bağla:
```bash
cd ~/Desktop/Projects/Auto-Follow
git init -b main
git remote add origin https://github.com/Auto-Follow/Auto-Follow.git
git fetch origin
git checkout -t origin/main
./kurulum.sh          # mevcut klonlara dokunmaz, sadece adreslerini kontrol eder
```

## Agent OS ile çalışma

Komutlar Claude Code'da `/agent-os:` önekiyle görünür (ör. `/agent-os:shape-spec`).

| Nerede çalıştırılır | Ne için |
|---|---|
| Bu klasör (çatı) | `/agent-os:plan-product` (sadece repo sorumlusu) ve iki repoyu birden ilgilendiren ortak spec'ler |
| `Autopilot/` veya `Vision/` | O bileşene ait spec'ler ve kod. Ürün planını `../agent-os/product/`'tan okurlar. |

Ayrıntılı kurallar: [`CLAUDE.md`](CLAUDE.md).

**Standart değiştirmek:** `agent-os-profilleri/` altını düzenle, sonra
```bash
kurulum/install-agent-os.sh && kurulum/agent-os-derle.sh
```
ve üç repoda ayrı ayrı PR aç.
