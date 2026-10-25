# Teknoloji Yığını

Son güncelleme: 2026-10-24

**Durum etiketleri:**
- **Kesin:** Karar verilmiş; sabit sürümü varsa yazılmıştır.
- **Karar bekliyor:** Henüz seçilmemiş veya doğrulanmamış. Kesinleşmiş gibi kullanılmaz; ilgili yol haritası maddesinde araştırılıp gerekçesiyle karara bağlanır.

**Ekip için sade özet:** [`docs/02-ortak-yazilim-surumleri.md`](../../docs/02-ortak-yazilim-surumleri.md): herkesin laptopunda ve Raspberry Pi'de **aynı olması gereken** sürümler, kurulum sonrası kontrol komutları ve "yapma" listesi. Bu dosya ile o doküman birbiriyle **tutarlı tutulur**: bir sürüm/araç değişince `VERSIONS.md`, `Vision/requirements/`, `02-ortak-yazilim-surumleri.md` ve bu dosya **aynı PR'da** güncellenir. Spec yazan veya kod geliştiren herkes (Claude ajanları dahil) yeni bir araç/paket önermeden önce o dokümana bakar.

**Sürümlerin tek doğru kaynağı:** `Autopilot/tez/env/VERSIONS.md` (araçlar) ve `Vision/requirements/*.txt` (Vision Python paketleri). Bu dosya ile onlar çelişirse onlar geçerlidir. Hiçbir araç veya paket "en son sürüm"e kaymaz; yeni bir araç, sabit sürümü oraya yazılmadan kullanılmaz.

## 1. Donanım

| Bileşen | Seçim | Durum |
|---|---|---|
| Gövde | Holybro X500 V2 (quadrotor X) | Kesin |
| Motorlar | Holybro 2216 KV920, 4 adet | Kesin |
| ESC | BLHeli S ESC 20A, 4 adet | Kesin |
| Pervaneler | 1045, 4 adet | Kesin |
| Uçuş kontrolcüsü | Pixhawk 6C (plastik kasa) | Kesin |
| Güç modülü | PM02 V3 | Kesin |
| Güç dağıtım kartı | Güç dağıtım kartı (PDB) | Kesin |
| GPS | Holybro M8N | Kesin |
| Telemetri radyosu | SiK Telemetry Radio V3, 915 MHz | Kesin |
| Yardımcı bilgisayar | Raspberry Pi 5 | Kesin |
| AI hızlandırıcı | Hailo AI Kit | Kesin (donanım) |
| Kamera | Raspberry Pi Camera Module 3 | Kesin (donanım) |
| RC kumanda sistemi | — | Karar bekliyor |
| Batarya | — | Karar bekliyor |
| Görüntü aktarım donanımı (yer istasyonuna) | — | Karar bekliyor |
| Aracın gerçek kütlesi | Ölçülmedi; simülasyonda şimdilik standart X500 | Karar bekliyor (ölçülecek) |

## 2. Uçuş yazılımı (`Autopilot` reposu)

| Bileşen | Seçim | Durum |
|---|---|---|
| Otopilot | **PX4-Autopilot v1.17.0** (`d6f12ad1c4`), kalıcı olarak kilitli; yükseltme yok | Kesin |
| Değiştirilebilir PX4 yolları | `Autopilot/tez/pin/allowed-paths.txt`; dışındaki değişiklik açık onay ister | Kesin |
| Dil / RTOS | C++ (PX4 modülleri), NuttX (donanım), POSIX (SITL) | Kesin |
| Derleme | `make` + CMake 3.28.3 + Ninja 1.11.1, GCC 13.3.0; donanım için arm-none-eabi-gcc 13.2.1 | Kesin |
| Firmware hedefi | `px4_fmu-v6c_default`, airframe `SYS_AUTOSTART=4019` | Kesin (mevcut) |
| Flash'ta yer açan özel kart konfigürasyonu | Flash ~%98 dolu (~40 KB boş); kapatılacak modüller ve konfigürasyon adı belirlenmedi | Karar bekliyor |
| Takip modunun PX4'e entegrasyon yaklaşımı | Seçilmedi | Karar bekliyor |
| Takip kontrol algoritması | Seçilmedi | Karar bekliyor |

