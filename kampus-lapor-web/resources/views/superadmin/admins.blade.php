@extends('layouts.superadmin', ['title' => 'Manajemen Admin', 'active' => 'superadmin.admins'])

@section('content')
    <div class="topbar">
        <h1>Manajemen Admin</h1>
    </div>

    <section class="panel">
        <div class="toolbar">
            <div class="tabs">
                <a class="tab {{ $status === 'active' ? 'active' : '' }}" href="{{ route('superadmin.admins', ['status' => 'active']) }}">Daftar Admin</a>
                <a class="tab {{ $status === 'banned' ? 'active' : '' }}" href="{{ route('superadmin.admins', ['status' => 'banned']) }}">Banned</a>
            </div>
            <input class="search" type="search" placeholder="Cari">
        </div>

        <div class="list">
            @forelse ($admins as $admin)
                <article class="row" style="grid-template-columns: 54px 1fr 170px 60px;">
                    <a href="{{ route('superadmin.admins.show', $admin) }}" class="logo-dot {{ $loop->even ? 'gold' : '' }} {{ $status === 'banned' ? 'muted' : '' }}" aria-label="Lihat profil {{ $admin->name }}"></a>
                    <a class="campus-name" href="{{ route('superadmin.admins.show', $admin) }}">{{ strtoupper($admin->campus?->name ?? 'KAMPUS') }} UNIVERSITY</a>
                    <div class="meta">
                        <a href="{{ route('superadmin.admins.show', $admin) }}"><strong>{{ $admin->name }}</strong></a>
                        <span>{{ $admin->email }}</span>
                    </div>
                    <div class="actions">
                        <a class="circle-btn" href="{{ route('superadmin.admins.show', $admin) }}" title="Lihat profil">i</a>
                        <form method="POST" action="{{ route('superadmin.admins.status', $admin) }}">
                            @csrf
                            @method('PATCH')
                            <input type="hidden" name="status" value="{{ $status === 'active' ? 'banned' : 'active' }}">
                            <button class="circle-btn" type="submit">{{ $status === 'active' ? '⊘' : '✓' }}</button>
                        </form>
                    </div>
                </article>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada admin untuk status ini.</p>
            @endforelse
        </div>

        <div class="pager"><x-mini-pagination :paginator="$admins" /></div>
    </section>
@endsection
