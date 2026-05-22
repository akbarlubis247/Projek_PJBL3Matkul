@extends('layouts.app')
@php $title = 'Pemeliharaan Fasilitas'; @endphp

@section('content')
<div class="toolbar">
  <p class="page-desc">Kelola laporan kerusakan dan perbaikan fasilitas kampus.</p>
  <div style="display:flex;align-items:center;gap:.75rem;">
    <a href="{{ route('fasilitas-rusak.export', 'pdf') }}" class="btn btn-pdf">PDF</a>
    <a href="{{ route('fasilitas-rusak.export', 'excel') }}" class="btn btn-excel">Excel</a>
    <div class="search-input-wrap" style="width:260px;">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
      <input type="search" id="searchFasilitas" placeholder="Cari fasilitas atau lokasi..." oninput="filterTable('searchFasilitas','tableRusak','tableDiperbaiki')" />
    </div>
  </div>
</div>

<div class="card">
  <div class="card-body" style="padding:0;">
    <div class="tabs-header" style="padding:0 1.5rem;margin-bottom:0;">
      <button class="tab-btn active" data-tab-group="fasilitas" data-tab="rusak" onclick="switchTab('fasilitas','rusak')">Fasilitas Rusak</button>
      <button class="tab-btn" data-tab-group="fasilitas" data-tab="diperbaiki" onclick="switchTab('fasilitas','diperbaiki')">Sudah Diperbaiki</button>
    </div>
    <div style="padding:1.5rem;">
      <div class="tab-panel active" data-panel-group="fasilitas" data-panel="rusak">
        <div class="table-wrap">
          <table id="tableRusak">
            <thead><tr><th>No</th><th>Foto</th><th>Nama Fasilitas</th><th>Pelapor</th><th>Lokasi</th><th>Tanggal</th><th>Status</th><th style="text-align:right;">Aksi</th></tr></thead>
            <tbody>
              @foreach($fasilitasRusak as $i => $item)
              <tr>
                <td>{{ $i+1 }}</td>
                <td>
                  @if(!empty($item['foto']))
                    <button type="button" class="report-thumb-button" onclick='openImageModal(@json($item["foto"]))' title="Lihat Foto">
                      <img src="{{ $item['foto'] }}" alt="Foto {{ $item['namaFasilitas'] }}" class="report-thumb">
                    </button>
                  @else
                    <div class="report-thumb report-thumb-empty">IMG</div>
                  @endif
                </td>
                <td>{{ $item['namaFasilitas'] }}</td>
                <td>{{ $item['pelapor'] }}</td>
                <td>{{ $item['lokasi'] }}</td>
                <td>{{ \Carbon\Carbon::parse($item['tanggal'])->isoFormat('D MMM YYYY') }}</td>
                <td><span class="badge badge-{{ $item['status']==='Dilaporkan' ? 'dilaporkan' : 'sedang' }}">{{ $item['status'] }}</span></td>
                <td style="text-align:right;">
                  <button class="btn-icon-sm btn-icon-blue" onclick='showDetail({{ json_encode(["Nama Fasilitas"=>$item["namaFasilitas"],"Pelapor"=>$item["pelapor"],"Lokasi"=>$item["lokasi"],"Tanggal"=>$item["tanggal"],"Status"=>$item["status"],"Deskripsi"=>$item["deskripsi"],"FotoUrl"=>$item["foto"] ?? null]) }})' title="Detail">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  </button>
                  <form method="POST" action="{{ route('fasilitas-diperbaiki.hapus', $item['id']) }}" style="display:inline;" onsubmit="return confirm('Hapus laporan fasilitas diperbaiki {{ $item['namaFasilitas'] }}?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="btn-icon-sm btn-icon-red" title="Hapus Laporan">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                    </button>
                  </form>
                  <form method="POST" action="{{ route('fasilitas-rusak.tandai', $item['id']) }}" style="display:inline;">
                    @csrf @method('PATCH')
                    <button type="submit" class="btn-icon-sm btn-icon-green" title="Tandai Sudah Diperbaiki">
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
      <div class="tab-panel" data-panel-group="fasilitas" data-panel="diperbaiki">
        <div class="table-wrap">
          <table id="tableDiperbaiki">
            <thead><tr><th>No</th><th>Foto</th><th>Nama Fasilitas</th><th>Pelapor</th><th>Lokasi</th><th>Tanggal</th><th>Status</th><th style="text-align:right;">Aksi</th></tr></thead>
            <tbody>
              @foreach($fasilitasDiperbaiki as $i => $item)
              <tr>
                <td>{{ $i+1 }}</td>
                <td>
                  @if(!empty($item['foto']))
                    <button type="button" class="report-thumb-button" onclick='openImageModal(@json($item["foto"]))' title="Lihat Foto">
                      <img src="{{ $item['foto'] }}" alt="Foto {{ $item['namaFasilitas'] }}" class="report-thumb">
                    </button>
                  @else
                    <div class="report-thumb report-thumb-empty">IMG</div>
                  @endif
                </td>
                <td>{{ $item['namaFasilitas'] }}</td>
                <td>{{ $item['pelapor'] }}</td>
                <td>{{ $item['lokasi'] }}</td>
                <td>{{ \Carbon\Carbon::parse($item['tanggal'])->isoFormat('D MMM YYYY') }}</td>
                <td><span class="badge badge-diperbaiki">{{ $item['status'] }}</span></td>
                <td style="text-align:right;">
                  <button class="btn-icon-sm btn-icon-blue" onclick='showDetail({{ json_encode(["Nama Fasilitas"=>$item["namaFasilitas"],"Pelapor"=>$item["pelapor"],"Lokasi"=>$item["lokasi"],"Tanggal"=>$item["tanggal"],"Status"=>$item["status"],"Deskripsi"=>$item["deskripsi"],"FotoUrl"=>$item["foto"] ?? null]) }})' title="Detail">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                  </button>
                  <form method="POST" action="{{ route('fasilitas-diperbaiki.hapus', $item['id']) }}" style="display:inline;" onsubmit="return confirm('Kembalikan laporan {{ $item['namaFasilitas'] }} ke fasilitas rusak?')">
                    @csrf @method('DELETE')
                    <button type="submit" class="btn-icon-sm btn-icon-red" title="Kembalikan ke Fasilitas Rusak">
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
