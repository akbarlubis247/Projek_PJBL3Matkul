<?php

use App\Http\Controllers\Api\KampusLaporApiController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/login/super-admin', [KampusLaporApiController::class, 'loginSuperAdmin']);
Route::post('/auth/login/admin-kampus', [KampusLaporApiController::class, 'loginAdminKampus']);
Route::post('/auth/login/civitas', [KampusLaporApiController::class, 'loginCivitas']);
Route::post('/kampus/register', [KampusLaporApiController::class, 'registerKampus']);
Route::post('/civitas/register', [KampusLaporApiController::class, 'registerCivitas']);

Route::get('/super-admin/kampus', [KampusLaporApiController::class, 'kampusList']);
Route::patch('/super-admin/kampus/{id}/status', [KampusLaporApiController::class, 'kampusStatus']);

Route::get('/admin-kampus/civitas', [KampusLaporApiController::class, 'civitasList']);
Route::patch('/admin-kampus/civitas/{id}/status', [KampusLaporApiController::class, 'civitasStatus']);
Route::get('/kampus/approved', [KampusLaporApiController::class, 'approvedKampus']);

Route::post('/laporan-barang', [KampusLaporApiController::class, 'storeLaporanBarang']);
Route::get('/laporan-barang', [KampusLaporApiController::class, 'laporanBarang']);
Route::get('/laporan-barang/{id}', [KampusLaporApiController::class, 'laporanDetail']);
Route::patch('/laporan-barang/{id}/status', [KampusLaporApiController::class, 'laporanStatus']);
Route::patch('/laporan-barang/{id}', [KampusLaporApiController::class, 'laporanUpdate']);

Route::post('/laporan-fasilitas', [KampusLaporApiController::class, 'storeLaporanFasilitas']);
Route::get('/laporan-fasilitas', [KampusLaporApiController::class, 'laporanFasilitas']);
Route::get('/laporan-fasilitas/{id}', [KampusLaporApiController::class, 'laporanDetail']);
Route::patch('/laporan-fasilitas/{id}/status', [KampusLaporApiController::class, 'laporanStatus']);

Route::post('/chats', [KampusLaporApiController::class, 'storeChat']);
Route::get('/chats/{participantId}', [KampusLaporApiController::class, 'chatThread']);

Route::get('/notifikasi', [KampusLaporApiController::class, 'notifications']);
Route::patch('/notifikasi/{id}/read', [KampusLaporApiController::class, 'notificationRead']);
