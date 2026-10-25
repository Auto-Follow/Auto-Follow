# Ürün Misyonu

Son güncelleme: 2026-10-25

> Bu dosya, kullanıcının ürün tanımına (Follow Me İHA — Product Tanımı) dayanır. Ürün planını yalnızca repo sorumlusu, ilgili PR merge edildikten sonra günceller.

## Pitch

**Auto-Follow**, hareket eden bir insanı kamera görüntüsü üzerinden algılayıp belirli bir mesafeden otonom olarak takip eden bir İHA sistemidir. Bir insan algılama modelinin çıktısını geometrik hesaplamalarla İHA'nın body coordinate frame'ine aktaran ve bu bilgiyi PX4 Autopilot'a entegre edilmiş özel bir takip modunda kullanan bir lisans tezi prototipidir.

Sistem; Holybro X500 V2 gövde, Pixhawk 6C (PX4 v1.17.0), Raspberry Pi 5, Hailo AI Kit ve Raspberry Pi Camera Module 3 üzerine kurulur. Önce simülasyonda (Gazebo Harmonic, SITL), ardından kontrollü donanım testlerinde doğrulanır ve bütün süreç akademik olarak raporlanır.

### Proje ve repo adı hakkında
Ürün bir "Follow Me İHA" olarak tanımlanır; ancak proje ve repo adı bilinçli olarak daha genel seçilmiştir: **Auto-Follow**. Gerekçe: proje yalnızca takip modundan ibaret değildir; uçuşlarda veri toplanması ve insan algılama modelinin eğitilmesi de projenin parçasıdır ve çalışma ileride bu yönde, bu tezin kapsamının ötesine taşınabilir.

## Kullanıcılar

### Birincil kullanıcılar

- **Takip edilen / çekim yapılan kişi:** Hareket ederken aynı anda İHA'yı uçurmak ve çekim yapmak zorunda kalmadan, kendisini otomatik takip eden bir İHA isteyen kişi.
- **Tez değerlendiricileri ve akademik okuyucular:** Sistemin nasıl tasarlandığını, hangi koşullarda test edildiğini, neyi başardığını ve sınırlamalarını teknik olarak savunulabilir bir raporda görmek isteyen öğretim üyeleri ve jüri.

### Kullanıcı profilleri

**Hareket eden kullanıcı**
- **Bağlam:** Yürüyen, koşan veya bir aktivite yapan ve kendisinin görüntülenmesini isteyen kişi.
- **Sorunlar:** Aynı anda hareket etmek, İHA'yı kumanda etmek ve çekimi yönetmek zordur; dikkat bölünür.
- **Hedefler:** İHA'nın kendisini kamerada tutarak belirli bir mesafeden güvenli biçimde takip etmesi; görüntünün ve takip durumunun yer istasyonunda izlenebilmesi.

**Tez değerlendiricisi**
- **Bağlam:** Projeyi lisans tezi kapsamında değerlendiren akademik jüri.
- **Sorunlar:** "Çalışıyor" iddiasının neye dayandığı, hangi koşullarda ölçüldüğü ve sınırlamaların ne olduğu belirsiz kalabilir.
- **Hedefler:** Planlanan, uygulanan, test edilen ve doğrulanan işlerin açıkça ayrıldığı; teknik kararların gerekçeli, sonuçların ölçülebilir olduğu bir rapor.

**Geliştirici öğrenciler ve Claude ajanları (dolaylı kullanıcı)**
- **Bağlam:** 4 lisans öğrencisi ve spec yazmadan önce bu dosyayı okuyan Claude ajanları.
- **Hedefler:** Görüntü işleme ve kontrol tarafını, ortak bir arayüz sayesinde birbirinden bağımsız geliştirip sonra birlikte test edebilmek.

## Problem

### Hareket eden kişinin kendini görüntülemesi zor
Bir kişinin aynı anda hareket etmesi, uçuş gerçekleştirmesi ve çekim yapması zordur. Manuel kumanda dikkat ve beceri ister; kişi hem aktiviteye hem de İHA'ya odaklanamaz.

