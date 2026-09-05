# Bitwarden Safari Touch ID: izin Rantai Kunci yang terbatas

[English](../README.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [हिन्दी](README.hi.md) · [Español](README.es.md) · [العربية](README.ar.md) · [Français](README.fr.md) · [বাংলা](README.bn.md) · [Português](README.pt.md) · [Русский](README.ru.md) · [Bahasa Indonesia](README.id.md)

## Penyiapan cepat

Tutup Safari (⌘Q). [Baca kode](../fix.command), lalu [unduh fix.command](https://github.com/Degisik/bitwarden_biometric-popup-fix/raw/refs/heads/main/fix.command) ke Downloads. Memerlukan Swift Apple; jika belum ada, jalankan `xcode-select --install`. Hanya untuk satu akun dan pengaturan Rantai Kunci bawaan.

Periksa saja terlebih dahulu:

```sh
cd ~/Downloads
bash fix.command
```

Jika pratinjau hanya menambahkan komponen Safari ke aplikasi desktop:

```sh
bash fix.command --apply
```

Izinkan hanya melalui dialog macOS. Setelah `save_acl=0`, buka Safari dan coba Touch ID. Skrip berupa teks terbaca, tanpa jaringan, `sudo`, atau pembacaan rahasia. Hanya `--apply` menyimpan izin. Berhenti jika hasil tidak sesuai. [Detail dan integritas](../README.md#quick-setup).

---

Panduan ini menjelaskan solusi yang berhasil pada satu Mac: Touch ID bekerja di Bitwarden desktop, tetapi Safari terus meminta akses ke `Bitwarden_biometric`. Pengguna mengonfirmasi keberhasilan pada macOS/Safari 26.5.2 dan Bitwarden 2026.8.0. Ini bukan perbaikan resmi atau solusi untuk semua kasus.

Daftar akses memuat aplikasi desktop, tetapi tidak memuat `/Applications/Bitwarden.app/Contents/PlugIns/safari.appex`. Hanya komponen bertanda tangan tersebut yang ditambahkan; izin lain dipertahankan. Ini memberikan akses permanen ke item sensitif. Kode tidak membaca atau mengubah rahasia dan tidak mengizinkan semua aplikasi.

Pengguna tidak dapat memilih komponen di dalam paket `.app` melalui pemilih grafis. Karena itu, cara GUI tersebut tidak dinyatakan telah terverifikasi.

1. Tutup Safari dengan ⌘Q dan pastikan akses biasa menggunakan kata sandi utama tetap tersedia.
2. Ikuti [pemeriksaan alat Swift Apple dan tanda tangan](../README.md#before-running). Jika belum tersedia, gunakan hanya alat resmi Apple.
3. Baca [seluruh kode lalu buat berkas lokal](../README.md#review-and-create-the-local-source). Tidak ada kode yang diunduh; gunakan sesi Terminal yang sama.
4. Jalankan tanpa `--apply`. Hasil yang diharapkan adalah `Dry run; unchanged`, dengan hanya aplikasi desktop pada daftar awal. Berhenti jika ada beberapa item yang cocok, beberapa akun, pengaturan Rantai Kunci khusus, atau izin yang tidak sesuai.
5. Jika menyetujui perubahan, jalankan dengan `--apply`. Masukkan kata sandi Mac/Rantai Kunci hanya ke dialog macOS. Tidak perlu `sudo`. Jika otorisasi gagal, berhenti.
6. Setelah `save_acl=0`, jalankan lagi tanpa `--apply`: kedua jalur dan `Already present; no changes` harus muncul. Buka ulang Safari dan uji penguncian serta pembukaan beberapa kali.

Untuk membatalkan, buka Akses Rantai Kunci → item terkait → Kontrol Akses, lalu hapus hanya entri tambahan dengan jalur `safari.appex`; pertahankan entri desktop. Pembatalan melalui GUI ini belum diuji di sini. Jika entri tidak dapat dibedakan, hubungi dukungan Bitwarden; jangan hapus itemnya. Jangan bagikan kata sandi atau dump Rantai Kunci. Terjemahan dibantu AI dan belum ditinjau secara independen oleh penutur asli; bahasa Inggris adalah acuan teknis.
