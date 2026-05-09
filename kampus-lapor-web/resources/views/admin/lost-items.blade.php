@extends('layouts.admin', ['title' => 'Barang Hilang', 'active' => 'lost-items'])

@section('content')
    <div class="topbar">
        <h1>Barang Hilang</h1>
        <a class="btn" href="{{ route('lost-item-report', array_filter(['status' => $status, 'tag' => $tag])) }}">Print Laporan</a>
    </div>

    <section class="panel">
        <div class="toolbar">
            <div class="tabs">
                <a class="tab {{ $status === 'lost' ? 'active' : '' }}" href="{{ route('lost-items', ['status' => 'lost']) }}">Barang Hilang</a>
                <a class="tab {{ $status === 'found' ? 'active' : '' }}" href="{{ route('lost-items', ['status' => 'found']) }}">Barang Ditemukan</a>
            </div>
            <form method="GET" action="{{ route('lost-items') }}">
                <input type="hidden" name="status" value="{{ $status }}">
                <select class="search tag-search" name="tag" onchange="this.form.submit()">
                    <option value="">Cari berdasarkan tag</option>
                    @foreach ($itemTags as $itemTag)
                        <option value="{{ $itemTag }}" @selected($tag === $itemTag)>{{ $itemTag }}</option>
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
                        <img class="thumb-img" src="{{ asset('storage/'.$report->image_path) }}" alt="Bukti barang hilang">
                    @else
                        <span class="thumb"></span>
                    @endif
                    <div class="report-text">
                        {{ $report->description }}
                        <div class="location">{{ $report->location?->name ?? $report->campus?->name }}</div>
                    </div>
                    <div class="icon-actions">
                        <form method="POST" action="{{ route('reports.status', $report) }}">
                            @csrf
                            @method('PATCH')
                            <input type="hidden" name="status" value="{{ $status === 'lost' ? 'found' : 'lost' }}">
                            <button class="btn outline" type="submit">{{ $status === 'lost' ? 'Ketemu' : 'Hilang' }}</button>
                        </form>
                        <form method="POST" action="{{ route('reports.destroy', $report) }}" onsubmit="return confirm('Hapus laporan ini permanen?')">
                            @csrf
                            @method('DELETE')
                            <button class="btn outline" type="submit">Hapus</button>
                        </form>
                    </div>
                </article>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada laporan barang untuk status ini.</p>
            @endforelse
        </div>

        <div class="pager">
            <x-mini-pagination :paginator="$reports" />
        </div>
    </section>
@endsection
