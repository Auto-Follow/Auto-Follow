# Auto-Follow Ekip Rehberi

> **ARŞİV — bu taslak artık kullanılmıyor.** Güncel rehber: [`01-ekip-rehberi.md`](01-ekip-rehberi.md). Bu dosya sadece geçmiş için duruyor; içindeki bazı bilgiler (komut adları, CI süreleri, Agent OS yeri) eski.
>
> (Eski not: Hüseyin onayladıktan sonra paylaşılacak ve PDF'e çevrilip sabitlenecek.)
> Son güncelleme: 2026-09-27

Bu rehber, projede **neyin neden kilitli olduğunu** ve **günlük olarak nasıl çalışacağımızı** anlatır.
Kısacası: kimse yanlışlıkla ortak kodu bozamasın diye GitHub'da otomatik korumalar var. Bu korumalar sana engel değil, emniyet kemeri.

---

## 1. Repolar ve klasör yapısı

| Repo | Ne var | Link |
|---|---|---|
| **Autopilot** | PX4 v1.17.0 (uçuş yazılımı), tez PX4 modülleri, simülasyon | https://github.com/Auto-Follow/Autopilot |
| **Vision** | Raspberry Pi 5'te çalışacak Python kodu (görüntü işleme, Pixhawk iletişimi) | https://github.com/Auto-Follow/Vision |

Bilgisayarında klasörler **herkeste aynı** olmalı:
```
~/Desktop/Projects/Auto-Follow/
├── Autopilot/
└── Vision/
```
Kurulum adımları: Autopilot içindeki `TEZ_README.md` ("Yeni ekip üyesi: kurulum sırası") ve Vision içindeki `README.md`.

---

## 2. Beş altın kural

1. **PX4 sürümü v1.17.0'da sabittir.** Güncelleme yok, v1.18'e geçiş yok. Bunu otomatik kontrol eden bir sistem var.
2. **`main` branch'ine doğrudan yazılmaz.** Her iş kendi branch'inde yapılır, PR (Pull Request) ile gönderilir.
3. **PR, otomatik kontrollerin hepsi yeşil olmadan ve bir arkadaşın onayı olmadan birleşmez.**
4. **Asla `git submodule update --remote` çalıştırma.** Doğrusu: `git submodule update --init --recursive`
5. **`v` ile başlayan tag açma** (ör. `v1.0`). Kendi tag'lerin `tez-` ile başlar (ör. `tez-ucus-testi-1`).

---

## 3. Günlük çalışma akışı (adım adım)

```bash
# 0) Güncel main'i çek
cd ~/Desktop/Projects/Auto-Follow/Autopilot      # veya Vision
git switch main
git pull

# 1) Kendi branch'ini aç (isim: ozellik/..., duzeltme/..., deney/...)
git switch -c ozellik/kamera-okuma

# 2) Çalış, sık sık commit et
git add <dosyalar>
git commit -m "kamera: Gazebo görüntüsünü okuyan fonksiyon"

# 3) GitHub'a gönder
git push -u origin ozellik/kamera-okuma
```
4) GitHub'da çıkan **"Compare & pull request"** düğmesine bas, ne yaptığını kısaca yaz, PR'ı aç.
5) Otomatik kontrollerin bitmesini bekle (Autopilot'ta ~6 dk, Vision'da ~1 dk).
6) Hepsi yeşilse bir arkadaşından **onay (Approve)** iste.
7) Onay gelince **"Squash and merge"** ile birleştir. Branch otomatik silinir.

> Kural: Başkasının PR'ını onaylarken gerçekten oku. Onay = "bu kodu ben de kontrol ettim" demektir.

---

## 4. Otomatik kontroller (CI) — ne kontrol ediyor, kırmızı olursa ne yapmalı?

Her PR açıldığında GitHub bu kontrolleri **kendiliğinden** çalıştırır. PR sayfasının altında yeşil ✓ veya kırmızı ✗ olarak görürsün.

### Autopilot reposu

| Kontrol | Ne yapar (sade anlatım) | Kırmızı olursa |
|---|---|---|
| `verify-pin` | "PX4 hâlâ v1.17.0 mı? İzin verilmeyen bir PX4 dosyasına dokunuldu mu?" diye bakar. | Büyük ihtimalle izin verilmeyen bir PX4 dosyasını değiştirdin veya submodule güncelledin. Değişikliği geri al; gerçekten gerekiyorsa Hüseyin'e danış. Yerelde kontrol: `tez/pin/verify_pin.sh --worktree` |
| `derleme-sitl` | Kodunu temiz bir bilgisayarda **simülasyon için derler.** | Kod derlenmiyor. PR sayfasında "Details"a tıkla, hata mesajını oku, düzelt, tekrar push et. Yerelde dene: `make px4_sitl` |
| `derleme-fmu-v6c` | Kodunu **Pixhawk 6C için derler.** Firmware kartın hafızasına sığmıyorsa da burada yakalanır. | Ya derleme hatası ya da hafıza taşması. Yerelde dene: `make px4_fmu-v6c_default` |

