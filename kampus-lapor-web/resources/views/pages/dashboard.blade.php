@extends('layouts.app')
@section('title', 'Dashboard')
@php $title = 'Dashboard'; @endphp

@section('content')
<div class="stats-grid">
  <div class="stat-card">
    <div class="stat-top">
      <span class="stat-label">Barang Hilang</span>
      <span class="stat-icon" style="background:#fef3c7;"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#d97706" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg></span>
    </div>
    <div class="stat-value">{{ $stats['barangHilang'] }}</div>
    <div class="stat-sub">Laporan aktif</div>
  </div>
  <div class="stat-card">
    <div class="stat-top">
      <span class="stat-label">Barang Ditemukan</span>
      <span class="stat-icon" style="background:#ede9fe;"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7c3aed" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.29 7 12 12 20.71 7"/><line x1="12" y1="22" x2="12" y2="12"/></svg></span>
    </div>
    <div class="stat-value">{{ $stats['barangDitemukan'] }}</div>
    <div class="stat-sub">Laporan selesai</div>
  </div>
  <div class="stat-card">
    <div class="stat-top">
      <span class="stat-label">Fasilitas Rusak</span>
      <span class="stat-icon" style="background:#fee2e2;"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg></span>
    </div>
    <div class="stat-value">{{ $stats['fasilitasRusak'] }}</div>
    <div class="stat-sub">Dalam antrean</div>
  </div>
  <div class="stat-card">
    <div class="stat-top">
      <span class="stat-label">Fasilitas Diperbaiki</span>
      <span class="stat-icon" style="background:#dbeafe;"><svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg></span>
    </div>
    <div class="stat-value">{{ $stats['fasilitasDiperbaiki'] }}</div>
    <div class="stat-sub">Telah selesai</div>
  </div>
</div>

<div class="dashboard-grid">
  <div class="card">
    <div class="card-header"><h3>Tren Laporan</h3><p>Statistik 6 bulan terakhir</p></div>
    <div class="card-body">
      @php
        $maxVal = collect($chartData)->max(fn($d)=>max($d['barangHilang'],$d['fasilitasRusak']));
      @endphp
      <div class="chart-bars">
        @foreach($chartData as $d)
          @php $h1=$maxVal > 0 ? ($d['barangHilang']/$maxVal)*180 : 0; $h2=$maxVal > 0 ? ($d['fasilitasRusak']/$maxVal)*180 : 0; @endphp
          <div class="chart-group">
            <div class="bar bar-green" style="height:{{ $h1 }}px;flex:1;" title="Barang Hilang: {{ $d['barangHilang'] }}"></div>
            <div class="bar bar-amber" style="height:{{ $h2 }}px;flex:1;" title="Fasilitas Rusak: {{ $d['fasilitasRusak'] }}"></div>
          </div>
        @endforeach
      </div>
      <div class="chart-labels">
        @foreach($chartData as $d)
          <div class="chart-label">{{ $d['month'] }}</div>
        @endforeach
      </div>
      <div class="chart-legend">
        <div class="chart-legend-item"><div class="legend-dot" style="background:#7c3aed;"></div> Brg Hilang</div>
        <div class="chart-legend-item"><div class="legend-dot" style="background:#f59e0b;"></div> Fasilitas Rusak</div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="card-header"><h3>Laporan Terbaru</h3><p>Aktivitas pelaporan terkini</p></div>
    <div class="card-body" style="padding:0;">
      <div class="table-wrap" style="border:none;">
        <table>
          <thead><tr><th>Kategori</th><th>Item</th><th>Status</th></tr></thead>
          <tbody>
            @forelse($laporanTerbaru as $lap)
            <tr>
              <td style="font-size:.75rem;">{{ $lap['kategori'] }}</td>
              <td>{{ $lap['nama'] }}</td>
              <td><span class="badge badge-{{ strtolower(str_replace(' ','-',$lap['status'])) }}">{{ $lap['status'] }}</span></td>
            </tr>
            @empty
            <tr>
              <td colspan="3" style="text-align:center;color:#64748b;padding:1.5rem;">Belum ada laporan untuk kampus ini.</td>
            </tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>
@endsection

