# Tarify

Tarify, kullanıcıların kendi tariflerini kaydedebileceği, düzenleyebileceği ve kişisel tarif arşivi oluşturabileceği Flutter tabanlı mobil uygulamadır.

Bu uygulama geliştirilirken amaç sadece tarif ekleyip listeleyen basit bir sistem oluşturmak değil; aynı zamanda kullanıcıya daha rahat bir deneyim sunan, işlevsel ve düzenli bir mobil uygulama ortaya çıkarmaktı.


## Uygulama Ne İşe Yarar?

Tarify ile kullanıcı:

- kendi tariflerini ekleyebilir,
- tarifleri düzenleyebilir veya silebilir,
- tariflere görsel ekleyebilir,
- favori tariflerini ayırabilir,
- tarifleri kategori ve zorluk seviyesine göre filtreleyebilir,
- daha önce görüntülediği tariflere hızlıca ulaşabilir,
- tarif adımlarını sesli olarak dinleyebilir,
- porsiyon miktarını değiştirerek malzeme miktarlarını güncelleyebilir.

Bu yönüyle uygulama, klasik bir tarif defterinin dijital ve daha kullanıcı dostu bir versiyonu olarak tasarlanmıştır.


## Projede Uygulanan Temel Özellikler

### Tarif Yönetimi
- Tarif ekleme
- Tarif düzenleme
- Tarif silme
- Silme öncesi onay penceresi

### Listeleme ve Filtreleme
- Tarifleri ana ekranda listeleme
- Tarif adına göre arama
- Kategoriye göre filtreleme
- Zorluk seviyesine göre filtreleme
- Favori tarifleri ayrı görüntüleme
- Son görüntülenen tarifleri listeleme

### Tarif Detay Özellikleri
- Tarif görseli gösterme
- Hazırlık ve pişirme süresi bilgisi
- Zorluk seviyesi gösterimi
- Porsiyon bilgisi
- Porsiyon artırma / azaltma
- Elle porsiyon girme
- Porsiyona göre malzeme miktarlarını otomatik güncelleme
- Malzeme checklist sistemi
- Hazırlanan malzeme ilerleme çubuğu
- Adımlara süre etiketi ekleyebilme

### Sesli Okuma
- Tarif adımlarını sesli okuma
- Adıma tıklayarak ilgili adımdan okuma başlatma
- Okuma hızı ayarlama
- Sonraki / önceki adıma geçebilme

### Kullanıcı Deneyimi İçin Eklenen Detaylar
- Tamamen boş tariflerin kaydedilmemesi
- Eksik alanlarla tarif eklenebilmesi
- Düzenleme ekranından çıkarken kaydetme uyarısı
- Yanlışlıkla silmeyi önlemek için onay kutusu
- Son görüntülenen tariflerin ayrı mantıkla tutulması
- Uzun kullanımda yormayan sade arayüz tasarımı


##Uygulama Nasıl Geliştirildi?

Projede önce temel yapı kuruldu. İlk aşamada tarif ekleme, listeleme, düzenleme ve silme gibi temel işlemler geliştirildi. Daha sonra uygulama sadece çalışan bir sistem olmaktan çıkarılıp kullanıcı deneyimini güçlendirecek özelliklerle geliştirildi.

Geliştirme sürecinde özellikle şu noktalar üzerinde çalışıldı:

- verilerin uygulama kapandıktan sonra da saklanabilmesi,
- kullanıcıya uygun filtreleme ve arama mantığının oluşturulması,
- tarif detay sayfasının daha işlevsel hale getirilmesi,
- sesli okuma ve porsiyon hesaplama gibi ek özelliklerin sisteme uyumlu şekilde eklenmesi.

Bu süreçte proje adım adım geliştirilmiş, yeni özellikler eklenirken mevcut yapının bozulmamasına dikkat edilmiştir.


## Kullanılan Teknolojiler

- **Flutter**
- **Dart**
- **Provider**
- **SQLite (sqflite)**
- **Flutter TTS**
- **Image Picker**

---

## Proje Yapısı

Projede katmanlı yapı kullanılmıştır:

