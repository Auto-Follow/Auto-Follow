# Çatı repo ve Agent OS: nasıl çalışıyoruz?

> Bu doküman, projeye **üçüncü bir repo** (çatı repo) eklendikten sonra çalışma düzenimizin nasıl değiştiğini anlatır.
> Kime: tüm ekip. Son güncelleme: 2026-10-24.

---

## 1. Kısaca ne değişti?

Projemiz **tek bir sistem** (drone + Pi + görüntü işleme) ama kodu **iki ayrı repoda**: `Autopilot` (PX4) ve `Vision` (Pi Python). Agent OS ise "bir repo = bir ürün" varsayımıyla çalışıyor. Bu yüzden ürün planını (misyon, yol haritası, teknoloji yığını) ve iki tarafı birden ilgilendiren konuları (Pi ↔ Pixhawk arayüzü gibi) koyacak ortak bir yerimiz yoktu.

Çözüm: zaten herkeste aynı olan `~/Desktop/Projects/Auto-Follow/` klasörünün **kendisi** artık bir git reposu: **`Auto-Follow/Auto-Follow`** (çatı repo).

| | Önce | Şimdi |
|---|---|---|
| `~/Desktop/Projects/Auto-Follow/` | Sıradan bir klasör | Çatı repo (GitHub: `Auto-Follow/Auto-Follow`) |
| Ürün planı (`/plan-product`) | Autopilot'ta yazılacaktı; Vision'dan görünmüyordu | Çatıda: `agent-os/product/`. **İki repodan da okunur** |
| İki repoyu ilgilendiren spec'ler (ICD vb.) | Yeri yoktu | Çatıda: `agent-os/specs/` |
| Agent OS profili (standartların kaynağı) | `Autopilot/tez/agent-os/profiles/` | Çatıda: `agent-os-profilleri/` |
| Kurulum | Repoları elle klonla | Çatıyı klonla → `./kurulum.sh` |
| Claude kuralları (`CLAUDE.md`) | Yoktu | Çatıda ortak bir tane + her repoda kısa bir tane |

**Değişmeyenler:** Autopilot ve Vision repoları, CI kontrolleri, PR/onay kuralları, PX4 sürüm kilidi, Pixhawk'a firmware yükleme ve Pi'ye kod kurma **aynen** devam ediyor.

---

## 2. Klasör yapısı

```
~/Desktop/Projects/Auto-Follow/        ← ÇATI REPO (Auto-Follow/Auto-Follow)
├── README.md
├── CLAUDE.md                          ← Claude'un her oturumda okuduğu ortak kurallar
├── kurulum.sh                         ← Autopilot + Vision'ı klonlar, Agent OS'u kurar
├── kurulum/                           ← Agent OS kurulum/derleme scriptleri
├── agent-os-profilleri/               ← standartların KAYNAĞI (sadece proje lideri değiştirir)
├── agent-os/
│   ├── product/                       ← ürün planı: mission.md, roadmap.md, tech-stack.md
│   └── specs/                         ← ortak spec'ler (iki repoyu birden ilgilendirenler)
├── docs/                              ← bu doküman
│
├── Autopilot/                         ← AYRI REPO (Auto-Follow/Autopilot): PX4 kodu
│   ├── CLAUDE.md
│   └── agent-os/specs/                ← sadece PX4 tarafını ilgilendiren spec'ler
│
└── Vision/                            ← AYRI REPO (Auto-Follow/Vision): Pi Python kodu
    ├── CLAUDE.md
    └── agent-os/specs/                ← sadece Pi tarafını ilgilendiren spec'ler
```

