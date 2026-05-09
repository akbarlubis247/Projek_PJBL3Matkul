@extends('layouts.superadmin', ['title' => 'Profil Admin', 'active' => 'superadmin.admins'])

@section('content')
    <div class="topbar">
        <div>
            <a href="{{ route('superadmin.admins') }}" style="color: var(--purple); font-weight: 900;">&lt; Manajemen Admin</a>
            <h1 style="margin-top: 10px;">Profil Admin</h1>
        </div>
        <form method="POST" action="{{ route('superadmin.admins.status', $user) }}">
            @csrf
            @method('PATCH')
            <input type="hidden" name="status" value="{{ $user->status === 'active' ? 'banned' : 'active' }}">
            <button class="circle-btn" type="submit" title="{{ $user->status === 'active' ? 'Ban admin' : 'Aktifkan admin' }}">
                {{ $user->status === 'active' ? '!' : '✓' }}
            </button>
        </form>
    </div>

    <section class="panel">
        <div class="admin-profile-grid">
            <div class="admin-profile-main">
                @if ($user->avatar_path)
                    <img class="admin-avatar image" src="{{ asset('storage/'.$user->avatar_path) }}" alt="Foto profil {{ $user->name }}">
                @else
                    <span class="admin-avatar"></span>
                @endif
                <h2>{{ $user->name }}</h2>
                <p>{{ $user->email }}</p>
                <span class="status-badge {{ $user->status === 'active' ? 'active' : 'banned' }}">{{ ucfirst($user->status ?? 'active') }}</span>
            </div>

            <div class="admin-fields">
                <label>Username<div class="read-field">{{ '@'.$user->username }}</div></label>
                <label>Kampus<div class="read-field">{{ $user->campus?->name ?? '-' }}</div></label>
                <label>Domain<div class="read-field">{{ $user->campus?->domain ?? '-' }}</div></label>
                <label>Status Kampus<div class="read-field">{{ ucfirst($user->campus?->status ?? '-') }}</div></label>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-box"><strong>{{ $stats['users'] }}</strong><span>User Civitas</span></div>
            <div class="stat-box"><strong>{{ $stats['reports'] }}</strong><span>Total Laporan</span></div>
            <div class="stat-box"><strong>{{ $stats['locations'] }}</strong><span>Lokasi Kampus</span></div>
        </div>

        <h2 class="section-title">Profil Kampus Terpasang</h2>
        <div class="campus-preview">
            @if ($user->campus?->image_path)
                <img src="{{ asset('storage/'.$user->campus->image_path) }}" alt="Foto kampus {{ $user->campus->name }}">
            @else
                <span class="empty-preview">Belum ada foto kampus</span>
            @endif

            <div>
                <strong>{{ $user->campus?->name ?? 'Kampus' }}</strong>
                <p>{{ $user->campus?->domain ?? '-' }}</p>
                @if ($user->campus?->legal_document_path)
                    <a class="doc-link" href="{{ asset('storage/'.$user->campus->legal_document_path) }}" target="_blank">Lihat dokumen legal</a>
                @else
                    <span class="doc-link">Dokumen legal belum diunggah</span>
                @endif
            </div>
        </div>
    </section>

    <style>
        .admin-profile-grid {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 30px;
        }
        .admin-profile-main {
            display: grid;
            justify-items: center;
            gap: 8px;
            text-align: center;
        }
        .admin-avatar {
            width: 126px;
            height: 126px;
            border-radius: 50%;
            background: #eaddff;
            border: 3px solid #d7c7ef;
        }
        .admin-avatar.image {
            object-fit: cover;
        }
        .admin-profile-main h2 {
            margin: 8px 0 0;
            color: var(--purple);
            font-size: 24px;
            line-height: 1;
        }
        .admin-profile-main p {
            margin: 0;
            color: var(--muted);
            font-size: 11px;
            font-weight: 800;
        }
        .admin-fields {
            display: grid;
            gap: 13px;
        }
        .admin-fields label {
            color: var(--purple);
            font-size: 11px;
            font-weight: 900;
        }
        .read-field {
            min-height: 40px;
            display: flex;
            align-items: center;
            margin-top: 6px;
            padding: 0 14px;
            border: 1px solid #d8d0e4;
            border-radius: 8px;
            background: #fff;
            color: var(--ink);
            font-weight: 800;
        }
        .status-badge {
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 900;
        }
        .status-badge.active { background: #e9fff1; color: #23623a; }
        .status-badge.banned { background: #ffe8e8; color: #9b2626; }
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-top: 24px;
        }
        .stat-box {
            padding: 15px;
            border-radius: 12px;
            background: #fff;
            border: 1px solid #e6dfef;
        }
        .stat-box strong {
            display: block;
            color: var(--purple);
            font-size: 22px;
        }
        .stat-box span {
            color: var(--muted);
            font-size: 10px;
            font-weight: 800;
        }
        .section-title {
            margin: 26px 0 12px;
            color: var(--purple);
            font-size: 17px;
        }
        .campus-preview {
            display: grid;
            grid-template-columns: 150px 1fr;
            gap: 16px;
            align-items: center;
            padding: 14px;
            border-radius: 12px;
            background: #fff;
            border: 1px solid #e6dfef;
        }
        .campus-preview img,
        .empty-preview {
            width: 150px;
            height: 98px;
            display: grid;
            place-items: center;
            border-radius: 8px;
            object-fit: cover;
            background: #f1e8ff;
            color: var(--muted);
            font-size: 10px;
            font-weight: 800;
            text-align: center;
        }
        .campus-preview strong {
            color: var(--purple);
            font-size: 18px;
        }
        .campus-preview p {
            margin: 4px 0 10px;
            color: var(--muted);
            font-size: 11px;
            font-weight: 800;
        }
        @media (max-width: 850px) {
            .admin-profile-grid,
            .stat-grid,
            .campus-preview { grid-template-columns: 1fr; }
        }
    </style>
@endsection
