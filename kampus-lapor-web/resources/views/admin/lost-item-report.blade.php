@extends('layouts.admin', ['title' => 'Laporan '.$statusLabel, 'active' => 'lost-items'])

@section('content')
    <div class="topbar no-print">
        <a href="{{ route('lost-items', array_filter(['status' => $status, 'tag' => $tag])) }}" style="color: var(--purple); font-weight: 900; font-size: 24px;">&lt;</a>
        <h1>{{ $statusLabel }}</h1>
        <button class="btn" type="button" onclick="window.print()">Download PDF</button>
    </div>

    <section class="panel report-document">
        @forelse ($reports->chunk(3) as $chunk)
            <article class="paper">
                <h2>Laporan {{ $statusLabel }}</h2>
                <p>Campus Lapor</p>
                <h3 style="font-size: 10px; margin: 0 0 8px;">{{ $chunk->first()?->campus?->name ?? 'Kampus' }}</h3>
                @if ($tag)
                    <h3 style="font-size: 9px; margin: 0 0 8px; color: #555;">Tag: {{ $tag }}</h3>
                @endif
                <table>
                    <thead>
                        <tr>
                            <th style="width: 34px;">NO</th>
                            <th>Gambar</th>
                            <th>Pelapor</th>
                            <th>Deskripsi</th>
                            <th>Lokasi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($chunk as $report)
                            <tr>
                                <td>{{ (($loop->parent->iteration - 1) * 3) + $loop->iteration }}</td>
                                <td>
                                    @if ($reportImages->has($report->id))
                                        <img class="table-img" src="{{ $reportImages[$report->id] }}" alt="Bukti barang">
                                    @else
                                        <div class="table-img empty-img">Tidak ada gambar</div>
                                    @endif
                                </td>
                                <td>{{ $report->user?->name ?? 'Pengguna' }}</td>
                                <td>{{ $report->description }}</td>
                                <td>{{ $report->location?->name ?? $report->campus?->name }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </article>
        @empty
            <article class="paper">
                <h2>Laporan {{ $statusLabel }}</h2>
                <p>Campus Lapor</p>
                <table>
                    <thead>
                        <tr>
                            <th>Informasi</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Belum ada laporan barang untuk status ini.</td>
                        </tr>
                    </tbody>
                </table>
            </article>
        @endforelse
    </section>

    <script>
        if (new URLSearchParams(window.location.search).get('print') === '1') {
            window.addEventListener('load', () => window.print());
        }
    </script>
@endsection