**Önemli:** Bunlar **üç ayrı git reposu**. `Autopilot/` ve `Vision/` çatının içinde duruyor ama çatıya ait değiller (çatının `.gitignore`'u onları dışarıda tutuyor; submodule de değiller).
`git` komutunu **hangi klasörde** çalıştırırsan **o repoya** yazar:

```bash
cd ~/Desktop/Projects/Auto-Follow            # git → çatı repo
cd ~/Desktop/Projects/Auto-Follow/Vision     # git → Vision reposu
git rev-parse --show-toplevel                # "şu an hangi repodayım?"
```

---

## 3. Kurulum

### 3.1 Sıfırdan (yeni bilgisayar)
```bash
mkdir -p ~/Desktop/Projects && cd ~/Desktop/Projects
git clone https://github.com/Auto-Follow/Auto-Follow.git
cd Auto-Follow
./kurulum.sh
```
`kurulum.sh` şunları yapar: Autopilot'u (submodule'leriyle) ve Vision'ı doğru yere klonlar, Agent OS v2.1.1'i `~/agent-os`'a kurar.
Sonra her zamanki gibi: PX4 + Gazebo için `Autopilot/TEZ_README.md`, Python ortamı için `Vision/README.md`.

### 3.2 Zaten `~/Desktop/Projects/Auto-Follow/Autopilot` ve `Vision` klasörlerin varsa
Klasör boş olmadığı için `git clone` çalışmaz. Çatı repoyu mevcut klasöre bağla:
```bash
cd ~/Desktop/Projects/Auto-Follow
git init -b main
git remote add origin https://github.com/Auto-Follow/Auto-Follow.git
git fetch origin
git checkout -t origin/main
./kurulum.sh        # mevcut Autopilot/Vision klonlarına dokunmaz, sadece adreslerini kontrol eder
```
Autopilot ve Vision'da da `git switch main && git pull` yap.

### 3.3 Kurulum doğru mu?
```bash
cd ~/Desktop/Projects/Auto-Follow
git status                  # "nothing to commit" demeli; Autopilot/ ve Vision/ listede GÖRÜNMEMELİ
ls agent-os/                # config.yml, standards/ (plan yazıldıktan sonra product/ da)
ls ~/agent-os/profiles/     # auto-follow, auto-follow-repo, default
```

---

## 4. Claude Code ile çalışma

### 4.1 Komutların adı
Agent OS komutları Claude Code'da **`/agent-os:` önekiyle** görünür. `/agent-os` yazınca liste açılır:

| Komut | Ne yapar |
|---|---|
| `/agent-os:plan-product` | Ürün planı (sadece çatıda, sadece proje lideri) |
| `/agent-os:shape-spec` | Bir özelliği soru-cevapla şekillendirir |
| `/agent-os:write-spec` | Şekillenen özellikten spec yazar |
| `/agent-os:create-tasks` | Spec'ten görev listesi (`tasks.md`) çıkarır |
| `/agent-os:implement-tasks` | Görevleri uygular |
| `/agent-os:orchestrate-tasks` | Görevleri alt ajanlara dağıtarak uygular |

> `/plan-product` yazarsan bulamaz; doğrusu `/agent-os:plan-product`.
> Yeni bir `.claude/` klasörü eklendiyse veya `git pull` ile komutlar değiştiyse Claude Code'u kapatıp yeniden aç.

### 4.2 Claude'u nerede açmalıyım?

| Ne yapacaksın | Claude'u nerede aç |
|---|---|
| Sadece PX4 tarafı (modül, parametre, SITL) | `Autopilot/` |
| Sadece Pi tarafı (kamera, görüntü işleme) | `Vision/` |
| İki tarafı birden ilgilendiren bir şey (Pi ↔ Pixhawk mesajları, uçtan uca test senaryosu) | Çatı (`Auto-Follow/`) |
| Ürün planı | Çatı (sadece proje lideri) |

Nerede açarsan aç, Claude **çatıdaki `CLAUDE.md`'yi de okur**. Kurallar (kilit, yasak komutlar, Gazebo Harmonic, sürüm sabitliği) her oturumda geçerlidir.

### 4.3 Ürün planı her yerden okunur
`Autopilot/` veya `Vision/` içinde `/agent-os:shape-spec` çalıştırdığında Claude ürün planını otomatik olarak **bir üst klasörden** (`../agent-os/product/`) okur. Senin bir şey yapmana gerek yok.

