<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;

Route::get('/login', [AuthController::class, 'login'])->name('login');
Route::post('/login', [AuthController::class, 'authenticate'])->name('login.authenticate');
Route::get('/daftar-admin', [AuthController::class, 'showAdminRegistration'])->name('admin-register');
Route::post('/daftar-admin', [AuthController::class, 'storeAdminRegistration'])->name('admin-register.store');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
Route::post('/mobile/register', [AuthController::class, 'mobileRegister'])->name('mobile.register');
Route::post('/mobile/login', [AuthController::class, 'mobileLogin'])->name('mobile.login');
Route::post('/mobile/reports', [DashboardController::class, 'mobileReportStore'])->name('mobile.reports.store');
Route::get('/mobile/reports/{reporterId}', [DashboardController::class, 'mobileReports'])->name('mobile.reports.index');
Route::post('/chat/send', [DashboardController::class, 'chatSend'])->name('chat.send');
Route::get('/chat/thread/{participantId}', [DashboardController::class, 'chatThread'])->name('chat.thread');
Route::post('/chat/thread/{participantId}/read', [DashboardController::class, 'chatMarkRead'])->name('chat.read');

Route::middleware(['role:admin'])->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/barang-hilang', [DashboardController::class, 'barangHilang'])->name('barang-hilang');
    Route::get('/barang-hilang/export/{format}', [DashboardController::class, 'exportBarang'])->name('barang-hilang.export');
    Route::patch('/barang-hilang/{id}/ubah-status', [DashboardController::class, 'ubahStatusBarang'])->name('barang-hilang.ubah-status');
    Route::patch('/barang-ditemukan/{id}/diambil', [DashboardController::class, 'tandaiBarangDiambil'])->name('barang-ditemukan.diambil');
    Route::delete('/barang-ditemukan/{id}', [DashboardController::class, 'hapusBarangDitemukan'])->name('barang-ditemukan.hapus');
    Route::get('/fasilitas-rusak', [DashboardController::class, 'fasilitasRusak'])->name('fasilitas-rusak');
    Route::get('/fasilitas-rusak/export/{format}', [DashboardController::class, 'exportFasilitas'])->name('fasilitas-rusak.export');
    Route::patch('/fasilitas-rusak/{id}/tandai', [DashboardController::class, 'tandaiDiperbaiki'])->name('fasilitas-rusak.tandai');
    Route::delete('/fasilitas-diperbaiki/{id}', [DashboardController::class, 'hapusFasilitasDiperbaiki'])->name('fasilitas-diperbaiki.hapus');
    Route::get('/pesan', [DashboardController::class, 'pesan'])->name('pesan');
    Route::post('/pesan/kirim', [DashboardController::class, 'kirimPesan'])->name('pesan.kirim');
    Route::get('/manajemen-kampus', [DashboardController::class, 'manajemenKampus'])->name('manajemen-kampus');
    Route::patch('/manajemen-kampus/user/{id}/toggle', [DashboardController::class, 'toggleUserStatus'])->name('manajemen-kampus.toggle-status');
    Route::post('/manajemen-kampus/lokasi', [DashboardController::class, 'simpanLokasi'])->name('manajemen-kampus.lokasi.simpan');
    Route::delete('/manajemen-kampus/lokasi/{id}', [DashboardController::class, 'hapusLokasi'])->name('manajemen-kampus.lokasi.hapus');
});

Route::middleware(['role:superadmin'])->group(function () {
    Route::get('/superadmin/seleksi-admin', [DashboardController::class, 'seleksiAdmin'])->name('superadmin.seleksi-admin');
    Route::patch('/superadmin/seleksi-admin/{id}', [DashboardController::class, 'ubahStatusAdmin'])->name('superadmin.seleksi-admin.ubah-status');
});
