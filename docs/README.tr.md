# Bitwarden Safari Touch ID — hedefli Anahtar Zinciri izni

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## Yönlendirmeli kurulum

[ZIP](https://github.com/Degisik/bitwarden_biometric-popup-fix/releases/download/v1.0.0/bitwarden-biometric-installer-v1.0.0.zip) · [Source](../install.command) · [SHA-256](../INSTALLER-SHA256SUMS)

ZIP’i indirip aç; kaynak kodunu okuduktan sonra Safari’yi kapat ve `install.command` dosyasına çift tıkla. Betik önce kontrol eder; değişiklik için `APPLY` yazmanı ister. `sudo` gerekmez. Apple Swift araçları gerekir. macOS engellerse korumaları kapatma; elle uygulama yöntemini kullan veya destek al.

## Hızlı kurulum

Safari’yi ⌘Q ile kapat. [Betiğin tamamını oku](../fix.command), ardından [fix.command dosyasını indir](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) ve İndirilenler’e kaydet. Apple Swift araçları gerekir; yoksa önce `xcode-select --install` çalıştır. Tek hesap ve varsayılan Keychain düzeni içindir.

Önce yalnız kontrol:

```sh
cd ~/Downloads
bash fix.command
```

Önizleme yalnız masaüstü → masaüstü + Safari bileşeni değişikliğini gösteriyorsa uygula:

```sh
bash fix.command --apply
```

Gerekirse parolanı yalnız macOS penceresine gir. `save_acl=0` sonrasında Safari’yi açıp Touch ID’yi dene. Betik kaynak kodu açık bir metindir; ağ isteği, `sudo` veya gizli anahtar okuması yapmaz. Kalıcı izin değişikliği yalnız `--apply` ile olur. Beklenmedik sonuçta dur. [Ayrıntılar ve dosya özeti doğrulaması](../README.md#quick-setup).

---

Masaüstünde Touch ID çalışırken Safari sürekli `Bitwarden_biometric` izni istiyorsa bu rehber, bir Mac’te başarıyla uygulanan çözümü anlatır. Resmî Bitwarden düzeltmesi değildir. macOS/Safari 26.5.2 ve Bitwarden 2026.8.0 üzerinde kullanıcı başarıyı doğruladı.

Sorunlu kaydın anahtar okuma izin listesinde masaüstü uygulaması vardı, gömülü Safari bileşeni yoktu. Yalnız `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex` eklendi; diğer yetkiler korundu. Bu, hassas kayda kalıcı erişim verir. Kasa anahtarı okunmaz veya değiştirilmez; tüm uygulamalara izin verilmez.

Arayüzde uygulama paketinin içine girip `.appex` seçmek kullanıcıda mümkün olmadı. Bu nedenle doğrulanmamış bir arayüz tarifi vermiyoruz.

1. Safari’yi ⌘Q ile kapat. Ana parolanla normal erişimini koru.
2. [İngilizce rehberdeki](../README.md#before-running) Apple Swift araçları ve kod imzası kontrollerini yap. Eksikse yalnız Apple’ın geliştirme araçları gerekir; üçüncü taraf indirme yoktur.
3. [Kaynağın tamamını](../README.md#review-and-create-the-local-source) oku ve gösterilen blokla yerel geçici dosyayı oluştur. Aynı Terminal oturumunu kullan.
4. Önce `--apply` olmadan çalıştır. Beklenen sonuç `Dry run; unchanged`; mevcut listede yalnız masaüstü olmalı. Beklenmedik izinler, birden fazla eşleşen kayıt/hesap veya özel Keychain düzeninde dur.
5. Kapsamı kabul ediyorsan aynı komutu `--apply` ile çalıştır. Gerekirse Mac/Keychain parolanı yalnız macOS penceresine gir. `sudo` gerekmez. Parola reddedilirse dur; bu yöntem parola kurtarmaz.
6. `save_acl=0` sonrasında komutu yeniden `--apply` olmadan çalıştır. İki yol ve `Already present; no changes` görülmeli. Safari’yi açıp birkaç kilitleme/açma denemesi yap.

Geri alma: Anahtar Zinciri Erişimi → ilgili kayıt → Erişim Denetimi içinde yalnız yolu `safari.appex` olan eklenmiş girdiyi kaldır; masaüstünü tut. Bu GUI geri alma adımı ayrıca test edilmedi. Girdileri ayırt edemiyorsan silme, Bitwarden desteğine başvur. Kod veya ikili dosya indirmen gerekmez; tüm kod sayfada görünür. Bir cihazdaki başarı her benzer hatanın aynı nedenle oluştuğunu göstermez. Çeviriler yapay zekâ desteğiyle hazırlandı; ortak kodun teknik kaynağı İngilizce metindir.