Güvenlik önlemleri (test edildi):
- Çatı repo kurulu değilse veya ürün planı henüz yazılmadıysa spec komutları **durur** ve bunu söyler; plansız spec yazılmaz.
- Alt repolarda `/agent-os:plan-product` çalışmaz; "plan çatıda" diye yönlendirir. Böylece kimse yanlışlıkla ikinci bir ürün planı oluşturamaz.
- Claude bileşen spec'i yazarken çatıdaki ortak spec'lere (ör. ICD) bakar ve arayüzü yeniden tanımlamak yerine onlara referans verir.

---

## 5. Örnek iş akışları

### 5.1 Proje lideri: ürün planı (bir kere, sonra güncelleme)
```bash
cd ~/Desktop/Projects/Auto-Follow
git switch -c plan/urun-plani
claude                              # içinde: /agent-os:plan-product
# agent-os/product/ altında mission.md, roadmap.md, tech-stack.md oluşur
git add agent-os/product && git commit -m "Urun plani"
git push -u origin plan/urun-plani  # → PR → onay → merge
```
`roadmap.md`'yi **sadece proje lideri** günceller (bir spec'in PR'ı merge edildikten sonra). Doğrulama ajanı roadmap'i değiştirmez, sadece "şu madde bitti" diye önerir.

### 5.2 Bir ekip üyesi: sadece Pi tarafında bir özellik
Örnek: "Gazebo kamerasından görüntü okuma"
```bash
cd ~/Desktop/Projects/Auto-Follow/Vision
git switch main && git pull
git switch -c ozellik/kamera-okuma
claude
#   /agent-os:shape-spec Gazebo kamerasından görüntü okuma
#   /agent-os:write-spec
#   /agent-os:create-tasks
#   /agent-os:implement-tasks
# Spec: Vision/agent-os/specs/<tarih>-<ad>/   Kod: Vision/src/
git push -u origin ozellik/kamera-okuma   # → Vision'da PR
```

### 5.3 İki tarafı birden ilgilendiren özellik
Örnek: "Pi, hedefin konumunu Pixhawk'a hangi MAVLink mesajıyla göndersin?" (ICD)
1. **Çatıda** spec yazılır: Claude'u `Auto-Follow/` klasöründe aç → `/agent-os:shape-spec` → `/agent-os:write-spec`. Spec `agent-os/specs/` altına yazılır ve **çatıda PR** olur.
2. Spec onaylanınca uygulama **iki repoda ayrı ayrı** yapılır:
   - `Vision/`'da gönderen taraf → Vision PR'ı
   - `Autopilot/`'ta alan taraf → Autopilot PR'ı
   - Her iki repoda da bileşen spec'i, çatıdaki ICD spec'ine referans verir.
3. PR açıklamalarında birbirine ve çatıdaki spec'e link verilir.

> Kural: Bir bileşen spec'i ortak bir arayüzü değiştirmek isterse **önce çatıdaki ortak spec değişir**, sonra kod.

### 5.4 Uçuş veya SITL testi: hangi sürümler birlikte çalıştı?
Autopilot ve Vision ayrı repolar olduğu için "bu testte hangi PX4 kodu hangi Pi koduyla çalıştı?" bilgisi kendiliğinden kaydedilmez. Bu yüzden her testte **iki repoya aynı isimli tag** atılır:
```bash
git -C ~/Desktop/Projects/Auto-Follow/Autopilot tag tez-ucus-1 && git -C ~/Desktop/Projects/Auto-Follow/Autopilot push origin tez-ucus-1
git -C ~/Desktop/Projects/Auto-Follow/Vision    tag tez-ucus-1 && git -C ~/Desktop/Projects/Auto-Follow/Vision    push origin tez-ucus-1
```
Tag'ler **`tez-`** ile başlar (`v` ile başlayan tag yasak).

---

## 6. Pixhawk ve Raspberry Pi'ye yükleme: değişen bir şey yok

