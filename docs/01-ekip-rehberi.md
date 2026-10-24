<!-- cspell:disable -->
# Auto-Follow Ekip Rehberi

> **Bu doküman ne?** Projede nasıl çalıştığımızı, git'e yeni başlayan birinin anlayacağı dille anlatır:
> repolar nasıl düzenlendi, kurallar neler ve neden var, günlük iş adım adım nasıl yapılır, Claude Code ile nasıl çalışılır.
>
> Son güncelleme: **2026-10-24**. En sondaki **"Durum ve değişiklik günlüğü"** bölümü, yapılan ve sırada bekleyen işleri gösterir.

> [!WARNING]
> **Çalışmaya başlamadan önce iki kural**
> 1. **Her iş, yol haritasındaki numaralı bir maddeye bağlıdır.** Yol haritası: [`agent-os/product/roadmap.md`](../agent-os/product/roadmap.md). Maddenin numarası işinin **her yerinde** görünür. Örneğin 7. madde için branch `ozellik/m07-...`, spec klasörü `<tarih>-m07-...`, PR başlığı `[M07] ...`. Ayrıntı: [9.6](#96-numaralandırma-her-iş-bir-yol-haritası-maddesine-bağlı).
> 2. **Dokümanla çalışılır.** Koda başlamadan önce o işin spec dokümanı yazılır. Aldığın kararlar, nedenleri, test sonuçları ve karşılaştığın sorunlar spec klasörüne yazılır. Dokümanı olmayan iş, tezde "yapıldı" sayılmaz.

### `docs/` klasöründeki dokümanlar
| Dosya | Ne için | Kim için |
|---|---|---|
| [`01-ekip-rehberi.md`](01-ekip-rehberi.md) | Bu rehber: kurallar, çalışma düzeni, Claude/Agent OS | Herkes (**önce bunu oku**) |
| [`02-ortak-yazilim-surumleri.md`](02-ortak-yazilim-surumleri.md) | Laptop ve Raspberry Pi'de kurulu olması gereken sabit sürümler | Herkes (kurulumda) |
| [`05-ekip-rehberi-ilk-taslak.md`](05-ekip-rehberi-ilk-taslak.md) | Bu rehberin eski taslağı (arşiv; bilgileri eski) | Sadece geçmiş için |

> `03` ve `04` numaralı dosyalar repo sorumlusunun kişisel notlarıdır; GitHub'a gönderilmez, bu yüzden repoda görmezsin.

---

## İçindekiler
1. [Önce küçük bir git sözlüğü](#1-önce-küçük-bir-git-sözlüğü)
2. [Projenin yapısı: üç repo](#2-projenin-yapısı-üç-repo)
3. [Kurulum](#3-kurulum)
4. [Altın kurallar](#4-altın-kurallar)
5. [Günlük çalışma: adım adım](#5-günlük-çalışma-adım-adım)
   - [5.1 Küçük ve sık commit](#51-küçük-ve-sık-commit)
   - [5.2 Hatalı ilerledim: nasıl geri dönerim?](#52-hatalı-ilerledim-nasıl-geri-dönerim)
6. [Otomatik kontroller (CI)](#6-otomatik-kontroller-ci)
7. [GitHub'ın seni durduracağı durumlar](#7-githubın-seni-durduracağı-durumlar)
8. ["PR'ım neden birleşmiyor?"](#8-prım-neden-birleşmiyor)
9. [Claude Code ve Agent OS ile çalışma](#9-claude-code-ve-agent-os-ile-çalışma)
10. [Örnek işler](#10-örnek-işler)
11. [Pixhawk ve Raspberry Pi'ye yükleme](#11-pixhawk-ve-raspberry-piye-yükleme)
12. [Sık karşılaşılan sorunlar](#12-sık-karşılaşılan-sorunlar)
13. [Takıldığında](#13-takıldığında)
14. [Durum ve değişiklik günlüğü](#14-durum-ve-değişiklik-günlüğü)

---

## 1. Önce küçük bir git sözlüğü

Bu kelimeler rehber boyunca geçiyor. Bilmiyorsan önce burayı oku.

| Kelime | Ne demek (sade anlatım) |
|---|---|
| **repo** (repository) | Bir projenin tüm dosyaları + bütün değişiklik geçmişi. GitHub'da bir sayfa, bilgisayarında bir klasör. |
| **klonlamak** (`git clone`) | GitHub'daki repoyu bilgisayarına indirmek. Bir kere yapılır. |
| **commit** | "Bu noktayı kaydet" demek. Oyundaki kayıt noktası gibi: istersen sonra bu ana geri dönebilirsin. Her commit'in kısa bir açıklaması olur. |
| **branch** (dal) | Ana koddan ayrılan kendi çalışma kopyan. Burada istediğin gibi deneme yaparsın; ana kod bozulmaz. |
| **`main`** | Ana branch. Herkesin kullandığı, **her zaman çalışır durumda olması gereken** ortak kod. |
| **push** (`git push`) | Bilgisayarındaki commit'leri GitHub'a göndermek. |
| **pull** (`git pull`) | GitHub'daki yenilikleri bilgisayarına çekmek. |
| **PR** (Pull Request) | "Benim branch'imdeki değişiklikleri `main`'e ekleyelim mi?" diye GitHub'da açılan istek. Arkadaşların burada kodunu görür, yorum yapar, onaylar. |
| **merge** (birleştirmek) | PR onaylanınca değişikliklerin `main`'e eklenmesi. Biz **"Squash and merge"** kullanıyoruz: PR'daki tüm commit'ler `main`'e tek bir commit olarak girer. |
| **CI** (otomatik kontroller) | Her PR'da GitHub'ın kendi kendine çalıştırdığı testler. Kodun derlenip derlenmediğine, kuralların çiğnenip çiğnenmediğine bakar. PR sayfasında yeşil ✓ veya kırmızı ✗ olarak görünür. |
| **onay** (Approve / review) | Bir arkadaşının PR'ındaki kodu okuyup "tamam" demesi. |
| **tag** (etiket) | Bir commit'e verilen kalıcı isim (ör. `tez-ucus-1`). "Uçuş testinde bu kodu kullandık" diye işaretlemek için. |
| **submodule** | Bir repo içinde duran başka bir repo. PX4 bunlardan çok kullanır; **biz onlara dokunmayız.** |

---

## 2. Projenin yapısı: üç repo

Projemiz **tek bir sistem** (drone + Pixhawk + Raspberry Pi + görüntü işleme), ama dosyalar **üç ayrı repoda** duruyor:

| Repo | İçinde ne var | Kim değiştirir |
|---|---|---|
| **Auto-Follow** (çatı repo) | Ürün planı, iki tarafı birden ilgilendiren ortak dokümanlar, Claude ayarları, kurulum scriptleri, bu rehber | Ekip PR açabilir; ürün planı ve ayarlar **repo sorumlusunun** onayıyla değişir |
| **Autopilot** | PX4 v1.17.0 (uçuş yazılımı, Pixhawk'ta çalışır), simülasyon | Herkes (PR ile) |
| **Vision** | Raspberry Pi 5'te çalışacak Python kodu: kamera, görüntü işleme, Pixhawk ile haberleşme | Herkes (PR ile) |

Bilgisayarında **herkeste aynı** şekilde durur:

```
~/Desktop/Projects/Auto-Follow/      ← ÇATI REPO
├── README.md
├── CLAUDE.md                        ← Claude'un her açılışta okuduğu kurallar
├── docs/                            ← dokümanlar (numaralı: 01-ekip-rehberi.md, 02-...)
├── kurulum.sh                       ← kurulum scripti
├── kurulum/                         ← Claude/Agent OS kurulum scriptleri
├── agent-os-profilleri/             ← Claude'un uyduğu kuralların kaynağı (repo sorumlusu düzenler)
├── agent-os/
│   ├── product/                     ← ürün planı (misyon, yol haritası, teknolojiler)
│   └── specs/                       ← iki repoyu birden ilgilendiren işlerin tarifleri (spec)
│
├── Autopilot/                       ← AYRI REPO: PX4
└── Vision/                          ← AYRI REPO: Raspberry Pi Python kodu
```

### En önemli şey: "Hangi klasördeysen, o repodasın"
`Autopilot/` ve `Vision/` çatı klasörün **içinde** duruyor ama çatı reponun **parçası değil**. Üçü ayrı repo.
`git` komutunu **hangi klasörde** çalıştırırsan **o repoya** yazar:

```bash
cd ~/Desktop/Projects/Auto-Follow            # burada git → ÇATI repo
cd ~/Desktop/Projects/Auto-Follow/Vision     # burada git → VISION repo
cd ~/Desktop/Projects/Auto-Follow/Autopilot  # burada git → AUTOPILOT repo

git rev-parse --show-toplevel                # "Şu an hangi repodayım?" sorusunun cevabı
```

> Kodu **sadece `Autopilot/` ve `Vision/`'a** yazarız. Çatı repoya kod konmaz; sadece plan, doküman ve ayar konur.

### Neden üçüncü bir repo (çatı) var?
Claude Code ile kullandığımız **Agent OS**, işlere başlamadan önce bir **ürün planı** okur (projenin amacı, yol haritası, kullanılan teknolojiler).
Planı Autopilot'a koysaydık Vision'da çalışan kişi göremezdi; ikisine de koysaydık iki kopya zamanla birbirinden farklılaşırdı.
Plan artık tek yerde, çatıda duruyor ve **iki repodan da otomatik okunuyor**. Pi ↔ Pixhawk haberleşmesi gibi **iki tarafı birden ilgilendiren** konuların tarifleri de çatıda yazılıyor, böylece aynı şeyi iki repoda iki farklı şekilde tanımlamıyoruz.

---

## 3. Kurulum

### 3.1 Hiç kurmadıysan (yeni bilgisayar)
```bash
sudo apt install -y git                                  # git yoksa kur
mkdir -p ~/Desktop/Projects && cd ~/Desktop/Projects     # klasörü oluştur ve içine gir
git clone https://github.com/Auto-Follow/Auto-Follow.git # çatı repoyu indir
cd Auto-Follow
./kurulum.sh                                             # Autopilot + Vision'ı indirir, Agent OS'u kurar
```
Sonra:
- PX4 + Gazebo kurulumu: `Autopilot/TEZ_README.md` → "Yeni ekip üyesi: kurulum sırası" (2. adımdan itibaren)
- Python ortamı: `Vision/README.md`

### 3.2 `Autopilot` ve `Vision` klasörlerin zaten varsa
`~/Desktop/Projects/Auto-Follow/` klasörün dolu olduğu için `git clone` çalışmaz. Çatı repoyu mevcut klasörüne şöyle bağlarsın:
```bash
cd ~/Desktop/Projects/Auto-Follow
git init -b main                                                       # bu klasörü bir git reposu yap
git remote add origin https://github.com/Auto-Follow/Auto-Follow.git  # GitHub adresini tanıt
git fetch origin                                                       # GitHub'daki dosyaları indir
git checkout -t origin/main                                            # dosyaları klasöre yerleştir
./kurulum.sh                                                           # Autopilot/Vision'a dokunmaz, sadece kontrol eder
```
Sonra iki repoyu da güncelle:
```bash
cd ~/Desktop/Projects/Auto-Follow/Autopilot && git switch main && git pull
cd ~/Desktop/Projects/Auto-Follow/Vision    && git switch main && git pull
```

### 3.3 Kurulum doğru mu?
```bash
cd ~/Desktop/Projects/Auto-Follow
git status              # "nothing to commit, working tree clean" demeli; Autopilot/ ve Vision/ listede GÖRÜNMEMELİ
ls ~/agent-os/profiles  # auto-follow  auto-follow-repo  default
```

---

## 4. Altın kurallar

Bu kuralların çoğunu GitHub zaten **otomatik olarak** uyguluyor; yanlışlıkla çiğneyemezsin, denersen reddedilir. Neden var olduklarını bilmek yeter.

| # | Kural | Neden |
|---|---|---|
| 1 | **PX4 sürümü v1.17.0'da sabittir.** Güncelleme yok, yeni sürüme geçiş yok. | Tez boyunca uçuş yazılımı değişmesin; bugün çalışan kod yarın da çalışsın. Otomatik kontrol ediliyor. |
| 2 | **`main`'e doğrudan yazılmaz.** Her iş kendi branch'inde yapılır, PR ile gönderilir. | Ortak kod her zaman çalışır kalsın. |
| 3 | **PR; otomatik kontrollerin hepsi yeşil olmadan ve en az bir arkadaşın onayı olmadan birleşmez.** | Bozuk kod ortak koda girmesin; her kodu en az iki kişi görsün. |
| 4 | **Asla `git submodule update --remote` çalıştırma.** Doğrusu: `git submodule update --init --recursive` | `--remote` PX4'ün parçalarını en yeni sürüme çeker ve sürüm kilidini bozar. |
| 5 | **`v` ile başlayan tag açma** (ör. `v1.0`). Bizim tag'lerimiz `tez-` ile başlar (ör. `tez-ucus-1`). | PX4 firmware sürümünü `v...` tag'lerinden okur; yanlış tag firmware'i bozar. GitHub bunu zaten engelliyor. |
| 6 | **`git` komutundan önce hangi klasörde olduğuna bak.** | Üç ayrı repo var; yanlış klasörde commit atarsan değişiklik yanlış repoya gider. |
| 7 | **Kod sadece `Autopilot/` ve `Vision/`'a yazılır.** | Çatı repo sadece plan ve ayar içindir. |
| 8 | **Vision kodu (`Vision/src/`) ve PX4 kodu asla `../` ile üst klasöre veya diğer repoya başvurmaz.** | Raspberry Pi'ye sadece Vision indirilir, çatı orada yoktur. Başvurursan kod Pi'de çöker. |
| 9 | **Hiçbir araç/kütüphane "en son sürüm" diye kurulmaz.** Sürümler sabittir: `Autopilot/tez/env/VERSIONS.md`, `Vision/requirements/`. | Herkesin bilgisayarında aynı sürüm olsun; "bende çalışıyordu" sorunu yaşanmasın. Yeni araç gerekiyorsa önce repo sorumlusuna sor. |
| 10 | **Simülatör Gazebo Harmonic'tir.** İnternetteki "Gazebo Classic" rehberleri (`gazebo-classic_...`, `.world`) bizde çalışmaz. | Ubuntu 24.04'te Gazebo Classic desteklenmiyor. |
| 11 | **Video, log (`.ulg`), veri seti, model ağırlığı repoya konmaz.** 100 MB'tan büyük dosya zaten reddedilir. | Repo şişmesin; GitHub'ın sınırı var. |
| 12 | **Uçuş/SITL testinde iki repoya aynı isimli `tez-*` tag'i atılır.** (Bkz. [10.4](#104-uçuş-veya-sitl-testi-sürümleri-işaretlemek)) | Autopilot ve Vision ayrı repolar; "bu testte hangi PX4 kodu hangi Pi koduyla çalıştı?" sorusunun cevabı kaybolmasın. |
| 13 | **Küçük ve sık commit at.** Her çalışan adım ayrı bir commit olur (Claude ile çalışırken bunu Claude kendisi yapar). | Hatalı bir yöne gidersen, en son çalışan duruma kolayca dönebilesin. (Bkz. [5.1](#51-küçük-ve-sık-commit)) |
| 14 | **Her iş numaralı bir yol haritası maddesine bağlıdır; numara branch, spec, commit ve PR adında görünür.** (Bkz. [9.6](#96-numaralandırma-her-iş-bir-yol-haritası-maddesine-bağlı)) | Kimin neyi, hangi madde için yaptığı her yerden takip edilebilsin; tez raporunda iş ↔ sonuç bağlantısı kaybolmasın. |
| 15 | **Dokümanla çalış:** önce spec, sonra kod; kararlar, nedenleri ve test sonuçları spec klasörüne yazılır. | Dokümanı olmayan iş tezde savunulamaz; arkadaşın işini devraldığında nerede kaldığını görebilsin. |
| 16 | **Emin olmadığın komutu çalıştırmadan önce sor.** Özellikle `--force`, `--remote`, `reset --hard`. | Bunlar geri alınması zor işler yapar. |

---

## 5. Günlük çalışma: adım adım

Örnek: Vision'da "kamera okuma" özelliği üzerinde çalışacaksın. (Autopilot'ta da aynısı, sadece klasör farklı.)

```bash
# 0) Doğru klasöre gir ve en güncel main'i al
cd ~/Desktop/Projects/Auto-Follow/Vision
git switch main          # main branch'ine geç
git pull                 # GitHub'daki en son hali indir

# 1) Kendi branch'ini aç
git switch -c ozellik/m09-kamera-okuma
#   branch adı kuralı:  ozellik/mNN-...  (yeni iş; NN = yol haritası madde numarası)
#                       duzeltme/mNN-... (hata düzeltme)   deney/mNN-... (deneme)

# 2) Çalış. Ara ara neyi değiştirdiğine bak:
git status               # hangi dosyalar değişti?
git diff                 # tam olarak ne değişti?

# 3) Kaydet (commit)
git add src/vision/kamera.py tests/test_kamera.py   # commit'e girecek dosyaları seç
git commit -m "kamera: Gazebo görüntüsünü okuyan fonksiyon ekle"

# 4) GitHub'a gönder
git push -u origin ozellik/kamera-okuma             # ilk seferde böyle; sonrakilerde sadece: git push
```

5. GitHub'da repo sayfasına git. Sarı bir kutuda **"Compare & pull request"** düğmesi çıkar, ona bas. Ne yaptığını kısaca yaz ve PR'ı aç.
6. Otomatik kontrollerin bitmesini bekle (Vision'da 1 dakikadan kısa, Autopilot'ta ~4 dk).
7. Hepsi yeşilse bir arkadaşından **onay (Approve)** iste.
8. Onay gelince **"Squash and merge"** düğmesine bas. Branch otomatik silinir.
9. Bilgisayarında main'e dön ve güncelle:
   ```bash
   git switch main && git pull
   ```

> **Onay verirken:** Başkasının PR'ını onaylamak "bu kodu ben de okudum, mantıklı" demektir. Okumadan onaylama. Anlamadığın yeri yorum olarak sor; soru sormak da bir katkıdır.

> **Commit'ten önce (Vision):** `.venv/bin/ruff format . && .venv/bin/ruff check . && .venv/bin/pytest -q`
> **Commit'ten önce (Autopilot):** `tez/pin/verify_pin.sh --worktree` ve değiştirdiğin şeye göre `make px4_sitl`

### 5.1 Küçük ve sık commit

Commit'i bir **kayıt noktası** gibi düşün. Ne kadar sık kayıt alırsan, bir şey bozulduğunda o kadar az iş kaybedersin.

- **Ne zaman commit?** Her küçük ama **çalışan** adımda: bir fonksiyon yazıldı ve testi geçti → commit. Bir hata düzeltildi → commit. Akşam bıraktın → o ana kadar çalışanı commit'le.
- **Ne kadar büyük?** Bir commit tek bir şeyi anlatsın. "Kamera okuma + hedef seçimi + README" yerine üç ayrı commit.
- **Mesaj:** Neyi yaptığını kısaca yaz: `kamera: Gazebo görüntüsünü okuyan fonksiyon ekle`. "düzeltme", "deneme2" gibi mesajlar sonra işe yaramaz.
- **Push:** Commit'ler önce sadece senin bilgisayarında durur. Günün sonunda (veya önemli bir adımdan sonra) `git push` ile kendi branch'ini GitHub'a gönder. Böylece bilgisayarına bir şey olsa da işin kaybolmaz. Kendi branch'ine push etmek `main`'i etkilemez.

**Claude ile çalışırken:** Claude (Agent OS komutlarıyla veya komutsuz) bunu **kendisi yapar**:
- Spec aşamalarında: `/agent-os:shape-spec`, `/agent-os:write-spec`, `/agent-os:create-tasks` bittikçe spec klasörünü commit'ler.
- Uygulamada: `/agent-os:implement-tasks` her **görev grubunu** bitirince önce kontrolleri (testler, `verify_pin`, derleme) çalıştırır, geçerse o grubu **tek bir commit** olarak kaydeder. Mesaj şöyle olur: `<spec-adı>: Görev grubu 2 — hedef vektörü hesaplama`.
- Kontroller geçmezse commit atmaz, sana hatayı söyler.
- `main`'deysen hiç başlamaz, önce branch açmanı ister.
- **Push yapmaz.** Push'u sen yaparsın.

### 5.2 Hatalı ilerledim: nasıl geri dönerim?

Önce **geçmişe bak**. Her satır bir commit (kayıt noktası), en üstteki en yenisi:
```bash
git log --oneline
#   a1b2c3d kamera-okuma: Görev grubu 3 — hedef seçimi        ← bozuk çıktı
#   9f8e7d6 kamera-okuma: Görev grubu 2 — piksel → body frame  ← burası çalışıyordu
#   5c4b3a2 kamera-okuma: Görev grubu 1 — kamera okuma
```

Sonra durumuna uyan satırı seç (en güvenliden en tehlikeliye):

| Durum | Komut | Ne olur |
|---|---|---|
| Henüz commit etmediğim değişiklikleri çöpe atmak istiyorum (tek dosya) | `git restore <dosya>` | O dosya son commit'teki hâline döner. **Kaydedilmemiş değişiklik kaybolur.** |
| Eski bir hâle sadece **bakmak** istiyorum | `git switch --detach 9f8e7d6` → bak/dene → geri dön: `git switch -` | Hiçbir şey silinmez. |
| Bir commit'in yaptığını **geri almak** istiyorum (push ettiysem de güvenli) | `git revert a1b2c3d` | O commit'i tersine çeviren **yeni bir commit** oluşur. Geçmiş silinmez. **İlk tercihin bu olsun.** |
| Son commit'i geri almak istiyorum ama değişiklikler dursun (**push etmediysem**) | `git reset --soft HEAD~1` | Commit kalkar, dosyalardaki değişikliklerin yerinde kalır. |
| Branch'imi tamamen eski bir noktaya döndürmek istiyorum (**push etmediysem**) | Önce yedek: `git branch yedek/kamera-okuma`  sonra: `git reset --hard 9f8e7d6` | O noktadan sonraki **her şey silinir** (yedek branch'te durur). Emin değilsen sor. |

> **Kurallar:** Bu komutları sadece **kendi branch'inde** kullan, `main`'de asla. Push ettiğin bir commit'i geri almak için **sadece `git revert`** kullan. `reset --hard` ve `push -f` kullanmadan önce mutlaka sor.
>
> Claude'a da söyleyebilirsin: *"Görev grubu 3'ten önceki hâle dönmek istiyorum, nasıl yaparız?"* Claude seçenekleri anlatır ama `reset --hard` gibi geri alınamayan işleri **sen onaylamadan yapmaz**.

---

## 6. Otomatik kontroller (CI)

Her PR açıldığında GitHub bu kontrolleri **kendiliğinden** çalıştırır. PR sayfasının altında yeşil ✓ veya kırmızı ✗ olarak görürsün. Kırmızıysa yanındaki **"Details"** bağlantısına tıklayıp hata mesajını okuyabilirsin.

### Autopilot
| Kontrol | Ne yapar | Kırmızı olursa |
|---|---|---|
| `verify-pin` | "PX4 hâlâ v1.17.0 mı? İzin verilmeyen bir PX4 dosyasına dokunuldu mu?" diye bakar. | Muhtemelen izin verilmeyen bir PX4 dosyasını değiştirdin veya submodule güncelledin. Değişikliği geri al; gerçekten gerekiyorsa repo sorumlusuna sor. Yerelde dene: `tez/pin/verify_pin.sh --worktree` |
| `derleme-sitl` | Kodunu temiz bir bilgisayarda **simülasyon için derler.** | Kod derlenmiyor. Hata mesajını oku, düzelt, tekrar `git push` yap (kontroller yeniden çalışır). Yerelde: `make px4_sitl` |
| `derleme-fmu-v6c` | Kodunu **Pixhawk 6C için derler.** Firmware kartın hafızasına sığmazsa da burada yakalanır. | Derleme hatası veya hafıza taşması (`region FLASH overflowed`). Yerelde: `make px4_fmu-v6c_default`. Hafıza taşmasıysa repo sorumlusuna haber ver. |

### Vision
| Kontrol | Ne yapar | Kırmızı olursa |
|---|---|---|
| `ci (3.12)` / `ci (3.13)` | Kodu iki Python sürümünde test eder ve kod stilini kontrol eder (ruff). 3.12 = laptop, 3.13 = Raspberry Pi. | Yerelde: `.venv/bin/ruff format . && .venv/bin/ruff check . && .venv/bin/pytest -q`. Hataları düzelt, tekrar push et. |

### Çatı repo (Auto-Follow)
Şimdilik otomatik kontrol yok; sadece onay gerekiyor.

---

## 7. GitHub'ın seni durduracağı durumlar

Bunlar **bilerek** böyle ayarlandı. Bir şey reddedilirse bozuk bir şey yapmadın; sadece emniyet kemeri devreye girdi.

| Denersen ne olur | Neden |
|---|---|
| `main`'e doğrudan push → **reddedilir** | Ortak kod her zaman çalışır kalsın. |
| `git push -f` (force-push) ile `main`'i değiştirmek → **reddedilir** | Geçmiş silinip başkalarının işi kaybolmasın. |
| Kontroller kırmızıyken birleştirme → **engellenir** | Bozuk kod ortak koda girmesin. |
| Onaysız birleştirme → **engellenir** | Her kodu en az iki kişi görsün. |
| Temel dosyaları değiştirmek (sürüm kilidi, CI, bağımlılıklar, ürün planı, Claude ayarları) → **repo sorumlusunun onayı gerekir** | Bunlar projenin temeli. |
| `v...` ile başlayan tag açmak → **reddedilir** | PX4 firmware sürümünü bu tag'lerden okur. |
| 100 MB'tan büyük dosya → **reddedilir** | GitHub sınırı. |

---

## 8. "PR'ım neden birleşmiyor?"

| GitHub'da gördüğün | Anlamı | Ne yap |
|---|---|---|
| "Review required" | Onay yok | Bir arkadaşından onay iste |
| "Some checks were not successful" | Otomatik kontrollerden biri kırmızı | [Bölüm 6](#6-otomatik-kontroller-ci) |
| "This branch is out-of-date with the base branch" | Sen çalışırken `main` değişti | PR sayfasında **"Update branch"** düğmesine bas; kontroller yeniden çalışır |
| "Waiting for review from code owners" | Temel dosyalara dokundun | Repo sorumlusunun onayı gerekiyor |
| "Merging is blocked" | Yukarıdakilerden biri | Sayfadaki kırmızı maddeleri tek tek çöz |

---

## 9. Claude Code ve Agent OS ile çalışma

**Claude Code**, terminalde çalışan yapay zekâ asistanıdır. **Agent OS** ise Claude'a "önce iyice planla, sonra kodla" düzenini veren bir komut setidir.
Bu düzende her iş önce bir **spec** (iş tarifi: ne yapılacak, neden, nasıl test edilecek) olarak yazılır, sonra görevlere bölünür, sonra koda dökülür.

### 9.1 Komutlar
Komutlar Claude Code'da **`/agent-os:` önekiyle** görünür. `/agent-os` yazınca liste açılır.

| Komut | Ne yapar | Sıra |
|---|---|---|
| `/agent-os:shape-spec` | Yapmak istediğin şeyi Claude'a anlatırsın, Claude sana sorular sorar | 1 |
| `/agent-os:write-spec` | Cevaplardan spec dokümanı yazar | 2 |
| `/agent-os:create-tasks` | Spec'i küçük görevlere böler (`tasks.md`) | 3 |
| `/agent-os:implement-tasks` | Görevleri koda döker | 4 |
| `/agent-os:orchestrate-tasks` | Görevleri birden fazla alt ajana dağıtarak uygular (büyük işler için) | 4 (alternatif) |
| `/agent-os:plan-product` | Ürün planını yazar. **Sadece çatıda, sadece repo sorumlusu.** | — |

> `/shape-spec` yazarsan bulamaz; doğrusu `/agent-os:shape-spec`.
> Komutlar görünmüyorsa Claude Code'u kapatıp yeniden aç.

### 9.2 Claude'u hangi klasörde açmalıyım?

| Ne yapacaksın | Claude'u nerede aç |
|---|---|
| Sadece PX4 tarafı (uçuş yazılımı, simülasyon) | `Autopilot/` |
| Sadece Pi tarafı (kamera, görüntü işleme) | `Vision/` |
| İki tarafı birden ilgilendiren iş (Pi ↔ Pixhawk mesajları, uçtan uca test senaryosu) | Çatı: `Auto-Follow/` |

```bash
cd ~/Desktop/Projects/Auto-Follow/Vision
claude
```

### 9.3 Claude neyi otomatik biliyor?
- Nerede açarsan aç, Claude **çatıdaki `CLAUDE.md`'yi okur**. Yani kuralları (sürüm kilidi, yasak komutlar, Gazebo Harmonic, sürüm sabitliği…) her seferinde bilir.
- `Autopilot/` veya `Vision/` içinde spec yazarken ürün planını **bir üst klasörden** (`../agent-os/product/`) kendisi okur. Senin bir şey yapmana gerek yok.

### 9.4 Kurulmuş güvenlik önlemleri
Bunlar denendi ve çalışıyor:
- **Ürün planı yoksa** veya çatı repo kurulu değilse spec komutları **durur** ve bunu söyler. Plansız spec yazılmaz.
- `Autopilot/` veya `Vision/` içinde `/agent-os:plan-product` **çalışmaz**, "plan çatıda" diye yönlendirir. Böylece kimse yanlışlıkla ikinci bir ürün planı oluşturamaz.
- Claude bir bileşen spec'i yazarken çatıdaki ortak spec'lere (ör. Pi ↔ Pixhawk arayüzü) bakar. Aynı arayüzü yeniden tanımlamaz, onlara referans verir.
- Henüz karar verilmemiş konularda (mesaj seti, görüntü işleme yöntemi, PX4'e eklenecek dosyaların adları ve yerleri…) Claude **tahmin etmez, sorar.**
- Claude'un yaptığı değişiklikler de **aynı kurallara** tabidir: branch → PR → kontroller → onay.
- Claude çalışırken **küçük ve sık commit** atar (her spec aşaması, her görev grubu), `main`'de çalışmaz ve push yapmaz. Ayrıntı: [5.1](#51-küçük-ve-sık-commit).

### 9.5 Ürün planı ve yol haritası
`agent-os/product/roadmap.md` (yol haritası) **sadece repo sorumlusu tarafından** güncellenir: bir işin PR'ı birleştikten sonra ilgili madde işaretlenir.
Claude işi bitirdiğinde roadmap'i kendisi değiştirmez, sadece raporunda "şu madde bitti" diye **önerir**. Böylece aynı dosyayı birkaç kişi aynı anda değiştirip çakışma yaşamaz.

### 9.6 Numaralandırma: her iş bir yol haritası maddesine bağlı

Yol haritasındaki ([`agent-os/product/roadmap.md`](../agent-os/product/roadmap.md)) her maddenin bir numarası var (1, 2, 3 … 27). Bir işe başlarken **önce hangi maddeye ait olduğunu bul.** Bu numara iki haneli yazılır (`m07`) ve işinin her yerinde görünür:

| Nerede | Biçim | Örnek (7. madde: algılama modelinin seçimi) |
|---|---|---|
| Branch | `ozellik/mNN-<kısa-ad>` | `ozellik/m07-algilama-modeli` |
| Spec klasörü | `<tarih>-mNN-<kısa-ad>` | `Vision/agent-os/specs/2026-10-25-m07-algilama-modeli/` |
| Commit | `<spec-klasörü>: ...` | `2026-10-25-m07-algilama-modeli: Görev grubu 1 — aday modellerin ölçümü` |
| PR başlığı | `[MNN] <başlık>` | `[M07] Algılama modelinin seçimi` |

- `/agent-os:shape-spec` çalıştırdığında Claude önce "bu iş yol haritasının kaçıncı maddesi?" diye sorar (açıksa kendisi bulur) ve klasör adına numarayı koyar.
- Yol haritasında olmayan küçük bir iş mi? Repo sorumlusuna sor; onaylanırsa numara `m00` olur.
- Neden? Tezde "7. maddeyi kim yaptı, hangi PR'da, hangi test sonucuyla?" sorusunun cevabı tek aramayla bulunur.

### 9.7 Dokümanla çalışmak

Bu projede **doküman, işin kendisidir.** Tez sonunda yazılacak rapor bu dokümanlardan derlenecek.
- **Önce spec, sonra kod:** `/agent-os:shape-spec` → `/agent-os:write-spec` → `/agent-os:create-tasks` → `/agent-os:implement-tasks`.
- **Kararları yaz:** "Neden bu modeli/yöntemi seçtik?" sorusunun cevabı spec klasöründe olmalı. Seçmediğin seçenekleri ve nedenlerini de yaz.
- **Sonuçları yaz:** Test ettiğin şeyin sonucunu (sayılar, log adı, `tez-*` tag'i) yaz. "Çalışıyor" yerine "şu testte şu sonucu verdi" yaz.
- **Sorunları yaz:** Takıldığın yeri ve nasıl çözdüğünü yaz. Bir sonraki kişi aynı yerde zaman kaybetmesin.
- **Kodla birlikte güncelle:** Kodu değiştirdiysen ilgili dokümanı da aynı PR'da güncelle.

---

## 10. Örnek işler

### 10.1 Sadece Pi tarafında bir özellik
Örnek: "Gazebo kamerasından görüntü okuma"
```bash
cd ~/Desktop/Projects/Auto-Follow/Vision
git switch main && git pull
git switch -c ozellik/m09-kamera-okuma      # örnek: yol haritasında ilgili madde 9 ise
claude
```
Claude içinde sırayla:
```
/agent-os:shape-spec Gazebo kamerasından görüntü okuma
/agent-os:write-spec
/agent-os:create-tasks
/agent-os:implement-tasks
```
Spec `Vision/agent-os/specs/<tarih>-m09-<isim>/` klasörüne, kod `Vision/src/` altına yazılır. Sonra [Bölüm 5](#5-günlük-çalışma-adım-adım)'teki gibi commit → push → PR.

> İpucu: Büyük bir işi tek PR'da yapma. Önce sadece spec'i PR olarak açıp arkadaşlarına göstermek iyi bir alışkanlıktır.

### 10.2 Sadece PX4 tarafında bir özellik
Aynısı, `Autopilot/` klasöründe. Ek dikkat:
- PX4'ün kendi dosyalarına dokunmak **kilit listesiyle** sınırlıdır (`Autopilot/tez/pin/allowed-paths.txt`). Listede olmayan bir dosyayı değiştirmen gerekiyorsa **önce repo sorumlusuna sor.**
- Pixhawk 6C'nin hafızası **neredeyse dolu (~%98)**. Yeni PX4 modülü eklemeden önce yer açılması planlanıyor.

### 10.3 İki tarafı birden ilgilendiren iş
Örnek: "Pi, takip edilen hedefin bilgisini Pixhawk'a hangi mesajla göndersin?"
1. **Önce çatıda ortak spec yazılır:** Claude'u `Auto-Follow/` klasöründe aç → `/agent-os:shape-spec` → `/agent-os:write-spec`. Spec `agent-os/specs/` altına yazılır ve **çatı repoda PR** olur.
2. Spec onaylanınca uygulama **iki repoda ayrı ayrı** yapılır:
   - Gönderen taraf `Vision/`'da → Vision'da PR
   - Alan taraf `Autopilot/`'ta → Autopilot'ta PR
3. PR açıklamalarında birbirine ve çatıdaki spec'e link ver.

> Kural: Ortak bir arayüz (mesaj formatı gibi) değişecekse **önce çatıdaki ortak spec değişir**, sonra kod.

### 10.4 Uçuş veya SITL testi: sürümleri işaretlemek
Her test/uçuştan önce, kullanılan kodu **iki repoda aynı isimle** işaretle:
```bash
cd ~/Desktop/Projects/Auto-Follow/Autopilot && git tag tez-ucus-1 && git push origin tez-ucus-1
cd ~/Desktop/Projects/Auto-Follow/Vision    && git tag tez-ucus-1 && git push origin tez-ucus-1
```
Aylar sonra "1. uçuşta hangi kod vardı?" diye sorulduğunda cevap `tez-ucus-1` tag'idir.

---

## 11. Pixhawk ve Raspberry Pi'ye yükleme

Çatı reponun eklenmesi bunları **hiç değiştirmedi**:

| İş | Nasıl | Not |
|---|---|---|
| Pixhawk 6C'ye firmware yüklemek | `cd Autopilot && make px4_fmu-v6c_default upload` | Derleme sadece `Autopilot/` içini görür. |
| Simülasyon | `cd Autopilot && make px4_sitl gz_x500` | |
| Raspberry Pi'ye kod kurmak | Pi'ye **sadece Vision** indirilir (`Vision/README.md`) | Pi çatı repoyu hiç görmez. Bu yüzden Kural 8 önemli. |
| GitHub kontrolleri | Her repo kendi kontrolünü çalıştırır | Kontroller sadece o repoyu görür. |

---

## 12. Sık karşılaşılan sorunlar

| Durum | Sebep | Çözüm |
|---|---|---|
| Yanlış repoya commit attım, **push etmedim** | Yanlış klasörde `git commit` | `git reset --soft HEAD~1` (commit geri alınır, değişikliklerin kaybolmaz), doğru klasöre geç |
| Yanlış repoya commit attım, **push ettim** | | Kendin düzeltmeye çalışma; repo sorumlusuna sor |
| `main`'de çalıştığımı fark ettim (henüz commit yok) | Branch açmayı unuttun | `git switch -c ozellik/<ad>`: değişikliklerin yeni branch'e taşınır |
| Çatıda `git status`'ta `Autopilot/` veya `Vision/` görünüyor | Ayar bozulmuş | Commit etme; repo sorumlusuna haber ver |
| Çatıya bir dosya koydum ama `git status`'ta görünmüyor | Çatı repo **sadece izin verilen** dosya/klasörleri kabul eder | Gerçekten gerekiyorsa repo sorumlusuna sor |
| `/shape-spec` bulunamıyor | Komutların adı `/agent-os:` önekli | `/agent-os:shape-spec` |
| Spec komutu "çatı repo kurulu değil / ürün planı yok" diyor | Çatı klonlanmamış veya plan henüz yazılmadı | [3.2](#32-autopilot-ve-vision-klasörlerin-zaten-varsa); plan yoksa repo sorumlusunu bekle |
| `verify_pin` → "yerel submodule'lar kayıtlı commit'te değil" | Submodule'ler doğru konumda değil | `git submodule update --init --recursive` (**`--remote` DEĞİL**) |
| Eski adresle (`Algan-Otopilot`) klonlamıştım, push reddediliyor | Proje taşındı; eski adresler salt okunur | `git remote set-url origin https://github.com/Auto-Follow/Autopilot.git` (Vision için `.../Vision.git`) |

PX4 kurulum/derleme sorunları için: `Autopilot/TEZ_README.md` → "Sorun giderme".

---

## 13. Takıldığında

1. Önce bu rehberdeki tablolara ve `Autopilot/TEZ_README.md` → "Sorun giderme" bölümüne bak.
2. Hata mesajını **olduğu gibi** kopyalayıp gruba yaz (ekran görüntüsü de olur). "Çalışmıyor" yerine "şu komutu çalıştırdım, şu mesajı aldım" yaz.
3. Emin olmadığın bir komutu çalıştırmadan önce sor. Soru sormak hiçbir zaman sorun değil; bozulan `main`'i düzeltmek sorun.

---

## 14. Durum ve değişiklik günlüğü

### Sırada bekleyenler
- [ ] Çatı repo `Auto-Follow/Auto-Follow`'un GitHub'da açılması (diğer repolarla aynı korumalar: PR + 1 onay, temel dosyalarda repo sorumlusu onayı)
- [ ] Autopilot PR'ı: Agent OS ayarlarının çatıya taşınması, `CLAUDE.md`, kilit listesi değişiklikleri (aşağıda)
- [ ] Vision PR'ı: Agent OS ayarlarının çatıya taşınması, `CLAUDE.md`, README güncellemesi
- [ ] Ürün planının yazılması (`/agent-os:plan-product`, çatıda, repo sorumlusu). **Bu yapılmadan spec komutları çalışmaz** (bilerek böyle).
- [ ] Pixhawk 6C'de yer açmak (kullanılmayan PX4 modüllerini kapatan özel kart ayarı); ilk PX4 modülünden önce
- [ ] Bu rehberin ekip ile birlikte gözden geçirilmesi

> Yukarıdaki ilk üç madde bitene kadar bu rehberdeki GitHub bağlantıları (`Auto-Follow/Auto-Follow`) ve [3. bölümdeki](#3-kurulum) kurulum adımları çalışmayabilir.

### 2026-10-24: Ürün planı, numaralandırma ve dokümanla çalışma
- Ürün planı yazıldı (`agent-os/product/`: misyon, 27 maddelik yol haritası, teknoloji yığını).
- Her iş yol haritasındaki madde numarasıyla anılır: branch `ozellik/mNN-...`, spec klasörü `<tarih>-mNN-...`, PR `[MNN] ...`. Claude spec açarken numarayı sorar. ([9.6](#96-numaralandırma-her-iş-bir-yol-haritası-maddesine-bağlı))
- "Dokümanla çalış" kuralı eklendi ([9.7](#97-dokümanla-çalışmak)). Rehberin başına uyarı kutusu kondu.

### 2026-10-24: Küçük ve sık commit kuralı
- Ekip hatalı ilerlediğinde önceki çalışan duruma dönebilsin diye **her anlamlı adım ayrı bir commit** olur. Altın kurallara 13. madde eklendi; anlatım: [5.1](#51-küçük-ve-sık-commit), geri dönme yolları: [5.2](#52-hatalı-ilerledim-nasıl-geri-dönerim).
- Claude bunu otomatik yapar: spec aşamaları ve her görev grubu bittikçe (kontroller geçerse) commit atar; `main`'de çalışmaz; push yapmaz.

### 2026-10-24: Dokümanlar `docs/` altında toplandı
- Dokümanlar numaralandırıldı: `01-ekip-rehberi.md` (bu rehber), `02-ortak-yazilim-surumleri.md` (eski adı `ORTAK-SURUMLER.md`), `05-ekip-rehberi-ilk-taslak.md` (eski taslak, arşiv).
- `03` ve `04` repo sorumlusunun kişisel notlarıdır ve repoya girmez.

### 2026-10-24: Çatı repo ve Agent OS düzeni
**Ne yapıldı (sade anlatım):**
- `~/Desktop/Projects/Auto-Follow/` klasörü kendi başına bir repo (**çatı repo**) oldu. Ürün planı, ortak spec'ler, Claude ayarları ve bu rehber burada.
- Claude'un uyduğu kuralların kaynağı (Agent OS **profilleri**) Autopilot'tan çatıya taşındı. İki profil var:
  - `auto-follow` → çatı için
  - `auto-follow-repo` → Autopilot ve Vision için (tek farkı: ürün planını bir üst klasörden okur)
- Her yerde Claude'un otomatik okuduğu **`CLAUDE.md`** dosyaları eklendi (çatıda ortak kurallar, her repoda kısa ek kurallar).
- Alt repolarda ürün planı yoksa spec yazılmasını durduran ve `plan-product`'ı çatıya yönlendiren **güvenlik önlemleri** eklendi ve Claude ile denendi.
- Kurulum tek komuta indirildi: `./kurulum.sh`.

**Düzeltilen bir hata: `_tez` isimleri**
- Daha önce Claude'un kurallarına, **karar verilmeden** bazı örnek isimler yazılmıştı: PX4 parametreleri `TEZ_...`, modüller `tez_...`, simülasyon dosyası `..._gz_x500_tez`. Bu isimlerde **gerçek bir dosya hiç oluşturulmadı**; sadece kurallarda geçiyorlardı.
- Ayrıca sürüm kilidi listesine, henüz var olmayan bu simülasyon dosyaları için 4 PX4 dosyasında değişiklik izni eklenmişti.
- İkisi de kaldırıldı. Bu konularda karar verilene kadar Claude artık isim önermez, sorar. Karar verilince ilgili izin ayrı ve açık bir PR ile eklenecek.

**Sürüm kilidi listesindeki değişiklikler** (`Autopilot/tez/pin/allowed-paths.txt`):
- Eklendi: `CLAUDE.md` (Claude kuralları; PX4'ün kendi dosyası değil)
- Çıkarıldı: `ROMFS/.../airframes/*_gz_x500_tez*`, `ROMFS/.../airframes/CMakeLists.txt`, `ROMFS/.../px4-rc.gzsim`, `src/modules/simulation/gz_bridge/gz_env.sh.in`

**Değişmeyenler:** PX4 sürümü, otomatik kontroller, PR/onay kuralları, Pixhawk'a ve Pi'ye yükleme.
