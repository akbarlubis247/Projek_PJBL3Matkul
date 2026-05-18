# Kampus Lapor

Kampus Lapor adalah aplikasi pelaporan kampus berbasis Laravel dan Flutter. Aplikasi ini dibuat untuk membantu civitas kampus melaporkan barang hilang, barang ditemukan, fasilitas rusak, serta melakukan chat dengan admin kampus.

Project ini terdiri dari dua bagian:

- `kampus-lapor-web` untuk web admin dan superadmin.
- `kampus_lapor_mobile` untuk aplikasi mobile civitas kampus.

## Fitur Utama

Web admin:

- Login admin kampus.
- Dashboard laporan.
- Manajemen barang hilang dan barang ditemukan.
- Manajemen fasilitas rusak dan fasilitas sudah diperbaiki.
- Chat dengan civitas kampus.
- Manajemen data kampus, daftar lokasi, dan data user.
- Export laporan PDF dan Excel.

Web superadmin:

- Login superadmin.
- Seleksi pendaftaran admin kampus.
- Melihat data admin yang sudah disetujui.

Mobile civitas:

- Login dan daftar akun civitas.
- Akun baru civitas menunggu persetujuan admin.
- Membuat laporan barang hilang atau fasilitas rusak.
- Upload foto laporan.
- Melihat status laporan.
- Chat dengan admin atau civitas lain.
- Profil, history laporan, update akun, dan logout.

## Teknologi

- Laravel 12
- PHP 8.2
- MongoDB lokal
- Flutter
- Dart
- Tailwind/CSS custom
- Laravel DomPDF
- Laravel Excel / Maatwebsite

## Database

Project ini menggunakan MongoDB lokal dengan nama database:

```text
kampus_lapor
```

Pastikan MongoDB sudah berjalan di:

```text
127.0.0.1:27017
```

Bisa dicek lewat MongoDB Compass.

## Akun Demo

Seeder menyediakan akun demo berikut:

| Role | Username | Password |
|---|---|---|
| Superadmin | `superadmin1` | `superadmin123` |
| Admin | `admin1` | `admin123` |
| Civitas Mobile | `civitas1` | `civitas123` |

## Cara Menjalankan Web Laravel

Masuk ke folder web:

```bash
cd kampus-lapor-web
```

Install dependency:

```bash
composer install
```

File `.env` sudah disediakan untuk demo lokal. Kalau ingin membuat ulang key:

```bash
php artisan key:generate
```

Jalankan seeder akun demo:

```bash
php artisan db:seed
```

Jalankan server:

```bash
php artisan serve
```

Buka web:

```text
http://127.0.0.1:8000
```

## Cara Menjalankan Mobile Flutter

Masuk ke folder mobile:

```bash
cd kampus_lapor_mobile
```

Install dependency:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Jika menjalankan Flutter Web:

```bash
flutter run -d chrome
```

Pastikan server Laravel tetap berjalan di port `8000`, karena mobile mengambil data dari API Laravel.

## Endpoint API Utama

Beberapa endpoint yang tersedia:

- `POST /api/auth/login/super-admin`
- `POST /api/auth/login/admin-kampus`
- `POST /api/auth/login/civitas`
- `POST /api/kampus/register`
- `POST /api/civitas/register`
- `GET /api/super-admin/kampus`
- `PATCH /api/super-admin/kampus/{id}/status`
- `GET /api/admin-kampus/civitas`
- `PATCH /api/admin-kampus/civitas/{id}/status`
- `POST /api/laporan-barang`
- `GET /api/laporan-barang`
- `GET /api/laporan-barang/{id}`
- `PATCH /api/laporan-barang/{id}/status`
- `POST /api/laporan-fasilitas`
- `GET /api/laporan-fasilitas`
- `PATCH /api/laporan-fasilitas/{id}/status`
- `POST /api/chats`
- `GET /api/chats/{participantId}`
- `GET /api/notifikasi`
- `PATCH /api/notifikasi/{id}/read`

## Export Laporan

Admin bisa export laporan dari dashboard atau halaman laporan:

- PDF barang hilang
- Excel barang hilang
- PDF fasilitas rusak
- Excel fasilitas rusak

PDF menggunakan `barryvdh/laravel-dompdf`.

Excel menggunakan `maatwebsite/excel`.

## Troubleshooting

Jika muncul error:

```text
No application encryption key has been specified
```

Jalankan:

```bash
cd kampus-lapor-web
php artisan key:generate
php artisan optimize:clear
```

Jika halaman tidak bisa connect ke MongoDB:

- Pastikan MongoDB sudah running.
- Pastikan database bernama `kampus_lapor`.
- Pastikan `.env` berisi:

```env
DB_CONNECTION=mongodb
DB_URI=mongodb://127.0.0.1:27017
DB_DATABASE=kampus_lapor
MONGODB_DATABASE=kampus_lapor
```

Jika mobile tidak bisa login atau daftar:

- Pastikan Laravel berjalan di `http://127.0.0.1:8000`.
- Pastikan akun civitas sudah disetujui admin.
- Pastikan username dan password sesuai akun demo atau akun yang sudah dibuat.

## Catatan

Project ini dibuat untuk kebutuhan demo sistem pelaporan kampus. Untuk deployment production, sebaiknya jangan menyimpan `.env` asli di repository publik dan ganti `APP_KEY`, konfigurasi database, serta credential lain sesuai server production.
