@extends('layouts.admin', ['title' => 'Daftar User', 'active' => 'campus-profile'])

@section('content')
    <div class="topbar">
        <h1>Manajemen Kampus</h1>
        <div class="management-tabs">
            <a class="btn outline" href="{{ route('campus-profile') }}">Profil Kampus</a>
            <a class="btn" href="{{ route('users') }}">Daftar User</a>
        </div>
    </div>

    <section class="panel">
        <div class="user-tools">
            <div class="tabs">
                <a class="tab {{ $status === 'active' ? 'active' : '' }}" href="{{ route('users', ['status' => 'active', 'search' => $search]) }}">Users</a>
                <a class="tab {{ $status === 'banned' ? 'active' : '' }}" href="{{ route('users', ['status' => 'banned', 'search' => $search]) }}">Banned</a>
            </div>
            <form class="user-search-form" method="GET" action="{{ route('users') }}">
                <input type="hidden" name="status" value="{{ $status }}">
                <input class="search" type="search" name="search" value="{{ $search }}" placeholder="Cari nama user">
                <button class="btn" type="submit">Cari</button>
                @if ($search !== '')
                    <a class="btn outline" href="{{ route('users', ['status' => $status]) }}">Reset</a>
                @endif
            </form>
        </div>

        <div class="user-list">
            @forelse ($users as $user)
                <article class="user-row">
                    <a href="{{ route('users.show', $user) }}" class="mini-avatar" aria-label="Lihat profil {{ $user->name }}"></a>
                    <div class="user-meta">
                        <a href="{{ route('users.show', $user) }}"><strong>{{ $user->name }}</strong></a>
                        <span>{{ '@'.$user->username }}</span>
                    </div>
                    <div class="icon-actions" style="grid-auto-flow: column; gap: 14px;">
                        <a class="btn outline" href="{{ route('users.show', $user) }}">Profil</a>
                        @if ($status === 'active')
                            <form method="POST" action="{{ route('admin.chats.start', $user) }}">
                                @csrf
                                <button class="btn" type="submit">Chat</button>
                            </form>
                        @endif
                        <form method="POST" action="{{ route('users.status', $user) }}">
                            @csrf
                            @method('PATCH')
                            <input type="hidden" name="status" value="{{ $status === 'active' ? 'banned' : 'active' }}">
                            <button class="btn outline" type="submit">{{ $status === 'active' ? 'Ban' : 'Aktif' }}</button>
                        </form>
                    </div>
                </article>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Tidak ada user yang cocok untuk status ini.</p>
            @endforelse
        </div>

        <div class="pager"><x-mini-pagination :paginator="$users" /></div>
    </section>
@endsection
