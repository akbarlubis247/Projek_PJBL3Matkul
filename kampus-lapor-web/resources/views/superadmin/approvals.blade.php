@extends('layouts.superadmin', ['title' => 'Persetujuan Admin', 'active' => 'superadmin.approvals'])

@section('content')
    <div class="topbar">
        <h1>Persetujuan</h1>
    </div>

    <section class="panel">
        <div class="toolbar">
            <div class="tabs">
                <a class="tab {{ $status === 'pending' ? 'active' : '' }}" href="{{ route('superadmin.approvals', ['status' => 'pending']) }}">Permintaan</a>
                <a class="tab {{ $status === 'approved' ? 'active' : '' }}" href="{{ route('superadmin.approvals', ['status' => 'approved']) }}">Diterima</a>
                <a class="tab {{ $status === 'rejected' ? 'active' : '' }}" href="{{ route('superadmin.approvals', ['status' => 'rejected']) }}">Ditolak</a>
            </div>
            <input class="search" type="search" placeholder="Cari">
        </div>

        <div class="list">
            @forelse ($campuses as $campus)
                <article class="row">
                    <span class="logo-dot {{ $loop->even ? 'gold' : '' }} {{ $status !== 'pending' ? 'muted' : '' }}"></span>
                    <strong class="campus-name">{{ strtoupper($campus->name) }} UNIVERSITY</strong>
                    <div class="meta">
                        <strong>{{ $campus->admins->first()?->name ?? 'Admin Kampus' }}</strong>
                        <span>{{ $campus->admins->first()?->email ?? $campus->domain }}</span>
                    </div>
                    <div class="actions">
                        @if ($status === 'pending')
                            <a class="doc-link" href="{{ route('superadmin.approvals', ['status' => $status, 'document' => $campus->id]) }}">Lihat surat</a>
                            <form method="POST" action="{{ route('superadmin.approvals.status', $campus) }}">
                                @csrf
                                @method('PATCH')
                                <input type="hidden" name="status" value="approved">
                                <button class="square-btn green" type="submit">✓</button>
                            </form>
                            <form method="POST" action="{{ route('superadmin.approvals.status', $campus) }}">
                                @csrf
                                @method('PATCH')
                                <input type="hidden" name="status" value="rejected">
                                <button class="square-btn red" type="submit">×</button>
                            </form>
                        @else
                            <span class="circle-btn">✓</span>
                        @endif
                    </div>
                </article>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada data kampus untuk status ini.</p>
            @endforelse
        </div>

        <div class="pager"><x-mini-pagination :paginator="$campuses" /></div>
    </section>

    @if ($documentCampus)
        <div class="modal-backdrop">
            <article class="letter">
                <a class="close" href="{{ route('superadmin.approvals', ['status' => $status]) }}">×</a>
                <h2>CONTOH SURAT TUGAS UNIVERSITAS</h2>
                <h3>SURAT TUGAS</h3>
                <p>Pihak kampus {{ $documentCampus->name }} menerangkan bahwa admin di bawah ini ditugaskan untuk mengelola laporan Campus Lapor.</p>
                <p>
                    Nama: {{ $documentCampus->admins->first()?->name ?? 'Admin Kampus' }}<br>
                    Email: {{ $documentCampus->admins->first()?->email ?? $documentCampus->domain }}<br>
                    Domain: {{ $documentCampus->domain }}
                </p>
                <p>Surat ini digunakan sebagai bukti validasi pendaftaran admin kampus pada sistem Campus Lapor.</p>
                <p style="margin-top: 58px; text-align: right;">Bandung, 7 Mei 2026<br><br><br>Rektor</p>
            </article>
        </div>
    @endif
@endsection
