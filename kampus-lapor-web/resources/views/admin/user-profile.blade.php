@extends('layouts.admin', ['title' => 'Profil User', 'active' => 'campus-profile'])

@section('content')
    <div class="topbar">
        <div>
            <a href="{{ route('users') }}" style="color: var(--purple); font-weight: 900;">&lt; Daftar User</a>
            <h1 style="margin-top: 10px;">Profil Civitas</h1>
        </div>
        <form method="POST" action="{{ route('admin.chats.start', $user) }}">
            @csrf
            <button class="btn" type="submit">Chat User</button>
        </form>
    </div>

    <section class="panel">
        <div class="profile-view">
            <div class="profile-main">
                @if ($user->avatar_path)
                    <img class="profile-avatar image" src="{{ asset('storage/'.$user->avatar_path) }}" alt="Foto profil {{ $user->name }}">
                @else
                    <span class="profile-avatar"></span>
                @endif
                <h2>{{ $user->name }}</h2>
                <p>{{ $user->campus?->name ?? 'Kampus' }}</p>
                <span class="status-badge {{ $user->status === 'active' ? 'active' : 'banned' }}">{{ ucfirst($user->status ?? 'active') }}</span>
            </div>

            <div class="profile-details">
                <label>
                    Username
                    <div class="read-field">{{ '@'.$user->username }}</div>
                </label>
                <label>
                    Email
                    <div class="read-field">{{ $user->email }}</div>
                </label>
                <label>
                    Role
                    <div class="read-field">{{ ucfirst($user->role) }}</div>
                </label>
                <label>
                    Bergabung
                    <div class="read-field">{{ $user->created_at?->format('d M Y H:i') ?? '-' }}</div>
                </label>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-box"><strong>{{ $reportCounts['total'] }}</strong><span>Total Laporan</span></div>
            <div class="stat-box"><strong>{{ $reportCounts['lost'] }}</strong><span>Barang Hilang</span></div>
            <div class="stat-box"><strong>{{ $reportCounts['facility'] }}</strong><span>Fasilitas Rusak</span></div>
        </div>

        <h2 class="section-title">Laporan Terbaru</h2>
        <div class="compact-list">
            @forelse ($latestReports as $report)
                <div class="compact-row">
                    <strong>{{ $report->title }}</strong>
                    <span>{{ $report->location?->name ?? 'Lokasi kampus' }} - {{ str_replace('_', ' ', $report->category) }} - {{ $report->status }}</span>
                </div>
            @empty
                <p style="color: var(--muted); font-weight: 800;">User ini belum membuat laporan.</p>
            @endforelse
        </div>
    </section>

    <style>
        .profile-view {
            display: grid;
            grid-template-columns: 260px 1fr;
            gap: 34px;
            align-items: start;
        }
        .profile-main {
            display: grid;
            justify-items: center;
            gap: 8px;
            text-align: center;
        }
        .profile-main h2 {
            margin: 8px 0 0;
            color: var(--purple);
            font-size: 26px;
            line-height: 1;
        }
        .profile-main p {
            margin: 0;
            font-weight: 900;
        }
        .profile-details {
            display: grid;
            gap: 14px;
        }
        .read-field {
            min-height: 42px;
            display: flex;
            align-items: center;
            margin-top: 6px;
            padding: 0 14px;
            border: 1px solid #d8d0e4;
            border-radius: 8px;
            background: var(--white);
            color: var(--ink);
            font-weight: 800;
        }
        .status-badge {
            padding: 5px 12px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 900;
        }
        .status-badge.active { background: #e9fff1; color: #23623a; }
        .status-badge.banned { background: #ffe8e8; color: #9b2626; }
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-top: 26px;
        }
        .stat-box {
            padding: 16px;
            border-radius: 12px;
            background: var(--white);
            border: 1px solid #e6dfef;
        }
        .stat-box strong {
            display: block;
            color: var(--purple);
            font-size: 24px;
        }
        .stat-box span {
            color: var(--muted);
            font-size: 11px;
            font-weight: 800;
        }
        .section-title {
            margin: 28px 0 12px;
            color: var(--purple);
            font-size: 18px;
        }
        .compact-list {
            display: grid;
            gap: 10px;
        }
        .compact-row {
            padding: 12px 14px;
            border-radius: 10px;
            background: var(--white);
            border: 1px solid #e6dfef;
        }
        .compact-row strong {
            display: block;
            font-size: 13px;
        }
        .compact-row span {
            color: var(--muted);
            font-size: 11px;
            font-weight: 700;
        }
        @media (max-width: 900px) {
            .profile-view, .stat-grid { grid-template-columns: 1fr; }
        }
    </style>
@endsection
