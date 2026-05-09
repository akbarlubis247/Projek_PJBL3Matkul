@extends('layouts.admin', ['title' => 'Laporan Fasilitas Rusak', 'active' => 'damaged-facilities'])

@section('content')
    <div class="topbar no-print">
        <a href="{{ route('damaged-facilities') }}" style="color: var(--purple); font-weight: 900; font-size: 24px;">&lt;</a>
        <h1>Fasilitas Rusak</h1>
        <button class="btn" type="button" onclick="window.print()">Download PDF</button>
    </div>

    <section class="panel report-document">
        @foreach ($reports->chunk(3) as $chunk)
            <article class="paper">
                <h2>Laporan Fasilitas Rusak</h2>
                <p>Campus Lapor</p>
                <h3 style="font-size: 10px; margin: 0 0 8px;">{{ $chunk->first()?->campus?->name ?? 'Kampus' }}</h3>
                <table>
                    <thead>
                        <tr>
                            <th style="width: 34px;">NO</th>
                            <th>Gambar</th>
                            <th>Deskripsi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($chunk as $report)
                            <tr>
                                <td>{{ $loop->iteration }}</td>
                                <td>
                                    @if ($reportImages->has($report->id))
                                        <img class="table-img" src="{{ $reportImages[$report->id] }}" alt="Bukti fasilitas">
                                    @else
                                        <div class="table-img empty-img">Tidak ada gambar</div>
                                    @endif
                                </td>
                                <td>{{ $report->description }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </article>
        @endforeach
    </section>

    <script>
        if (new URLSearchParams(window.location.search).get('print') === '1') {
            window.addEventListener('load', () => window.print());
        }
    </script>
@endsection