**Model -> DAO -> Repository -> ViewModel -> View**

### Katmanların Görevleri

- **Model:** Tarif verisini temsil eder.
- **DAO:** Veritabanı işlemlerini gerçekleştirir.
- **Repository:** Veri erişimini düzenler.
- **ViewModel:** İş mantığını ve ekran verilerini yönetir.
- **View:** Kullanıcı arayüzünü oluşturur.

Bu yapı sayesinde proje daha düzenli hale getirilmiş ve yeni özelliklerin eklenmesi kolaylaştırılmıştır.


## Geliştirme Sürecinde Öğrenilenler

Bu proje sayesinde:

- Flutter ile çok sayfalı uygulama geliştirme,
- yerel veritabanı ile veri saklama,
- katmanlı mimari kurma,
- ViewModel mantığı ile ekran ve veri yönetimini ayırma,
- kullanıcı deneyimi odaklı düşünme,
- özellikleri mevcut yapıyı bozmadan geliştirme

konularında pratik kazanılmıştır.

Bu proje aynı zamanda sadece çalışan bir uygulama geliştirmenin değil, kullanımı rahat ve mantıklı bir sistem tasarlamanın da önemli olduğunu göstermiştir.


## Ekran Görüntüleri
### ANA EKRAN GÖRÜNTÜLERİ
## Ana Sayfa
<img width="280" alt="Ana Sayfa" src="https://github.com/user-attachments/assets/966a00e3-e45c-4664-8ffc-14894f82c906" />
## Filtrelenmiş Ana Sayfa
<img width="280" alt="Filtrelenmiş Ana Sayfa" src="https://github.com/user-attachments/assets/6bb1a9a1-bf5a-46eb-8e7c-27f5ec3982f7" />
### TARİF DETAY SAYFASININ GÖRÜNTÜLERİ
## Tarif Detay Üst Bilgi Alanı
<img width="280" alt="Tarif Detay Üst Bilgi Alanı" src="https://github.com/user-attachments/assets/acad3761-b987-4e01-b1a5-bd2fbacbda01" />
## Porsiyon Ayarı
<img width="280" alt="Porsiyon Ayarı" src="https://github.com/user-attachments/assets/ec55040f-9f85-45b6-8e39-3d09f2ab691a" />
## Porsiyon Değişimi ve Checklist
<img width="280" alt="Porsiyon Değişimi ve Checklist" src="https://github.com/user-attachments/assets/9013a1ba-c40d-4ba8-aebd-625545b6443c" />
## Yapılış Adımları
<img width="280" alt="Yapılış Adımları" src="https://github.com/user-attachments/assets/8629fbbe-1c0d-417a-8144-13b59798ba7f" />
## Ek Notlar Kısmı
<img width="280" alt="Ek Notlar Kısmı" src="https://github.com/user-attachments/assets/f8225e58-2c3a-4f6c-b23e-88d0cb2143d1" />
### TARİF DÜZENLEME SAYFASININ GÖRÜNTÜLERİ
## Tarif Düzenleme Sayfası Üst Kısmı
<img width="280" alt="Tarif Düzenleme Sayfası Üst Kısmı" src="https://github.com/user-attachments/assets/b7282f1a-8042-4312-ac66-c20d889c551a" />
## Değişiklikleri Kaydetme Uyarısı
<img width="280" alt="Değişiklikleri Kaydetme Uyarısı" src="https://github.com/user-attachments/assets/d62dd519-cff4-42f9-92cb-7d2bdb966811" />
### TARİF EKLEME SAYFASI GÖRÜNTÜLERİ
## Tarif Ekleme Sayfası Üst Kısmı
<img width="280" alt="Tarif Ekleme Sayfası Üst Kısmı" src="https://github.com/user-attachments/assets/26a9c58e-2197-4f2d-bdc7-aa60dbd46e94" />
## Silme İşlemi için Uyarı Butonu
<img width="280" alt="Silme İşlemi İçin Uyarı Butonu" src="https://github.com/user-attachments/assets/b150c631-b696-447f-b11b-28e1ad94a0ee" />










