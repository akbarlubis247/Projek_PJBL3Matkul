<?php

use App\Http\Controllers\Admin\ChatController as AdminChatController;
use App\Http\Controllers\Admin\CampusController;
use App\Http\Controllers\Admin\ReportController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Auth\WebAuthController;
use App\Http\Controllers\SuperAdmin\ApprovalController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/login');

Route::view('/login', 'auth.login')->name('login');
Route::post('/login', [WebAuthController::class, 'adminLogin'])->name('login.submit');
Route::view('/superadmin/login', 'auth.superadmin-login')->name('superadmin.login');
Route::post('/superadmin/login', [WebAuthController::class, 'superAdminLogin'])->name('superadmin.login.submit');
Route::view('/daftar', 'auth.register')->name('register');
Route::post('/daftar', [WebAuthController::class, 'registerAdmin'])->name('register.submit');
Route::post('/logout', [WebAuthController::class, 'logout'])->name('logout');

Route::middleware(['auth', 'role:admin'])->group(function (): void {
    Route::get('/barang-hilang', [ReportController::class, 'lostItems'])->name('lost-items');
    Route::get('/barang-hilang/laporan', [ReportController::class, 'lostItemReport'])->name('lost-item-report');
    Route::get('/fasilitas-rusak', [ReportController::class, 'damagedFacilities'])->name('damaged-facilities');
    Route::patch('/fasilitas-rusak/{report}/status', [ReportController::class, 'updateStatus'])->name('reports.status');
    Route::delete('/laporan/{report}', [ReportController::class, 'destroy'])->name('reports.destroy');
    Route::get('/fasilitas-rusak/laporan', [ReportController::class, 'facilityReport'])->name('facility-report');

    Route::get('/pesan', [AdminChatController::class, 'index'])->name('admin.chats');
    Route::post('/pesan/user/{user}', [AdminChatController::class, 'start'])->name('admin.chats.start');
    Route::get('/pesan/{conversation}', [AdminChatController::class, 'show'])->name('admin.chats.show');
    Route::post('/pesan/{conversation}', [AdminChatController::class, 'send'])->name('admin.chats.send');

    Route::get('/manajemen-kampus/profil', [CampusController::class, 'profile'])->name('campus-profile');
    Route::patch('/manajemen-kampus/profil', [CampusController::class, 'update'])->name('campus-profile.update');
    Route::get('/manajemen-kampus/user', [UserController::class, 'index'])->name('users');
    Route::get('/manajemen-kampus/user/{user}', [UserController::class, 'show'])->name('users.show');
    Route::patch('/manajemen-kampus/user/{user}/status', [UserController::class, 'updateStatus'])->name('users.status');
});

Route::middleware(['auth', 'role:superadmin'])->group(function (): void {
    Route::get('/superadmin/persetujuan', [ApprovalController::class, 'index'])->name('superadmin.approvals');
    Route::patch('/superadmin/persetujuan/{campus}/status', [ApprovalController::class, 'updateCampusStatus'])->name('superadmin.approvals.status');
    Route::get('/superadmin/manajemen-admin', [ApprovalController::class, 'admins'])->name('superadmin.admins');
    Route::get('/superadmin/manajemen-admin/{user}', [ApprovalController::class, 'showAdmin'])->name('superadmin.admins.show');
    Route::patch('/superadmin/manajemen-admin/{user}/status', [ApprovalController::class, 'updateAdminStatus'])->name('superadmin.admins.status');
});
