# Auto-Follow — çatı repo

Lisans tezi: Holybro X500 V2 + Pixhawk 6C + Raspberry Pi 5 ile görüntü işleme tabanlı otomatik takip (auto-follow).
4 kişilik ekip; repo sorumlusu: `huseyinuygun43`. Ekiple **Türkçe** konuş.

Bu dosya, Claude bu klasörde **veya altındaki** `Autopilot/` ya da `Vision/` klasörlerinde açıldığında da okunur.

## Klasör yapısı: üç ayrı git reposu

```
~/Desktop/Projects/Auto-Follow/      ← Auto-Follow/Auto-Follow (çatı repo): ürün planı, ortak spec'ler, Agent OS profilleri
├── Autopilot/                       ← Auto-Follow/Autopilot: PX4 v1.17.0 (kilitli) + tez PX4 kodu
└── Vision/                          ← Auto-Follow/Vision: Raspberry Pi 5 Python kodu
```

- `Autopilot/` ve `Vision/` çatı reponun **içinde ama ona ait değil**: çatının `.gitignore`'u onları dışarıda tutar. Submodule değiller.
- **Kod yalnızca `Autopilot/` ve `Vision/` içine yazılır.** Çatı repoda sadece doküman, Agent OS ve kurulum scriptleri olur.
- **Her `git` komutundan önce hangi repoda olduğunu kontrol et** (`git rev-parse --show-toplevel`). Kökte `git add`/`commit` yapmak çatı repoya yazar, alt repoya değil. Emin değilsen `git -C Autopilot ...` / `git -C Vision ...` kullan.
- Bir iş birden fazla repoyu değiştiriyorsa her repoda **ayrı branch ve ayrı PR** açılır.

## Agent OS v2.1.1

Komutlar Claude Code'da `/agent-os:` önekiyle görünür: `/agent-os:plan-product`, `/agent-os:shape-spec`, `/agent-os:write-spec`, `/agent-os:create-tasks`, `/agent-os:implement-tasks`, `/agent-os:orchestrate-tasks`.

| Ne | Nerede | Kim |
|---|---|---|
| Ürün planı (mission, roadmap, tech-stack) | `agent-os/product/` (sadece çatıda) | Sadece repo sorumlusu günceller, PR merge edildikten sonra |
| Ortak spec'ler (iki repoyu birden ilgilendiren: Pi ↔ Pixhawk arayüzü, log formatı, uçtan uca SITL senaryosu) | `agent-os/specs/` (çatı) | Spec'i çatıda yazılır; görevleri ilgili alt repolarda PR olarak uygulanır |
| Bileşen spec'leri (sadece PX4 ya da sadece Pi kodu) | `Autopilot/agent-os/specs/`, `Vision/agent-os/specs/` | Herkes |

- `/agent-os:plan-product` **sadece çatıda** çalışır; alt repolarda yönlendirme mesajı verir.
- Alt repolardaki spec komutları ürün planını `../agent-os/product/` yolundan okur. Bir alt repo spec'i ortak bir arayüzü değiştirmek isterse önce çatıdaki ortak spec değişir.
- **Standart/profil değiştirmek:** derlenmiş `agent-os/standards/` veya `.claude/` dosyalarını elle düzenleme. Kaynak `agent-os-profilleri/` altındadır:
  - `auto-follow`: çatı repo + tüm standartlar ve ajan değişiklikleri
  - `auto-follow-repo`: alt repolar (`auto-follow`'dan miras alır, sadece ürün planı yolunu değiştirir)

  Değişiklikten sonra `kurulum/install-agent-os.sh && kurulum/agent-os-derle.sh`; sonuç üç repoda ayrı ayrı PR olur.
- Agent OS **v2.1.1'de sabittir**. Resmi `base-install.sh` kullanılmaz (main = v3). `project-install.sh --re-install` kullanılmaz (`agent-os/specs/` ve `product/`'ı siler).

## Değişmez kurallar