### Vision reposu

| Kontrol | Ne yapar | Kırmızı olursa |
|---|---|---|
| `ci (3.12)` / `ci (3.13)` | Kodu iki Python sürümünde test eder, kod stilini kontrol eder (ruff). 3.12 = laptop (Ubuntu 24.04), 3.13 = Raspberry Pi (Raspberry Pi OS Trixie). | Yerelde çalıştır: `.venv/bin/ruff format . && .venv/bin/ruff check . && .venv/bin/pytest -q` — hataları düzelt, tekrar push et. |

---

## 5. Yapamayacağın şeyler (ve neden)

| Denersen ne olur | Neden |
|---|---|
| `main`'e doğrudan push → **reddedilir** | Ortak kod her zaman çalışır halde kalsın diye. |
| Force-push (`git push -f`) `main`'e → **reddedilir** | Geçmişi silip başkalarının işini kaybettirmesin diye. |
| Kontroller kırmızıyken birleştirme → **engellenir** | Bozuk kod ortak koda girmesin diye. |
| Onaysız birleştirme → **engellenir** | Her kodu en az iki kişi görsün diye. |
| Sürüm kilidi / CI / bağımlılık dosyalarını değiştirme → **Hüseyin'in onayı gerekir** | Bunlar projenin temeli. |
| `v...` tag açma → **reddedilir** | PX4, firmware sürümünü bu tag'lerden okur; yanlış tag firmware'i bozar. |
| 100 MB'tan büyük dosya → **reddedilir** | GitHub sınırı. Video, log, veri seti repoya konmaz. |

---

## 6. "PR'ım neden birleşmiyor?" — hızlı çözüm tablosu

| GitHub'da gördüğün | Anlamı | Ne yap |
|---|---|---|
| "Review required" | Onay yok | Bir arkadaşından onay iste |
| "Some checks were not successful" | Kontrollerden biri kırmızı | Bölüm 4'e bak |
| "This branch is out-of-date with the base branch" | Sen çalışırken `main` değişti | PR sayfasında **"Update branch"** düğmesine bas, kontroller yeniden çalışır |
| "Waiting for review from code owners" | Temel dosyalara dokundun | Hüseyin'in onayı gerekiyor |
| "Merging is blocked" | Yukarıdakilerden biri | Sayfadaki kırmızı maddeleri tek tek çöz |

---

## 7. Eski adresler

Proje eskiden `Algan-Otopilot` adındaydı. **Eski adresler artık çalışmaz** (salt okunur, push reddedilir).
Eski adresle klonladıysan düzelt:
```bash
git remote set-url origin https://github.com/Auto-Follow/Autopilot.git   # Vision için .../Vision.git
```

---

## 8. Claude Code + Agent OS ile çalışma

- Repolarda **Agent OS v2.1.1** kurulu. Claude Code'u repo klasöründe açınca `/shape-spec`, `/write-spec`, `/create-tasks`, `/implement-tasks` komutları görünür.
- Görevler önce **spec** olarak yazılır (`agent-os/specs/`), sonra koda dökülür.
- `agent-os/product/roadmap.md` dosyasını **sadece Hüseyin** günceller.
- Claude'a da aynı kurallar geçerli: Claude'un yaptığı değişiklik de PR ve kontrollerden geçmek zorunda.

---

## 9. Bilinmesi gereken teknik not

- **Pixhawk 6C'nin hafızası neredeyse dolu (%98).** Yeni PX4 modülü eklemeden önce yer açılması planlanıyor. `derleme-fmu-v6c` kırmızı olur ve "region FLASH overflowed" yazarsa sebebi budur — Hüseyin'e haber ver.
- Simülatör **Gazebo Harmonic**'tir. İnternette "Gazebo Classic" (`gazebo-classic_...`, `.world`) anlatan rehberler bizim sistemde çalışmaz.

---

## 10. Takıldığında

1. Önce `TEZ_README.md` → "Sorun giderme" tablosuna bak.
2. Hata mesajını olduğu gibi kopyalayıp gruba yaz (ekran görüntüsü de olur).
3. Emin olmadığın bir komutu (özellikle `--force`, `--remote`, `reset --hard`) çalıştırmadan önce sor.
