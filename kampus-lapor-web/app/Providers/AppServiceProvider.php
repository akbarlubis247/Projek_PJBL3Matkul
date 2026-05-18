<?php

namespace App\Providers;

use App\Services\ChatStore;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        View::composer('layouts.app', function ($view) {
            $unreadCount = session('auth_role') === 'admin' && session('auth_username') !== 'admin1'
                ? 0
                : app(ChatStore::class)->unreadForAdmin();

            $view->with('adminUnreadChatCount', $unreadCount);
        });
    }
}