**Çözümümüz:** Kamera görüntüsünden insanı algılayan, hedefin İHA'ya göre konumunu hesaplayan ve PX4 içindeki özel bir takip modu ile hedefi otonom olarak takip eden bir İHA.

### Görüntü bilgisi tek başına uçuş kontrolü için yeterli değil
Algılama modeli yalnızca görüntü üzerindeki pixel coordinates bilgisini verir. Uçuş kontrolü ise koordinat sistemi, eksen yönleri ve birimleri belli bir hedef bilgisine ihtiyaç duyar.

**Çözümümüz:** Camera intrinsic parameters, camera frame ↔ body frame dönüşümü ve gerektiğinde İHA attitude bilgisi kullanılarak hedefin İHA'ya göre konumunu/doğrultusunu ifade eden, frame'i ve birimleri açıkça tanımlanmış bir hedef vektörü üretmek.

### Akademik olarak savunulabilir sonuç gerekiyor
Bir özelliğin kodlanmış olması, çalıştığının kanıtı değildir. Ölçülmemiş performans iddiaları tezde savunulamaz.

**Çözümümüz:** Simülasyon öncelikli doğrulama, tanımlı test senaryoları (hedef kaybı, geçersiz veri, gecikme dahil), log tabanlı ölçüm ve her teknik kararın gerekçesiyle belgelenmesi.

## Farklılaştırıcılar

> Bu bölüm bir tez prototipinin tasarım tercihlerini anlatır; rakip ürünlerle sayısal bir karşılaştırma iddiası içermez.

### Uçuş üzerinde (on-board) çıkarım
İnsan algılama, İHA üzerindeki Raspberry Pi 5 ve Hailo AI Kit ile yapılması hedeflenir; algılama için yer istasyonuna görüntü göndermek gerekmez. Hailo yazılım yığınının Pi OS Trixie üzerinde çalıştığı henüz doğrulanmamıştır; bu, yol haritasının erken bir adımıdır.

### PX4'e entegre özel takip modu
PX4 sıfırdan yazılmaz; sabit sürüm (v1.17.0) üzerine projeye özgü bir takip modu eklenir. Böylece takip davranışı, PX4'ün mevcut kontrol zinciri ve failsafe mekanizmalarıyla birlikte çalışır. Entegrasyonun nasıl yapılacağı henüz seçilmemiştir.

### Açıkça tanımlı görüntü işleme ↔ kontrol arayüzü
Hedef vektörünün anlamı, coordinate frame'i, eksen/işaret kuralları, birimleri, güncelleme frekansı, zaman damgası ve geçersiz veri davranışı ortak bir arayüz tanımında (ICD) yazılı olarak belirlenir. Bu sayede iki taraf bağımsız geliştirilip birlikte test edilebilir.

### Simülasyon öncelikli ve ölçülerek doğrulama
Her bileşen önce Gazebo Harmonic + PX4 SITL ortamında doğrulanır; donanıma yalnızca simülasyonda doğrulanan bileşenlerle geçilir. Sonuçlar loglardan ölçülerek raporlanır ve sabit araç sürümleri sayesinde tekrarlanabilir olur.

## Temel Özellikler

### Çekirdek özellikler
- **İnsan algılama:** Kamera görüntüsündeki kişi bir insan algılama modeli ile belirlenir. Önce hazır modeller ve açık veri setleriyle yapılan deneme eğitimleri kullanılır; sonra ekibin kendi veri setiyle eğittiği model kullanılır (model henüz seçilmedi).
- **Veri toplama ve model eğitimi:** Uçuşlarda kamera görüntüsü kaydedilir, ekip bu görüntüleri etiketleyerek kendi veri setini oluşturur ve insan algılama modelini bu veri setiyle eğitir. Eğitilen model, başlangıç modeliyle ölçülerek karşılaştırılır.
- **Hedef konumlandırma:** Hedefin piksel konumu, kamera parametreleri ve koordinat dönüşümleriyle İHA'nın body frame'inde bir hedef vektörüne çevrilir.
- **Otonom takip modu:** PX4'e entegre edilen özel mod, hedef vektörünü kullanarak İHA'yı hedefi belirli bir mesafeden takip edecek şekilde yönlendirir.
- **Güvenli davranış:** Hedef kaybolduğunda, veri geçersiz veya eski olduğunda ya da haberleşme gecikmesinde sistem tanımlı ve güvenli bir davranışa geçer.

