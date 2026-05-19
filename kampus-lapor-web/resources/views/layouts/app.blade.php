<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="csrf-token" content="{{ csrf_token() }}">
  <title>Kampus Lapor - {{ $title ?? 'Dashboard' }}</title>
  <link rel="icon" type="image/png" href="{{ asset('images/logo_kampus_lapor_square.png') }}">
  <link rel="stylesheet" href="{{ asset('css/app.css') }}" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
</head>
<body>
<div class="app-wrapper">
  <!-- Sidebar -->
  <aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
      <img class="sidebar-brand-logo" src="{{ asset('images/logo_kampus_lapor.png') }}" alt="Kampus Lapor">
    </div>

    <div class="sidebar-section">
      <p class="sidebar-section-label">Menu Utama</p>
      <nav class="sidebar-nav">
        @php
          $isSuperadminArea = session('auth_role') === 'superadmin';
          $menus = $isSuperadminArea ? [
            ['route' => 'superadmin.seleksi-admin', 'label' => 'Seleksi Admin', 'icon' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/>'],
            ['route' => 'superadmin.admin-aktif', 'label' => 'Admin Aktif', 'icon' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>'],
            ['route' => 'superadmin.data-kampus', 'label' => 'Data Kampus', 'icon' => '<path d="M3 21h18"/><path d="M5 21V7l8-4v18"/><path d="M19 21V11l-6-4"/><path d="M9 9h1"/><path d="M9 13h1"/><path d="M9 17h1"/>'],
          ] : [
            ['route' => 'dashboard', 'label' => 'Dashboard', 'icon' => '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'],
            ['route' => 'barang-hilang', 'label' => 'Barang Hilang', 'icon' => '<path d="M16.5 9.4l-9-5.19"/><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.29 7 12 12 20.71 7"/><line x1="12" y1="22" x2="12" y2="12"/>'],
            ['route' => 'fasilitas-rusak', 'label' => 'Fasilitas Rusak', 'icon' => '<circle cx="12" cy="12" r="3"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M4.93 4.93a10 10 0 0 0 0 14.14"/>'],
            ['route' => 'pesan', 'label' => 'Pesan', 'icon' => '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>'],
            ['route' => 'manajemen-kampus', 'label' => 'Manajemen Kampus', 'icon' => '<path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>'],
          ];
        @endphp
        @foreach($menus as $menu)
          <a href="{{ route($menu['route']) }}" class="sidebar-link {{ request()->routeIs($menu['route']) ? 'active' : '' }}">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">{!! $menu['icon'] !!}</svg>
            {{ $menu['label'] }}
            @if(request()->routeIs($menu['route']))
              <svg class="chevron" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
            @endif
          </a>
        @endforeach
      </nav>
    </div>

    <div class="sidebar-footer">
      <div class="sidebar-user-card">
        <div class="sidebar-avatar">{{ $isSuperadminArea ? 'SA' : 'AD' }}</div>
        <p class="sidebar-user-name">{{ session('auth_name', $isSuperadminArea ? 'Superadmin 1' : 'Admin 1') }}</p>
        <p class="sidebar-user-email">{{ session('auth_email', $isSuperadminArea ? 'superadmin1@kampus-lapor.test' : 'admin1@kampus-lapor.test') }}</p>
        <form method="POST" action="{{ route('logout') }}">
          @csrf
          <button type="submit" class="btn-logout">
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            Keluar
          </button>
        </form>
      </div>
    </div>
  </aside>

  <!-- Overlay for mobile -->
  <div id="sidebarOverlay" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:99;" onclick="closeSidebar()"></div>

  <!-- Main -->
  <div class="main-area">
    <header class="topbar">
      <div style="display:flex;align-items:center;gap:1rem;">
        <button class="hamburger" onclick="toggleSidebar()" aria-label="Menu">
          <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
        </button>
        <span class="topbar-title">{{ $title ?? 'Dashboard' }}</span>
      </div>
      <div class="topbar-right">
        <div class="search-wrap">
          <input type="search" id="topbarSearch" placeholder="Cari..." oninput="handleTopbarSearch(this.value)" />
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
        </div>
        <a class="btn-icon notif-link" href="{{ $isSuperadminArea ? route('superadmin.seleksi-admin') : route('pesan') }}" title="Buka halaman pesan">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
          @if(!$isSuperadminArea && ($adminUnreadChatCount ?? 0) > 0)
            <span class="notif-count">{{ $adminUnreadChatCount }}</span>
          @endif
        </a>
        <div class="topbar-avatar" title="{{ $isSuperadminArea ? 'Superadmin' : 'Admin Kampus' }}">{{ $isSuperadminArea ? 'SA' : 'AD' }}</div>
      </div>
    </header>

    <main class="page-content">
      <div class="content-inner">
        @if(session('success'))
          <div class="alert alert-success">{{ session('success') }}</div>
        @endif
        @if(session('error'))
          <div class="alert alert-danger">{{ session('error') }}</div>
        @endif
        @yield('content')
      </div>
    </main>
  </div>
</div>

<!-- Modal Detail Laporan -->
<div class="modal-backdrop" id="modalDetail" style="display:none;">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal('modalDetail')">&times;</button>
    <h2 class="modal-title" id="modalDetailTitle">Detail Laporan</h2>
    <div id="modalDetailBody"></div>
    <div style="margin-top:1.25rem;text-align:right;">
      <button class="btn btn-outline" onclick="closeModal('modalDetail')">Tutup</button>
    </div>
  </div>
</div>

<!-- Modal Profil User -->
<div class="modal-backdrop" id="modalProfil" style="display:none;">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal('modalProfil')">&times;</button>
    <h2 class="modal-title">Profil Pengguna</h2>
    <div id="modalProfilBody"></div>
    <div style="margin-top:1.25rem;text-align:right;">
      <button class="btn btn-outline" onclick="closeModal('modalProfil')">Tutup</button>
    </div>
  </div>
</div>

<script>
function toggleSidebar() {
  const sb = document.getElementById('sidebar');
  const ov = document.getElementById('sidebarOverlay');
  sb.classList.toggle('open');
  ov.style.display = sb.classList.contains('open') ? 'block' : 'none';
}
function closeSidebar() {
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('sidebarOverlay').style.display = 'none';
}
function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

function showDetail(data) {
  let html = '';
  for (const [key, val] of Object.entries(data)) {
    html += `<div class="modal-field"><dt>${key}</dt><dd>${val}</dd></div>`;
  }
  document.getElementById('modalDetailBody').innerHTML = html;
  openModal('modalDetail');
}
function showProfil(data) {
  document.getElementById('modalProfilBody').innerHTML = `
    <div style="text-align:center;margin-bottom:1rem;">
      <div style="width:64px;height:64px;border-radius:50%;background:#ede9fe;color:#5b21b6;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:1.25rem;margin:0 auto .75rem;">${data.nama.charAt(0)}</div>
      <p style="font-weight:600;">${data.nama}</p>
      <span class="badge badge-${data.role.toLowerCase()}">${data.role}</span>
    </div>
    <div class="modal-field"><dt>NIM / NIDN</dt><dd>${data.nim}</dd></div>
    <div class="modal-field"><dt>Email</dt><dd>${data.email}</dd></div>
    <div class="modal-field"><dt>Status</dt><dd><span class="badge badge-${data.status === 'Aktif' ? 'user-aktif' : 'banned'}">${data.status}</span></dd></div>`;
  openModal('modalProfil');
}

// Tab switching
function switchTab(tabGroupId, tabId) {
  document.querySelectorAll(`[data-tab-group="${tabGroupId}"]`).forEach(el => el.classList.remove('active'));
  document.querySelectorAll(`[data-panel-group="${tabGroupId}"]`).forEach(el => el.classList.remove('active'));
  document.querySelector(`[data-tab-group="${tabGroupId}"][data-tab="${tabId}"]`)?.classList.add('active');
  document.querySelector(`[data-panel-group="${tabGroupId}"][data-panel="${tabId}"]`)?.classList.add('active');
}

function handleTopbarSearch(value) {
  if (typeof window.onTopbarSearch === 'function') {
    window.onTopbarSearch(value);
  }
}
</script>
@stack('scripts')
</body>
</html>

