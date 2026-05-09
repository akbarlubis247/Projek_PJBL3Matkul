<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CampusController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Middleware\ApiTokenAuth;
use Illuminate\Support\Facades\Route;

Route::get('/campuses', [CampusController::class, 'index']);
Route::get('/campuses/{campus}/locations', [CampusController::class, 'locations']);
Route::get('/reports/{report}/image', [ReportController::class, 'image']);
Route::get('/users/{user}/avatar', [AuthController::class, 'avatar']);

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::middleware(ApiTokenAuth::class)->group(function (): void {
    Route::get('/me', [AuthController::class, 'me']);
    Route::patch('/me', [AuthController::class, 'updateProfile']);
    Route::post('/me/avatar', [AuthController::class, 'updateAvatar']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);

    Route::get('/chats', [ChatController::class, 'index']);
    Route::post('/chats', [ChatController::class, 'store']);
    Route::post('/chats/admin', [ChatController::class, 'adminStore']);
    Route::get('/chats/{conversation}', [ChatController::class, 'show']);
    Route::post('/chats/{conversation}/messages', [ChatController::class, 'sendMessage']);

    Route::get('/reports', [ReportController::class, 'index']);
    Route::get('/reports/mine', [ReportController::class, 'mine']);
    Route::post('/reports', [ReportController::class, 'store']);
    Route::get('/reports/{report}', [ReportController::class, 'show']);
    Route::patch('/reports/{report}/status', [ReportController::class, 'updateStatus']);
    Route::delete('/reports/{report}', [ReportController::class, 'destroy']);
});