### İzleme özellikleri
- **Telemetri izleme:** Uçuş durumu ve telemetri QGroundControl üzerinden izlenir.
- **Görüntü ve takip bilgisinin izlenmesi:** Kamera görüntüsü ve takip bilgileri yer istasyonundaki bilgisayarlarda gözlemlenebilir hâle getirilir (aktarım yöntemi ve donanımı henüz seçilmedi).

### Doğrulama ve raporlama özellikleri
- **Simülasyon ortamı:** Hareketli insan hedefi içeren Gazebo Harmonic senaryosunda uçtan uca takip testi.
- **Ölçüm ve analiz:** ULog kayıtları ve analiz araçlarıyla başarı kriterlerine karşı ölçülmüş sonuçlar.
- **Tez raporu:** Mimari, yöntemler, kararlar, testler, sonuçlar ve sınırlamaları içeren lisans tezi.

## Kapsam dışı

- PX4'ü sıfırdan yazmak veya PX4 sürümünü yükseltmek (PX4 v1.17.0'da kalıcı olarak kilitlidir).
- Yeni MAVLink mesajı veya dialect tanımlamak (haberleşme, PX4 v1.17.0'ın zaten desteklediği mesajlarla yapılır).
- Ticari ürün düzeyinde güvenilirlik, sertifikasyon veya genel kullanıcılara dağıtım.

## Başarı ölçütü ve çalışma ilkeleri

**Başarı ölçütü:** Yalnızca takip modunun geliştirilmesi değil; sistemin tanımlı koşullarda test edilmesi, sonuçlarının ölçülmesi, sınırlamalarının ortaya konması ve bütün sürecin lisans tezi kapsamında teknik olarak savunulabilir biçimde raporlanmasıdır. Ölçülebilir başarı kriterleri (takip mesafesi, toleranslar vb.) henüz sayısal olarak belirlenmemiştir; yol haritasının ilk adımıdır.

**Çalışma ilkeleri:**
- **Planlanan, uygulanan, test edilen ve doğrulanan** işler birbirinden açıkça ayrılır. Kodlanmış olmak, çalıştığının kanıtı değildir.
- Test edilmemiş veya doğrulanmamış sonuçlar başarılı olarak sunulmaz; performans iddiaları yalnızca ölçülen verilerin desteklediği kadar yapılır.
- Teknik kararlar gerekçeleriyle belgelenir; kod değişikliğiyle birlikte ilgili dokümantasyon da güncellenir.
- Henüz belirlenmemiş donanım ve yöntemler (algılama modeli, eğitim çerçevesi ve ortamı, etiketleme aracı, haberleşme yöntemi, kontrol algoritması, PX4 entegrasyon yaklaşımı, RC, batarya, görüntü aktarımı vb.) kesinleşmiş gibi sunulmaz.
- Görüntü işleme (`Vision` reposu) ile kontrol (`Autopilot` reposu) arasındaki sorumluluk sınırı korunur; ortak arayüz çatı repoda (`agent-os/specs/`) tanımlanır ve iki taraf ona uyar.
- İş, `main` üzerinde değil bir özellik branch'inde küçük ve sık adımlarla commit edilir (ör. her spec aşamasından ve her tamamlanan görev grubundan sonra); böylece yanlış yöne gidildiğinde daha önceki çalışan bir duruma dönülebilir.
- Commit mesajları açıklayıcıdır ve ilgili spec'e/görev grubuna atıf yapar.
- Karşılaşılan hatalar, çözüm adımları ve önemli kararlar kaydedilir; her çalışma tezin çıktılarıyla ilişkilendirilir.