| | Nasıl | Çatı repo etkiler mi? |
|---|---|---|
| Pixhawk 6C firmware | `cd Autopilot && make px4_fmu-v6c_default upload` | **Hayır.** Derleme sadece `Autopilot/` içini görür; firmware sürüm bilgisi Autopilot'un kendi git geçmişinden okunur. |
| SITL | `cd Autopilot && make px4_sitl gz_x500` | **Hayır.** |
| Raspberry Pi | Pi'ye **sadece Vision** klonlanır (`Vision/README.md`) | **Hayır.** Pi çatı repoyu hiç görmez. |
| GitHub CI | Her repo kendi CI'ını çalıştırır | **Hayır.** CI sadece o repoyu klonlar. |

Bunun hep böyle kalması için kural: **`Vision/src/` ve PX4 kodu asla `../` ile çatıya veya diğer repoya başvurmaz.** (Pi'de çatı yok; CI'da diğer repo yok.)

---

## 7. Standartları değiştirmek (sadece proje lideri)

Claude'un uyduğu kurallar (`agent-os/standards/`) **elle düzenlenmez**; bir sonraki derlemede silinir. Kaynak çatıdaki profillerdir:

| Profil | Nerede kullanılır | İçerik |
|---|---|---|
| `agent-os-profilleri/auto-follow` | Çatı | Tüm proje standartları (PX4, Python, Gazebo, test) + ajan değişiklikleri |
| `agent-os-profilleri/auto-follow-repo` | Autopilot, Vision | `auto-follow`'un aynısı; sadece "ürün planını `../`'dan oku" farkı var |

Değiştirme adımları:
```bash
cd ~/Desktop/Projects/Auto-Follow
# 1) agent-os-profilleri/auto-follow/standards/... dosyasını düzenle
kurulum/install-agent-os.sh       # profilleri ~/agent-os'a bağlar (sabit v2.1.1)
kurulum/agent-os-derle.sh         # çatı + Autopilot + Vision'ı yeniden derler
# 2) Üç repoda ayrı ayrı: git status → branch → PR
```
> `project-install.sh --re-install` **kullanılmaz**: `agent-os/specs/` ve `product/` klasörlerini siler. `agent-os-derle.sh` bunları korur.

---

## 8. Sık karşılaşılan durumlar

| Durum | Sebep | Çözüm |
|---|---|---|
| `/plan-product` bulunamıyor | Komutların adı `/agent-os:` önekli | `/agent-os:plan-product` |
| Komutlar hiç görünmüyor | Claude Code, `.claude/` eklenmeden önce açılmış | Claude Code'u kapatıp yeniden aç |
| Vision'da spec komutu "çatı repo kurulu değil / ürün planı yok" diyor | Çatı klonlanmamış veya plan henüz yazılmamış | Bölüm 3.2; plan yoksa proje liderini bekle |
| Vision'da `plan-product` "bu repoda çalıştırılmaz" diyor | Bilerek böyle | Ürün planı sadece çatıda |
| Çatıda `git status`'ta `Autopilot/` görünüyor | `.gitignore` bozulmuş | Commit etme; proje liderine haber ver |
| Çatıya yeni bir dosya ekledim ama `git status`'ta görünmüyor | Çatının `.gitignore`'u **beyaz liste**: sadece izin verilenler girer | Gerçekten gerekiyorsa `.gitignore`'a `!/<ad>` eklenir (proje lideri onayı) |
| Yanlış repoya commit attım | Yanlış klasörde `git commit` | Push etmediysen: `git reset --soft HEAD~1`, doğru klasöre geç. Push ettiysen proje liderine sor |

---

## 9. Özet: beş madde

1. Klasör = repo: `Auto-Follow/` çatı, `Autopilot/` ve `Vision/` ayrı repolar. `git`'ten önce hangi klasörde olduğuna bak.
2. Kod sadece `Autopilot/` ve `Vision/`'a yazılır; çatıda sadece plan, ortak spec ve ayar olur.
3. Ürün planı çatıda; spec komutları onu her yerden otomatik okur. Planı sadece proje lideri değiştirir.
4. İki tarafı ilgilendiren konu → önce çatıda ortak spec, sonra iki repoda ayrı PR.
5. Test/uçuş → iki repoya aynı isimli `tez-*` tag'i.