1. **PX4 v1.17.0'da kalıcı kilitli.** Güncelleme, yükseltme, upstream `pull` yok. İzin verilen PX4 yolları: `Autopilot/tez/pin/allowed-paths.txt`. Kontrol: `Autopilot/tez/pin/verify_pin.sh --worktree`.
2. **Yasak komutlar:** `git submodule update --remote` (doğrusu `git submodule update --init --recursive`), `main`'e doğrudan push, force-push, `v*` tag açmak (PX4 firmware sürümünü bu tag'lerden okur).
3. **Her değişiklik:** branch → PR → CI yeşil → en az 1 onay → squash merge. Claude'un yaptığı değişiklikler de bu yoldan geçer.
4. **Sürüm sabitliği:** hiçbir araç/paket "en son sürüm"e kaymaz. Sabit sürümler: `Autopilot/tez/env/VERSIONS.md` (Vision Python paketleri: `Vision/requirements/`). Yeni araç sabit sürümüyle oraya yazılmadan kullanılmaz. Ekip özeti `docs/02-ortak-yazilim-surumleri.md`; bir sürüm değişirse `VERSIONS.md`, `Vision/requirements/`, `docs/02-...` ve `agent-os/product/tech-stack.md` aynı PR'da güncellenir.
5. **Simülatör Gazebo Harmonic** (`gz_*` hedefleri). Gazebo Classic (`gazebo-classic_*`, `.world`) kullanılmaz.
6. **Uyumlu sürümler:** bir SITL testi veya uçuş için kullanılan Autopilot ve Vision commit'leri, **iki repoda aynı isimli** `tez-*` tag'iyle işaretlenir (ör. `tez-ucus-1`).
7. **Alt repolar çatıya çalışma zamanında bağımlı olamaz:** `Vision/src/` ve PX4 kodu `../` yoluyla çatıdaki veya diğer repodaki dosyalara başvurmaz (Raspberry Pi'ye sadece `Vision` klonlanır; CI sadece tek repoyu görür).
8. **Çatının köküne araç ayar dosyası konmaz** (`pyproject.toml`, `setup.cfg`, `pytest.ini`, `ruff.toml`, `conftest.py`, `.clang-format`, `.editorconfig`): bu araçlar ayar dosyasını üst klasörlerde de arar.
9. Video, log (`.ulg`), veri seti, model ağırlığı ve 100 MB'tan büyük dosya hiçbir repoya girmez.
10. **Küçük ve sık commit:** Ekip hatalı ilerlediğinde önceki çalışan duruma dönebilmelidir. Bir branch'te çalışırken her anlamlı adım ayrı commit olur. Bunu kullanıcı ayrıca istemese de yap:
    - Spec aşamaları: `shape-spec`, `write-spec`, `create-tasks` her biri bitince spec klasörü commit edilir (`<spec-klasor-adi>: requirements` / `: spec` / `: tasks`).
    - Uygulama: her görev grubu bitince, ilgili kontroller geçtikten sonra commit edilir (`<spec-klasor-adi>: Görev grubu <N> — <ne yapıldı>`). Agent OS kullanılmadan yapılan işlerde de aynı ölçü: her çalışan adım bir commit.
    - Önce branch kontrolü: `main`'deysen commit atma, kullanıcıya branch açmasını söyle. Dosyaları adıyla ekle (`git add -A` / `git add .` kullanma); kullanıcının işe ait olmayan değişikliklerini commit'e katma.
    - Commit atmak serbest; **push, amend, rebase, `reset --hard`, branch silme** kullanıcı istemeden yapılmaz.
11. **Her iş numaralı bir yol haritası maddesine bağlıdır ve dokümanla yürür:**
    - Numara `agent-os/product/roadmap.md`'deki madde numarasıdır, iki haneli yazılır: `m07`. Plana uymayan küçük işler kullanıcı onayıyla `m00`.
    - Branch `ozellik/m07-<ad>` · spec klasörü `<tarih>-m07-<ad>` · commit `<spec-klasor-adi>: ...` · PR başlığı `[M07] <başlık>`.
    - Kod yazmadan önce spec dokümanı olur (`/agent-os:shape-spec` → `write-spec` → `create-tasks`). Kararlar, gerekçeler, test sonuçları ve karşılaşılan sorunlar o spec klasörüne yazılır; doküman koddan geri kalmaz.
    - Kullanıcı numarasız veya spec'siz bir işe başlamak isterse önce bunu hatırlat ve hangi maddeye ait olduğunu sor.

## Henüz kesinleşmemiş konular

Ürün planı: `agent-os/product/` (misyon, 27 maddelik yol haritası, teknoloji yığını). **Kesin olan ve olmayan her şeyin listesi `agent-os/product/tech-stack.md`'dedir** ("Kesin" / "Karar bekliyor").

Kesin donanım: Raspberry Pi 5 + **Hailo AI Kit** + **Raspberry Pi Camera Module 3**; hazır (önceden eğitilmiş) insan algılama modeli kullanılır, model eğitimi kapsam dışı.

**Karar bekliyor** (kesinleşmiş gibi uygulama; ilgili yol haritası maddesinde araştırılıp gerekçesiyle karara bağlanır, emin değilsen repo sorumlusuna sor): hangi algılama modeli, Hailo yazılım yığını ve sürümleri (Pi OS Trixie uyumu doğrulanmadı), Pi ↔ Pixhawk haberleşme yöntemi ve ICD, kontrol algoritması, takip modunun PX4'e entegrasyon yaklaşımı, simülasyon kamerası ve hareketli insan hedefi, laptop'ta Hailo'suz algılama, RC, batarya, görüntü aktarımı, ROS 2 (taslak: kullanılmıyor), başarı kriterlerinin sayısal değerleri.
