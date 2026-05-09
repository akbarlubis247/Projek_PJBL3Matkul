# API Flutter Campus Lapor

Base URL emulator Android:

```text
http://10.0.2.2:8000/api
```

Base URL browser/lokal:

```text
http://127.0.0.1:8000/api
```

Untuk endpoint yang butuh login, kirim header:

```text
Authorization: Bearer TOKEN_DARI_LOGIN
Accept: application/json
```

## Auth Civitas

### Register

`POST /auth/register`

```json
{
  "campus_id": 1,
  "name": "Budi Santoso",
  "email": "budi@apps.ipb.ac.id",
  "username": "budi123",
  "password": "password",
  "password_confirmation": "password"
}
```

### Login

`POST /auth/login`

```json
{
  "email": "siti432@apps.ipb.ac.id",
  "password": "password"
}
```

### Profil Login

`GET /me`

### Update Profil

`PATCH /me`

```json
{
  "name": "Adam Terry",
  "username": "adamterry15",
  "email": "adamterry15@apps.ipb.ac.id"
}
```

### Logout

`POST /auth/logout`

## Kampus

### Kampus Yang Sudah Disetujui

`GET /campuses`

### Lokasi Kampus

`GET /campuses/{campus_id}/locations`

## Laporan

Kategori:

- `lost_item`
- `damaged_facility`

Status:

- Barang hilang: `lost`, `found`
- Fasilitas rusak: `damaged`, `repaired`

### Semua Laporan Di Kampus User

`GET /reports`

Filter opsional:

```text
GET /reports?category=lost_item&status=lost&location_id=1
```

Search:

```text
GET /reports?q=tumbler
```

### Laporan Milik User

`GET /reports/mine`

### Detail Laporan

`GET /reports/{id}`

### Buat Laporan

`POST /reports`

Gunakan `multipart/form-data` jika mengirim foto.

Field:

```text
category=lost_item
campus_location_id=1
title=Botol tumbler hilang
description=Hilang di sekitar gedung C1
tags[0]=Botol
tags[1]=Tumbler
image=(file opsional)
```

Ukuran foto maksimal: 5 MB.

### Update Status Laporan Milik User

`PATCH /reports/{id}/status`

```json
{
  "status": "found"
}
```

## Notifikasi

### List Notifikasi

`GET /notifications`

### Tandai Sudah Dibaca

`PATCH /notifications/{id}/read`

## Chat

### List Chat

`GET /chats`

### Buat Chat Baru

`POST /chats`

```json
{
  "user_id": 11,
  "message": "Barangnya ketemu di CB Prog."
}
```

### Detail Chat

`GET /chats/{conversation_id}`

### Kirim Pesan

`POST /chats/{conversation_id}/messages`

```json
{
  "message": "Oke terima kasih infonya."
}
```
