@extends('layouts.app')
@php $title = 'Manajemen Barang'; @endphp

@section('content')
<div class="toolbar">
  <p class="page-desc">Kelola laporan barang hilang dan ditemukan di area kampus.</p>
  <div style="display:flex;align-items:center;gap:.75rem;">
    <a href="{{ route('barang-hilang.export', 'pdf') }}" class="btn btn-pdf">PDF</a>
    <a href="{{ route('barang-hilang.export', 'excel') }}" class="btn btn-excel">Excel</a>
    <div class="search-input-wrap" style="width:260px;">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="search" id="searchBarang" placeholder="Cari barang atau pelapor..." oninput="filterTable('searchBarang','tableHilang','tableFound')" />
    </div>
  </div>
</div>

<div class="card">
  <div class="card-body" style="padding:0;">
    <div class="tabs-header" style="padding:0 1.5rem;margin-bottom:0;">
      <button class="tab-btn active" data-tab-group="barang" data-tab="hilang" onclick="switchTab('barang','hilang')">Barang Hilang</button>
      <button class="tab-btn" data-tab-group="barang" data-tab="ditemukan" onclick="switchTab('barang','ditemukan')">Barang Ditemukan</button>
    </div>
    <div style="padding:1.5rem;">
      <div class="tab-panel active" data-panel-group="barang" data-panel="hilang">
        <div class="table-wrap">
          <table id="tableHilang">
            <thead><tr><th>No</th><th>Foto</th><th>Nama Barang</th><th>Pelapor</th><th>Lokasi</th><th>Tanggal</th><th>Status</th><th style="text-align:right;">Aksi</th></tr></thead>
            <tbody>
              @foreach($barangHilang as $i => $item)
              <tr>
                <td>{{ $i+1 }}</td>
                <td>
                  @if(!empty($item['foto']))
                    <button type="button" class="report-thumb-button" onclick='openImageModal(@json($item["foto"]))' title="Lihat Foto">
                      <img src="{{ $item['foto'] }}" alt="Foto {{ $item['namaBarang'] }}" class="report-thumb">
                    </button>
                  @else
                    <div class="report-thumb report-thumb-empty">IMG</div>
                  @endif
                </td>
                <td>{{ $item['namaBarang'] }}</td>
                <td>{{ $item['pelapor'] }}</td>
                <td>{{ $item['lokasi'] }}</td>
                <td>{{ \Carbon\Carbon::parse($item['tanggal'])->isoFormat('D MMM YYYY') }}</td>
                <td><span class="badge badge-{{ strtolower($item['status']) }}">{{ $item['status'] }}</span></td>
                <td style="text-align:right;">
                  <button class="btn-icon-sm btn-icon-blue" onclick='showDetail({{ json_encode(["Nama Barang"=>$item["namaBarang"],"Pelapor"=>$item["pelapor"],"Lokasi"=>$item["lokasi"],"Tanggal"=>$item["tanggal"],"Status"=>$item["status"],"Deskripsi"=>$item["deskripsi"],"FotoUrl"=>$item["foto"] ?? null]) }})' title="Detail">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  </button>
                  <form method="POST" action="{{ route('barang-hilang.ubah-status', $item['id']) }}" style="display:inline;">
                    @csrf @method('PATCH')
                    <button type="submit" class="btn-icon-sm btn-icon-green" title="Tandai Barang Ditemukan">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </button>
                  </form>
                </td>
              </tr>
              @endforeach
            </tbody>
          </table>
        </div>
      </div>
      <div class="tab-panel" data-panel-group="barang" data-panel="ditemukan">
        <div class="table-wrap">
          <table id="tableFound">
            <thead><tr><th>No</th><th>Foto</th><th>Nama Barang</th><th>Pelapor</th><th>Lokasi</th><th>Tanggal</th><th>Status</th><th style="text-align:right;">Aksi</th></tr></thead>
            <tbody>
              @foreach($barangDitemukan as $i => $item)
              <tr>
                <td>{{ $i+1 }}</td>
                <td>
                  @if(!empty($item['foto']))
                    <button type="button" class="report-thumb-button" onclick='openImageModal(@json($item["foto"]))' title="Lihat Foto">
                      <img src="{{ $item['foto'] }}" alt="Foto {{ $item['namaBarang'] }}" class="report-thumb">
                    </button>
                  @else
                    <div class="report-thumb report-thumb-empty">IMG</div>
                  @endif
                </td>
                <td>{{ $item['namaBarang'] }}</td>
                <td>{{ $item['pelapor'] }}</td>
                <td>{{ $item['lokasi'] }}</td>
                <td>{{ \Carbon\Carbon::parse($item['tanggal'])->isoFormat('D MMM YYYY') }}</td>
                <td><span class="badge badge-ditemukan">{{ $item['status'] }}</span></td>
                <td style="text-align:right;">
                  <button class="btn-icon-sm btn-icon-blue" onclick='showDetail({{ json_encode(["Nama Barang"=>$item["namaBarang"],"Pelapor"=>$item["pelapor"],"Lokasi"=>$item["lokasi"],"Tanggal"=>$item["tanggal"],"Status"=>$item["status"],"Deskripsi"=>$item["deskripsi"],"FotoUrl"=>$item["foto"] ?? null]) }})' title="Detail">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  </button>
                  @if(($item['status'] ?? '') === 'Menunggu Diambil')
                  <form method="POST" action="{{ route('barang-ditemukan.diambil', $item['id']) }}" style="display:inline;">
                    @csrf @method('PATCH')
                    <button type="submit" class="btn-icon-sm btn-icon-green" title="Verifikasi Sudah Diambil">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                    </button>
                  </form>
                  @endif
                  <form method="POST" action="{{ route('barang-ditemukan.hapus', $item['id']) }}" style="display:inline;" onsubmit="return confirm('Hapus laporan barang ditemukan {{ $item['namaBarang'] }}? Status di mobile akan menjadi Barang Dihapus.')">
                    @csrf @method('DELETE')
                    <button type="submit" class="btn-icon-sm btn-icon-red" title="Hapus Laporan">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                    </button>
                  </form>
                </td>
              </tr>
              @endforeach
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
@endsection
@push('scripts')
<script>
function filterTable(inputId, ...tableIds) {
  const q = document.getElementById(inputId).value.toLowerCase();
  tableIds.forEach(id => {
    const tbl = document.getElementById(id);
    if (!tbl) return;
    tbl.querySelectorAll('tbody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  });
}
</script>
@endpush
