@extends('layouts.admin', ['title' => 'Fasilitas Rusak', 'active' => 'damaged-facilities'])

@section('content')
    <div class="topbar">
        <h1>Fasilitas Rusak</h1>
        <a class="btn" href="{{ route('facility-report') }}">Print Laporan</a>
    </div>

    <section class="panel">
        <div class="toolbar">
            <div class="tabs">
                <a class="tab {{ $status === 'damaged' ? 'active' : '' }}" href="{{ route('damaged-facilities', ['status' => 'damaged']) }}">Fasilitas Rusak</a>
                <a class="tab {{ $status === 'repaired' ? 'active' : '' }}" href="{{ route('damaged-facilities', ['status' => 'repaired']) }}">Fasilitas Diperbaiki</a>
            </div>
            <form method="GET" action="{{ route('damaged-facilities') }}">
                <input type="hidden" name="status" value="{{ $status }}">
            <select class="select" name="location" onchange="this.form.submit()">
                <option>Lokasi</option>
                @foreach ($locations as $location)
                    <option value="{{ $location->id }}" @selected((string) $locationId === (string) $location->id)>{{ $location->name }}</option>
                @endforeach
            </select>
            </form>
        </div>

        <div class="report-list">
            @forelse ($reports as $report)
                <article class="report-card">
                    <div class="person">
                        <span class="avatar"></span>
                        <span><strong>{{ $report->user?->name ?? 'Pengguna' }}</strong>{{ '@'.($report->user?->username ?? 'user') }}</span>
                    </div>
                    @if ($report->image_path)
                        <img class="thumb-img" src="{{ asset('storage/'.$report->image_path) }}" alt="Bukti fasilitas rusak">
                    @else
                        <span class="thumb facility"></span>
                    @endif
                    <div class="report-text">
                        {{ $report->description }}
                        <div class="location">{{ $report->location?->name ?? $report->campus?->name }}</div>
                    </div>
                    <div class="icon-actions">
                        <form method="POST" action="{{ route('reports.status', $report) }}">
                            @csrf
                            @method('PATCH')
                            <input type="hidden" name="status" value="{{ $status === 'damaged' ? 'repaired' : 'damaged' }}">
                            <button class="btn outline" type="submit">{{ $status === 'damaged' ? 'OK' : 'Rusak' }}</button>
                        </form>
                        <form method="POST" action="{{ route('reports.destroy', $report) }}" onsubmit="return confirm('Hapus laporan ini permanen?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn outline" type="submit">Hapus</button>
                        </form>
                    </div>
                </article>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada laporan fasilitas untuk status ini.</p>
            @endforelse
        </div>

        <div class="toolbar" style="margin-top: 28px; margin-bottom: 0;">
            <div>
                <button class="btn">Diperbaiki</button>
                <button class="btn">Pilih semua</button>
            </div>
            <div class="pager" style="margin-top: 0;">
                <x-mini-pagination :paginator="$reports" />
            </div>
        </div>
    </section>
@endsection
