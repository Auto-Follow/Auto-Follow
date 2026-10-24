# Auto-Follow — Ortak Yazılım Sürümleri

Projede herkesin bilgisayarında **aynı sürümler** olmalı. Farklı sürüm = "bende çalışıyor, sende çalışmıyor" sorunu.
Hiçbir şeyi kendi başına güncelleme; güncelleme gerekiyorsa önce ekipçe konuşuyoruz.

Son güncelleme: 24 Ekim 2026

> Bu doküman ürün planındaki teknoloji yığınının ([`agent-os/product/tech-stack.md`](../agent-os/product/tech-stack.md)) **sade özetidir**; ikisi birbiriyle tutarlı tutulur. Tam sürüm listesi: `Autopilot/tez/env/VERSIONS.md` ve `Vision/requirements/`. Bir sürüm değişirse hepsi **aynı PR'da** güncellenir; bunu repo sorumlusu onaylar.

---

## 1. Laptop — mutlaka herkeste aynı olmalı

| Bileşen | Sürüm | Not |
|---|---|---|
| **Ubuntu** | **24.04 LTS** (64-bit, x86_64) | 24.04.4 veya 24.04.5 fark etmez (aynı sürümün güncellenmiş hâli). 22.04 veya 25.x **olmaz**. |
| **PX4** | **v1.17.0** | Repoda kilitli. v1.18'e **geçilmeyecek**. |
| **QGroundControl** | **v5.1.4** | Stable sürüm. Başka sürüm indirme. |
| **Gazebo** | **Harmonic** (gz-sim **8.15.0**) | **Gazebo Classic kullanılmıyor.** İnternette "Gazebo Classic / gazebo11" anlatan rehberler bizde çalışmaz. |
| **Pixhawk derleyicisi** | arm-none-eabi-gcc **13.2.1** | PX4 kurulum script'i kurar. |
| **Python** | **3.12** | Ubuntu 24.04 ile gelir. |
| **Vision Python paketleri** | NumPy 2.4.6 · OpenCV 5.0.0.93 · pymavlink 2.4.50 · pyserial 3.5 · PyYAML 6.0.3 | Vision reposundaki `requirements/laptop.txt` ile kurulur, elle kurma. |
| **Agent OS** | **v2.1.1**, profiller **`auto-follow`** + **`auto-follow-repo`** | v3 **kullanılmıyor**. Resmi kurulum komutunu değil, çatı repodaki `./kurulum.sh` script'ini kullan (bkz. `01-ekip-rehberi.md`). |

## 2. Raspberry Pi 5 — mutlaka aynı olmalı

| Bileşen | Sürüm | Not |
|---|---|---|
| **İşletim sistemi** | **Raspberry Pi OS (64-bit), masaüstlü** — Debian 13 "Trixie" | İmaj: **`2026-09-15-raspios-trixie-arm64.img.xz`**. "Lite" (arayüzsüz), "Full" veya "Legacy/Bookworm" **değil**. |
| İmaj doğrulama (sha256) | `61d95799550aac32788bb3cacc3d471dcc860f8053ce989dec4aecc388b799dd` | İndirdikten sonra kontrol et (aşağıda). |
| **Python** | **3.13** (Trixie ile gelir: 3.13.5) | Laptoptaki 3.12'den farklı; Vision kodu ikisinde de çalışacak şekilde yazılır. |
| **Vision Python paketleri** | NumPy 2.4.6 · OpenCV (headless) 5.0.0.93 · pymavlink 2.4.50 · pyserial 3.5 · PyYAML 6.0.3 | Vision reposundaki `requirements/pi.txt` ile kurulur. |
| Pi kamera kütüphanesi | picamera2 | `sudo apt install python3-picamera2` (pip ile değil). |

**Pi imajını indirme ve doğrulama (laptopta):**
```bash
cd ~/Downloads
wget https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2026-09-15/2026-09-15-raspios-trixie-arm64.img.xz
echo "61d95799550aac32788bb3cacc3d471dcc860f8053ce989dec4aecc388b799dd  2026-09-15-raspios-trixie-arm64.img.xz" | sha256sum -c
# "OK" görmelisin
```
SD karta yazarken Raspberry Pi Imager'da listeden seçme; **"Use custom"** ile bu indirdiğin dosyayı seç. Böylece herkes birebir aynı imajı kurar.

## 3. Donanım ve uçuş ayarları — herkes aynısını kullanır