## 3. Simülasyon

| Bileşen | Seçim | Durum |
|---|---|---|
| Simülatör | **Gazebo Harmonic**: gz-sim 8.15.0, gz-transport 13.6.0, sdformat 14.9.0 (`apt-mark hold`) | Kesin |
| Gazebo Python bağları | python3-gz-transport13 13.6.0, python3-gz-msgs10 10.4.0, python3-gz-sim8 8.15.0 | Kesin |
| SITL | PX4 SITL, `make px4_sitl gz_<model>` | Kesin |
| Gazebo Classic | Kullanılmaz | Kesin |
| Simülasyon kamerası | Hazır `gz_x500_mono_cam` mi, özel model mi | Karar bekliyor |
| Hareketli insan hedefinin simülasyonu | Yöntem seçilmedi | Karar bekliyor |
| Laptop'ta Hailo olmadan algılama | Yöntem seçilmedi | Karar bekliyor |

## 4. Yardımcı bilgisayar ve görüntü işleme (`Vision` reposu)

| Bileşen | Seçim | Durum |
|---|---|---|
| Pi işletim sistemi | Raspberry Pi OS (64-bit) masaüstü, Debian 13 Trixie, imaj 2026-09-15 | Kesin |
| Python | Pi: 3.13.5 · Laptop: 3.12.3 (kod iki sürümde de çalışmalı) | Kesin |
| Sayısal hesap | NumPy 2.4.6 | Kesin |
| Görüntü işleme | OpenCV 5.0.0.93 (`opencv-python` laptop, `opencv-python-headless` Pi/CI) | Kesin |
| Pi kamera kütüphanesi | picamera2 (Pi'de apt paketi, venv `--system-site-packages`) | Kesin |
| Yardımcı paketler | pyserial 3.5, PyYAML 6.0.3 | Kesin |
| Test ve stil | pytest 9.1.1, ruff 0.16.9 | Kesin |
| ROS 2 | Şu an kullanılmıyor (taslak karar); ROS 2 bağımlılığı eklenmez | Karar bekliyor (taslak: kullanılmıyor) |

## 5. AI çıkarımı

| Bileşen | Seçim | Durum |
|---|---|---|
| Çıkarım donanımı | Hailo AI Kit (Pi 5 üzerinde) | Kesin (donanım) |
| Hailo yazılım yığını (runtime, sürücü, Python paketleri) ve sürümleri | Pi OS Trixie / Python 3.13 uyumu doğrulanmadı, sürümler sabitlenmedi | Karar bekliyor / doğrulanacak |
| İnsan algılama modeli | Önce hazır/deneme modeli (madde 7), sonra uçuş verisiyle ekibin eğittiği model (madde 28); hangisi olduğu seçilmedi | Karar bekliyor |
| Model eğitimi | **Kapsamda:** uçuşlarda toplanan görüntülerden etiketlenen kendi veri setimizle eğitim (Aşama 8) | Kesin |
| Eğitim çerçevesi ve başlangıç ağırlıkları | Deneme eğitimleri YOLOv8s (Ultralytics) ile COCO ağırlıklarından transfer learning olarak yapıldı; kesin seçim değil, sürüm sabitlenmedi. Lisans (Ultralytics: AGPL-3.0) seçimde değerlendirilir | Karar bekliyor |
| Modelin Hailo formatına dönüştürülmesi | Dönüşüm aracı ve sürümü seçilmedi (madde 7) | Karar bekliyor |
| Eğitim ortamı (donanım) ve eğitim kodunun yeri | Seçilmedi. Eğitim paketleri Pi'nin `Vision/requirements/` dosyalarına karışmaz | Karar bekliyor |
| Etiketleme aracı ve etiket formatı | Seçilmedi (madde 27) | Karar bekliyor |
| Veri seti ve model dosyalarının saklandığı yer | Repo dışında ortak bir depolama alanı; hangisi olduğu seçilmedi | Karar bekliyor |

## 6. Görüntü işleme ↔ kontrol haberleşmesi

| Bileşen | Seçim | Durum |
|---|---|---|
| Protokol kısıtı | MAVLink kilitli submodule; yeni mesaj veya dialect eklenmez, yalnızca PX4 v1.17.0'ın desteklediği mesajlar kullanılır | Kesin (kısıt) |
| MAVLink kütüphanesi (Python) | pymavlink 2.4.50 | Kesin |
| Pi ↔ Pixhawk haberleşme yöntemi ve fiziksel bağlantı | Mevcut standart Pi'nin Pixhawk TELEM2'ye seri hatla bağlanmasını öngörür; yöntem ve format seçimiyle birlikte teyit edilecek | Karar bekliyor |
| Mesaj seti ve veri formatı | Seçilmedi | Karar bekliyor |
| Arayüz tanımı (ICD): hedef vektörü, frame, birimler, frekans, zaman damgası, geçersiz veri davranışı | Çatı repoda `agent-os/specs/` altında tanımlanacak | Karar bekliyor |

## 7. Yer istasyonu ve izleme

| Bileşen | Seçim | Durum |
|---|---|---|
| Yer kontrol istasyonu | QGroundControl v5.1.4 (Stable_V5.1), x86_64 AppImage | Kesin |
| Telemetri bağlantısı | SiK Telemetry Radio V3, 915 MHz | Kesin |
| Görüntü aktarım yöntemi | Seçilmedi | Karar bekliyor |
| Görüntü ve takip bilgisinin yer istasyonunda gösterimi | Yöntem/araç seçilmedi | Karar bekliyor |

## 8. Log ve analiz

| Bileşen | Seçim | Durum |
|---|---|---|
| Uçuş logları | ULog (PX4) | Kesin |
| Log analizi | pyulog 1.2.4, PlotJuggler 3.17.2 (AppImage) | Kesin |
| Analiz Python ortamı | `Autopilot/tez/env/analiz-requirements.txt` (pandas, matplotlib, SciPy…), venv `.venv-tez` | Kesin |
| MAVLink araçları | MAVProxy 1.8.75 | Kesin |
| Başarı kriterleri (ölçülecek büyüklükler ve eşikler) | Sayısal olarak belirlenmedi | Karar bekliyor |

## 9. Geliştirme ortamı

| Bileşen | Seçim | Durum |
|---|---|---|
| İşletim sistemi (laptop) | Ubuntu 24.04 LTS (x86_64) | Kesin |
| Editör | VS Code (eklenti listesi `VERSIONS.md`'de) | Kesin |
| Sürüm kontrolü | Git 2.43.0, GitHub organizasyonu `Auto-Follow` | Kesin |
| CI | GitHub Actions; Autopilot'ta zorunlu kontroller `verify-pin`, `derleme-sitl`, `derleme-fmu-v6c`; Vision'da Python 3.12 + 3.13 | Kesin |

## 10. Dokümantasyon ve süreç

| Bileşen | Seçim | Durum |
|---|---|---|
| Repo yapısı | Üç ayrı repo: `Auto-Follow/Auto-Follow` (çatı: ürün planı, ortak spec'ler, doküman), `Auto-Follow/Autopilot` (PX4 kodu), `Auto-Follow/Vision` (Pi Python kodu). Kod yalnızca Autopilot ve Vision'a yazılır | Kesin |
| Planlama | Agent OS v2.1.1 (`6a6495111e`), Claude Code; profiller `auto-follow` (çatı) ve `auto-follow-repo` (alt repolar) | Kesin |
| Spec yerleri | Ortak spec'ler `agent-os/specs/` (çatı); bileşen spec'leri `Autopilot/agent-os/specs/`, `Vision/agent-os/specs/` | Kesin |
| İş akışı | branch → PR → CI yeşil → en az 1 onay → squash merge; uyumlu sürümler iki repoda aynı `tez-*` tag'iyle işaretlenir | Kesin |
| Doküman dili | Türkçe (teknik terimler İngilizce kalabilir) | Kesin |
| Repoya girmeyenler | Video, `.ulg` log, veri seti, model ağırlığı, 100 MB üstü dosyalar | Kesin |
