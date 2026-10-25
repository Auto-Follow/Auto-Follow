# Ürün Yol Haritası

Son güncelleme: 2026-10-25

Maddeler teknik bağımlılık sırasına göre dizilmiştir ve ürün tanımındaki 8 aşamayı izler; model eğitimi için ayrı bir aşama (Aşama 8) eklenmiştir. Her madde uçtan uca, doğrulanabilir bir sonuçtur; nasıl doğrulanacağı açıklamada yazılıdır. "Karar" geçen maddelerde önce seçenekler araştırılır, seçim gerekçesiyle belgelenir, sonra uygulanır.

Repo kısaltmaları: **Çatı** = `Auto-Follow` (ortak spec'ler `agent-os/specs/`), **Autopilot** = PX4 kodu, **Vision** = Raspberry Pi Python kodu.

## Aşama 1: Gereksinimler ve planlama

1. [ ] Ölçülebilir başarı kriterlerinin belirlenmesi — Takip mesafesi ve toleransı, hedefin görüntüde tutulma oranı, uçtan uca gecikme, hedef kaybında beklenen davranış ve test koşulları sayısal olarak tanımlanır (Çatı). Doğrulama: her kriterin hangi testle ve hangi log verisiyle ölçüleceği yazılmış ve repo sorumlusu tarafından onaylanmış olur. `S`
2. [ ] Hailo yazılım yığınının Pi OS Trixie üzerinde kurulumu, sürüm sabitleme ve doğrulama — Hailo AI Kit için gerekli yazılımın Raspberry Pi OS (Debian 13 Trixie, Python 3.13) ile uyumu araştırılır, kurulur ve Camera Module 3 görüntüsüyle örnek bir hazır model çalıştırılır (Vision). Doğrulama: bench'te Pi 5 üzerinde çıkarım çalışır, ölçülen FPS/gecikme kaydedilir ve sürümler `VERSIONS.md` / `Vision/requirements/` içine yazılır; uyumsuzluk varsa gerekçesiyle raporlanır. `M`

## Aşama 2: Sistem mimarisi

3. [ ] Sistem mimarisi ve coordinate frame tanımları — Bileşenler, veri akışı, camera frame / body frame tanımları, eksen yönleri, işaret kuralları ve birimler ortak spec olarak yazılır (Çatı). Doğrulama: örnek sayısal dönüşümler doküman içinde elle hesaplanmış ve iki repo tarafından gözden geçirilmiş olur. `S`
4. [ ] Pi ↔ Pixhawk haberleşme yönteminin seçimi — PX4 v1.17.0'ın zaten desteklediği MAVLink mesajları arasından aday yöntemler araştırılır (yeni mesaj/dialect yok), fiziksel bağlantı ve veri formatı seçilir, gerekçesi belgelenir (Çatı). Doğrulama: seçilen mesajla SITL'de laptop'tan gönderilen örnek veri PX4 tarafında okunup loglanır. `M`
5. [ ] Görüntü işleme ↔ kontrol arayüz tanımı (ICD) — Hedef vektörünün bileşenleri, frame, birimler, güncelleme frekansı, zaman damgası/gecikme bilgisi, "hedef yok" ve geçersiz/eski veri durumları ile her iki tarafın bu durumlardaki davranışı tanımlanır (Çatı). Doğrulama: Vision'da üretilen örnek mesajlar ve Autopilot'ta okuyan taraf için arayüz testleri iki repoda da geçer. `M`
6. [ ] Simülasyon kamera ve hareketli insan hedefi kurulumu — Hazır `gz_x500_mono_cam` modeli mi yoksa özel kamera modeli mi kullanılacağına ve Gazebo Harmonic'te hareketli insan hedefinin nasıl simüle edileceğine karar verilir ve uygulanır (Çatı spec, Autopilot uygulama). Doğrulama: SITL'de kamera görüntüsü laptop'taki Vision kodu tarafından okunur ve hedef tanımlı bir yörüngede hareket eder; kamera parametreleri belgelenir. `M`

## Aşama 3: Görüntü işleme geliştirme

7. [ ] Başlangıç insan algılama modelinin seçimi ve Hailo'ya aktarılması — Hazır (ör. COCO ile önceden eğitilmiş) modeller ile açık veri setleriyle yapılan deneme eğitimleri doğruluk, FPS ve gecikme açısından karşılaştırılır; seçilen modelin Hailo formatına dönüştürülme yolu (dönüşüm aracı ve sürümü) belirlenir ve belgelenir. Uçuş verisiyle eğitim Aşama 8'dedir (Vision). Doğrulama: aday modeller aynı test görüntüleri üzerinde ve Pi 5 + Hailo'da ölçülür, dönüşüm sonrası doğruluk kaybı raporlanır, seçim ölçümlerle gerekçelendirilir; model dosyaları repoya değil ortak depolama alanına konur. `L`
8. [ ] Simülasyonda Hailo olmadan algılama — Laptop'ta Hailo cihazı olmadan Gazebo görüntüsünde algılamanın nasıl yapılacağına karar verilir (seçilen modelle tutarlılık dahil) ve uygulanır (Vision). Doğrulama: SITL'deki insan hedefi laptop'ta algılanır; Pi + Hailo sonuçlarıyla farkları belgelenir. `S`
9. [ ] Camera Module 3 kalibrasyonu — Camera intrinsic parameters (ve gerekiyorsa distorsiyon) ölçülür ve Vision koduna yapılandırma olarak verilir (Vision). Doğrulama: kalibrasyon hatası (reprojection error) raporlanır; simülasyon kamerasının parametreleriyle ayrı tutulur. `S`
10. [ ] Piksel koordinatından body frame hedef vektörüne dönüşüm — Pixel coordinates → görüş doğrultusu → camera frame → body frame dönüşümü uygulanır; attitude bilgisinin kullanımı değerlendirilir ve gerekçesiyle belgelenir (Vision). Doğrulama: bilinen geometrilerle birim testleri geçer ve SITL'de hesaplanan vektör Gazebo'daki gerçek (ground truth) hedef konumuyla karşılaştırılıp hata ölçülür. `L`
11. [ ] Hedef seçimi ve geçersiz veri yönetimi — Görüntüde birden fazla kişi olduğunda takip edilecek hedefin seçimi, hedef kaybı ve kare okuma/işleme süresi aşımı durumlarında ICD'ye uygun "hedef yok" çıkışı üretilir (Vision). Doğrulama: kayıtlı/simüle görüntülerle hedef kaybı ve çoklu kişi senaryolarında beklenen çıktılar testlerle doğrulanır. `M`
12. [ ] Hedef vektörünün Pixhawk'a gönderilmesi — Vision çıktısı seçilen haberleşme yöntemi ve ICD ile PX4'e gönderilir (Vision). Doğrulama: SITL'de PX4 tarafında mesajlar alınır ve loglanır; ulaşan frekans ve gecikme ölçülür. `M`

## Aşama 4: Kontrol geliştirme

13. [ ] Takip kontrol algoritmasının tasarımı — Hedef vektörü ve takip mesafesinden İHA hareketini üreten kontrol yöntemi araştırılır, seçilir ve gerekçesiyle belgelenir; çıkış sınırları ve güvenli davranış tanımlanır (Autopilot). Doğrulama: PX4 dışında, sentetik hedef vektörü dizileriyle yapılan analiz/simülasyonda başarı kriterlerine göre davranışı ölçülür. `L`

## Aşama 5: PX4 entegrasyonu

14. [ ] Pixhawk 6C flash'ında yer açılması — Flash ~%98 dolu (~40 KB boş) olduğundan, kullanılmayan modülleri kapatan özel bir kart konfigürasyonu hazırlanır; kilit listesine (`Autopilot/tez/pin/allowed-paths.txt`) ekleme repo sorumlusunun onayıyla ayrı PR ile yapılır (Autopilot). Doğrulama: Pixhawk 6C firmware'i CI'da derlenir, boş flash miktarı raporlanır, kapatılan modüllerin listesi gerekçesiyle belgelenir ve araç bench'te QGroundControl'e bağlanıp temel fonksiyonları çalışır. `M`
15. [ ] PX4 entegrasyon yaklaşımının seçimi — Takip modunun PX4 v1.17.0'a nasıl entegre edileceğine dair seçenekler araştırılır; her birinin kilitli dosyalara ve flash'a etkisi değerlendirilir, seçim gerekçesiyle belgelenir (Autopilot). Doğrulama: seçilen yaklaşımın en küçük iskeleti SITL ve Pixhawk 6C hedeflerinde derlenir. `S`
16. [ ] PX4 özel takip modu (SITL) — Kontrol algoritması seçilen yaklaşımla PX4'e entegre edilir; gelen veri doğrulanır (NaN/aralık/zaman aşımı) ve geçersiz veride güvenli davranışa geçilir (Autopilot). Doğrulama: SITL'de sentetik hedef vektörüyle mod seçilir, İHA hedefi takip eder ve veri kesildiğinde tanımlı davranışa geçtiği loglardan gösterilir; CI'daki derleme ve kilit kontrolleri geçer. `XL`

## Aşama 6: Simülasyon ve test

17. [ ] Test ve ölçüm altyapısı — Başarı kriterlerini ULog kayıtlarından ve Vision loglarından hesaplayan analiz betikleri ve test raporu şablonu hazırlanır (Çatı spec, ilgili repoda uygulama). Doğrulama: örnek bir SITL kaydından kriterler otomatik olarak hesaplanır ve grafiklenir. `M`
18. [ ] Uçtan uca SITL takibi — Gazebo kamera → algılama → hedef vektörü → PX4 takip modu zinciri hareketli insan hedefiyle birlikte çalıştırılır; ortak senaryo çatıda spec'lenir (Çatı). Doğrulama: senaryo tekrarlanabilir şekilde çalışır, sonuçlar başarı kriterlerine göre ölçülür ve kullanılan commit'ler iki repoda aynı `tez-*` tag'iyle işaretlenir. `L`
19. [ ] Hata senaryoları (SITL) — Hedef kaybı, geçersiz/eski veri, haberleşme gecikmesi ve kesintisi senaryoları uçtan uca zincirde test edilir (Çatı). Doğrulama: her senaryoda sistemin ICD'de tanımlı davranışa geçtiği loglardan ölçülerek gösterilir; başarısız durumlar sınırlama olarak kaydedilir. `M`
20. [ ] Yer istasyonunda takip bilgisinin izlenmesi (simülasyon) — Telemetri QGroundControl'de, kamera görüntüsü ve takip bilgisi (algılama kutusu, hedef vektörü, durum) yer istasyonu bilgisayarında izlenir (Vision). Doğrulama: uçtan uca SITL senaryosu sırasında görüntü ve takip bilgisi canlı olarak gözlemlenir. `S`

## Aşama 7: Donanım entegrasyonu

21. [ ] Eksik donanım kararları ve gerçek kütle — RC kumanda sistemi ve batarya seçilir, seçim gerekçeleri belgelenir; Pi 5, Hailo ve kamera dahil aracın gerçek kütlesi ölçülür ve simülasyon modeline yansıtılır (Çatı). Doğrulama: seçimler ve ölçülen kütle belgelenir; güncellenmiş modelle uçtan uca SITL senaryosu yeniden geçer. `S`
22. [ ] Donanım montajı ve temel uçuş — X500 V2 montajı, sensör kalibrasyonları ve RC failsafe ayarı yapılır; Pi 5, Hailo ve Camera Module 3 araca yerleştirilir (Autopilot). Doğrulama: takip modu kullanılmadan, güvenli alanda manuel/konum tutma uçuşu yapılır ve ULog kaydı incelenir. `M`
23. [ ] Pi ↔ Pixhawk bench entegrasyonu — Gerçek Pixhawk 6C ile Pi 5 arasında seçilen haberleşme yöntemi kurulur; Hailo ile on-board algılama ve hedef vektörü gönderimi pervanesiz çalıştırılır (Vision). Doğrulama: pervaneler takılı değilken mesajlar PX4'te alınır, uçtan uca gecikme ve frekans ölçülür, veri kesintisinde mod davranışı gözlenir. `M`
24. [ ] Yer istasyonuna görüntü aktarımı — Görüntü aktarımı için donanım ve yöntem seçilir, gerekçesiyle belgelenir ve uygulanır (Vision). Doğrulama: bench ve uçuşta görüntü ve takip bilgisi yer istasyonunda izlenir; gecikme ve kopma durumları ölçülür. `M`
25. [ ] Kontrollü takip uçuş testleri — Kademeli test: önce takip modu kapalıyken uçuşta algılama, sonra güvenli alanda düşük hızla takip; her uçuş öncesi test planı ve güvenlik kontrolü yapılır (Çatı). Doğrulama: uçuş logları ve Vision logları başarı kriterlerine göre analiz edilir; kullanılan commit'ler `tez-*` tag'iyle işaretlenir. `L`

## Aşama 8: Veri toplama ve model eğitimi

26. [ ] Uçuşlarda görüntü verisi toplama — Pi üzerinde uçuş sırasında kamera görüntüsünü, zaman damgası ve gerekli uçuş bilgileriyle (ör. irtifa, attitude) birlikte kaydeden özellik geliştirilir; kayıt formatı, çözünürlük/FPS ve depolama belirlenir. Görüntüye giren kişilerin izni alınır ve nasıl alındığı belgelenir. Kayıtlar repoya değil ortak depolama alanına konur (Vision). Doğrulama: bench'te ve en az bir uçuşta kayıt alınır; kaydın algılama/takip FPS'ini ve gecikmesini ne kadar etkilediği ölçülür. `M`
27. [ ] Veri etiketleme ve veri seti oluşturma — Etiketleme aracı ve formatı seçilir; etiketleme kuralları (neyin "insan" sayılacağı, kısmen görünen ve çok küçük hedefler) yazılır; veri seti eğitim/doğrulama/test olarak uçuş bazında ayrılır (aynı uçuşun kareleri iki kümeye birden girmez) ve sürümlenir (Vision). Doğrulama: veri seti istatistikleri (görüntü ve kutu sayısı, irtifa/ışık koşulları) belgelenir; etiketlerden bir örneklem ikinci bir kişi tarafından kontrol edilir. `M`
28. [ ] Model eğitimi — Başlangıç modeli (madde 7) kendi veri setimizle (gerekirse açık veri setleriyle birlikte) eğitilir; eğitim ortamı, kodun yeri, hiperparametreler ve tekrarlanabilirlik bilgileri (seed, araç sürümleri, veri seti sürümü) belgelenir (Vision). Doğrulama: aynı test kümesinde başlangıç modeliyle karşılaştırmalı doğruluk ölçümleri (ör. mAP, precision, recall) raporlanır; aşırı öğrenme (overfitting) kontrol edilir. `L`
29. [ ] Eğitilen modelin araca alınması ve karşılaştırma — Eğitilen model Hailo formatına dönüştürülüp Pi 5'e alınır; SITL kayıtları ve kontrollü uçuş testleri yeni modelle tekrarlanır (Vision). Doğrulama: Pi 5 + Hailo'da FPS/gecikme ve dönüşüm sonrası doğruluk ölçülür; takip sonuçları başlangıç modeliyle başarı kriterlerine göre karşılaştırılır; kullanılan commit'ler `tez-*` tag'iyle işaretlenir. `M`

## Aşama 9: Değerlendirme ve raporlama

30. [ ] Sonuçların değerlendirilmesi — SITL ve uçuş ölçümleri başarı kriterleriyle karşılaştırılır; simülasyon ile gerçek uçuş arasındaki farklar, sınırlamalar ve gelecek çalışmalar belirlenir (Çatı). Doğrulama: her iddianın dayandığı test ve log kaydı belirtilmiş bir değerlendirme dokümanı hazırlanır. `M`
31. [ ] Lisans tezi raporu — Mimari, yöntemler, veri seti ve model eğitimi, coordinate frame'ler, ICD, kontrol algoritması, PX4 entegrasyonu, testler, sonuçlar ve sınırlamalar mevcut dokümantasyondan derlenerek tez yazılır (Çatı). Doğrulama: planlanan / uygulanan / test edilen / doğrulanan işler raporda ayrı gösterilir ve danışman incelemesinden geçer. `XL`

> Notlar
> - Sıralama teknik bağımlılığa ve ürün tanımındaki aşamalara göredir. Bağımsız maddeler (ör. 7–9, 13) paralel yürütülebilir; ancak ICD'ye (madde 5) dayanan işler ICD onaylanmadan başlamaz.
> - **Ortak spec'ler (madde 3, 4, 5) henüz yazılmayacak** (2026-10-25): gereksinimler netleştikçe ileride yazılacak. Bunlara dayanan maddelerde (ör. 10, 11, 12, 16) çalışılabilir; frame, eksen, birim ve mesaj gibi konular o maddenin spec'inde "Varsayımlar" başlığı altında açıkça yazılır ve ortak spec yazılınca ona göre güncellenir.
> - Aşama 8'in uçuş verisi, Aşama 7'deki uçuşlarda (madde 22 ve 25) toplanır; kayıt özelliği (madde 26) bu uçuşlardan önce hazır olmalıdır.
> - Her madde uçtan uca ve doğrulanabilir bir sonuçtur (SITL'de, bench'te veya uçuşta). Bir maddenin kodlanmış olması tamamlandığı anlamına gelmez; açıklamadaki doğrulama yapılmış olmalıdır.
> - İki repoyu birden ilgilendiren işler (mimari, coordinate frame'ler, ICD, uçtan uca SITL senaryosu) çatı repoda `agent-os/specs/` altında spec'lenir; görevler ilgili alt repolarda ayrı PR'larla uygulanır.
> - Yeni PX4 dosyası, parametre, modül veya model adları bu planda verilmez; ilgili spec'te kararlaştırılır.
> - Efor ölçeği: `XS` = 1 gün, `S` = 2-3 gün, `M` = 1 hafta, `L` = 2 hafta, `XL` = 3+ hafta.
> - Maddeler, ilgili PR merge edildikten sonra yalnızca repo sorumlusu tarafından `[x]` olarak işaretlenir.
