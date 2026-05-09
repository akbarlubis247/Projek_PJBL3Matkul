# Campus Lapor Projects

Folder ini berisi dua project terpisah:

## Laravel Web/Admin

```text
kampus-lapor-web
```

Isi:

- Web admin kampus
- Web superadmin
- API backend untuk mobile Flutter
- Database MySQL `kampus_lapor`

Jalankan:

```bash
cd kampus-lapor-web
php artisan serve --host=127.0.0.1 --port=8000
```

## Flutter Mobile Civitas

```text
kampus_lapor_mobile
```

Isi:

- Aplikasi mobile untuk civitas kampus
- Nanti dipakai untuk login, laporan barang hilang, dan laporan fasilitas rusak

Jalankan:

```bash
cd kampus_lapor_mobile
flutter run
```

## API Untuk Flutter

Dokumentasi endpoint ada di:

```text
kampus-lapor-web/API_FLUTTER.md
```

Base URL Android emulator:

```text
http://10.0.2.2:8000/api
```

Base URL browser/lokal:

```text
http://127.0.0.1:8000/api
```