| Bileşen | Değer |
|---|---|
| Gövde | Holybro **X500 V2** |
| Uçuş kontrolcüsü | Holybro **Pixhawk 6C** |
| Yardımcı bilgisayar | **Raspberry Pi 5** (Pixhawk'a bağlantı yöntemi henüz kesin değil; şu anki öngörü TELEM2 seri port — yol haritası madde 4'te kesinleşecek) |
| Yapay zekâ hızlandırıcı | **Hailo AI Kit** (Pi 5 üzerinde). Yazılımı ve sürümü **henüz sabitlenmedi**; Pi OS Trixie uyumu yol haritası madde 2'de doğrulanacak. O zamana kadar Hailo için kendi başına paket kurma. |
| Kamera | **Raspberry Pi Camera Module 3** |
| Güç / GPS / telemetri | PM02 V3 güç modülü · Holybro M8N GPS · SiK Telemetry Radio V3 (915 MHz) |
| Motor / ESC / pervane | Holybro 2216 KV920 · BLHeli S 20A ESC · 1045 pervane (4'er adet) |
| Henüz seçilmedi | RC kumanda, batarya, yer istasyonuna görüntü aktarım donanımı |
| Pixhawk firmware | Autopilot reposundan derlenir: `make px4_fmu-v6c_default` (hazır PX4 firmware'i **yükleme**) |
| Airframe | `SYS_AUTOSTART = 4019` (Holybro X500 V2) |

## 4. Aynı olması önerilir

| Bileşen | Sürüm |
|---|---|
| GCC / CMake / Ninja | 13.3.0 / 3.28.3 / 1.11.1 (Ubuntu ile gelir) |
| PlotJuggler (log grafikleri) | 3.17.2 (4.0 kullanılmıyor) |
| MAVProxy / pyulog | 1.8.75 / 1.2.4 |
| Git | 2.43.0 |

## 5. Farklı olabilir (sorun değil)

| Bileşen | Not |
|---|---|
| NVIDIA sürücüsü | Ekran kartına bağlı. NVIDIA kartın yoksa gerekmez. |
| VS Code, Claude Code | Kendi kendine güncellenir, sorun değil. |
| Raspberry Pi Imager | Sadece SD karta yazmak için; "Use custom" ile yazıldığı sürece sürümü önemli değil. |

---

## Nasıl kurarım?

Kurulumu tek tek yapma; repodaki adımları sırayla izle:

1. **Çatı repo + iki repo + Agent OS** (tek komut; ayrıntı: [`01-ekip-rehberi.md` → 3. Kurulum](01-ekip-rehberi.md#3-kurulum)):
   ```bash
   mkdir -p ~/Desktop/Projects && cd ~/Desktop/Projects
   git clone https://github.com/Auto-Follow/Auto-Follow.git
   cd Auto-Follow && ./kurulum.sh
   ```
   Sonuç (herkeste aynı):
   ```
   ~/Desktop/Projects/Auto-Follow/   ← çatı repo
   ├── Autopilot/
   └── Vision/
   ```
2. **Autopilot kurulumu (PX4 + Gazebo):** https://github.com/Auto-Follow/Autopilot/blob/main/TEZ_README.md → "Yeni ekip üyesi: kurulum sırası"
3. **Tam sürüm listesi ve kurulum komutları** (QGroundControl, Gazebo dondurma, geliştirme araçları): https://github.com/Auto-Follow/Autopilot/blob/main/tez/env/VERSIONS.md
4. **Vision kurulumu (laptop ve Pi):** https://github.com/Auto-Follow/Vision#readme

---

## Kurulumdan sonra kontrol et

**Laptopta** — terminalde çalıştır, sağdaki sonuçları görmelisin:

```bash
cd ~/Desktop/Projects/Auto-Follow/Autopilot
lsb_release -ds                                    # Ubuntu 24.04.x LTS
git describe --tags --match 'v[0-9]*' --abbrev=0   # v1.17.0
tez/pin/verify_pin.sh --worktree                   # Sonuc: KILIT SAGLAM (v1.17.0)
gz sim --versions                                  # 8.15.0
arm-none-eabi-gcc --version | head -1              # ... 13.2.1 ...
python3 -V                                         # Python 3.12.x
ls ~/Applications/                                 # QGroundControl-v5.1.4-x86_64.AppImage
grep ^version ~/agent-os/config.yml                # version: 2.1.1
```

**Raspberry Pi'de:**

```bash
cat /etc/os-release | grep PRETTY    # Debian GNU/Linux 13 (trixie)
uname -m                             # aarch64
python3 -V                           # Python 3.13.x
```

Bir satır farklı çıkarsa **kendin düzeltmeye çalışma**, çıktıyı gruba at.

---

## Yapma

- ❌ `sudo apt upgrade` sonrası Gazebo'yu elle güncellemek (Gazebo paketleri bilerek dondurulmuş)
- ❌ QGroundControl'ün başka bir sürümünü indirmek
- ❌ `pip install --upgrade ...` ile paket yükseltmek
- ❌ PX4'ü GitHub'daki orijinal PX4 reposundan klonlamak — **sadece** `Auto-Follow/Autopilot` kullan
- ❌ Agent OS'u resmi sitesindeki komutla kurmak (o komut v3 kurar) — çatı repodaki `./kurulum.sh` kullanılır
- ❌ Hailo için internetteki rehberlerden "en güncel" paketleri kurmak — sürüm yol haritası madde 2'de belirlenip buraya yazılacak
- ❌ Pi'ye Raspberry Pi Imager listesinden "en güncel" sürümü yazmak — **sadece** yukarıdaki imaj dosyası
- ❌ Pixhawk'a QGroundControl'ün sunduğu hazır PX4 firmware'ini yüklemek — firmware Autopilot reposundan derlenir
