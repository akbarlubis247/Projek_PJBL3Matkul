@php
    $menu = [
        ['label' => 'Persetujuan', 'route' => 'superadmin.approvals'],
        ['label' => 'Manajemen Admin', 'route' => 'superadmin.admins'],
    ];
@endphp

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'Super Admin Campus Lapor' }}</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700,800" rel="stylesheet" />
    <style>
        :root {
            --purple: #8138e9;
            --page: #f4edff;
            --panel: #f9fcff;
            --line: #dfd7ea;
            --ink: #2b2240;
            --muted: #8b8298;
            --green: #52d579;
            --red: #ff6666;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            background: var(--page);
            color: var(--ink);
            font-family: "Instrument Sans", Arial, sans-serif;
        }
        a { color: inherit; text-decoration: none; }
        button { font-family: inherit; }
        .app {
            width: 100%;
            min-height: 100vh;
            display: grid;
            grid-template-columns: 205px 1fr;
            margin: 0;
            background: var(--page);
            position: relative;
        }
        .super-badge {
            position: absolute;
            top: 0;
            right: 0;
            height: 28px;
            display: grid;
            place-items: center;
            padding: 0 18px;
            background: var(--purple);
            color: #fff;
            border-radius: 0 0 0 8px;
            font-size: 10px;
            font-weight: 800;
        }
        .sidebar {
            display: flex;
            flex-direction: column;
            padding: 45px 0 34px;
            background: var(--purple);
            color: #fff;
        }
        .logo {
            margin: 0 0 36px;
            padding-left: 52px;
            font-size: 22px;
            line-height: .95;
            font-weight: 800;
        }
        .nav a {
            min-height: 39px;
            display: flex;
            align-items: center;
            padding: 0 18px 0 38px;
            font-size: 11px;
            font-weight: 800;
        }
        .nav a.active {
            background: rgba(255,255,255,.24);
            border-radius: 0 20px 20px 0;
        }
        .logout {
            margin: auto auto 0;
            color: #fff;
            font-size: 11px;
            font-weight: 800;
        }
        .link-button {
            border: 0;
            padding: 0;
            background: transparent;
            color: inherit;
            cursor: pointer;
            font: inherit;
        }
        .main { padding: 52px 36px 40px; }
        .topbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            margin-bottom: 24px;
        }
        h1 {
            margin: 0;
            color: var(--purple);
            font-size: 25px;
            line-height: 1;
        }
        .panel {
            min-height: 470px;
            padding: 26px;
            border: 1px solid var(--line);
            border-radius: 17px;
            background: var(--panel);
            box-shadow: 0 3px 12px rgba(67, 45, 98, .08);
        }
        .toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 20px;
        }
        .tabs {
            display: inline-flex;
            overflow: hidden;
            border: 1px solid var(--purple);
            border-radius: 999px;
            background: #fff;
        }
        .tab {
            min-width: 96px;
            height: 27px;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            color: var(--purple);
            font-size: 10px;
            font-weight: 800;
        }
        .tab.active {
            background: var(--purple);
            color: #fff;
        }
        .search {
            width: 240px;
            height: 29px;
            border: 1px solid #e1d9e9;
            border-radius: 999px;
            padding: 0 15px;
            color: var(--muted);
            outline: none;
        }
        .list {
            display: grid;
            gap: 14px;
        }
        .row {
            min-height: 66px;
            display: grid;
            grid-template-columns: 54px 1fr 150px 104px;
            align-items: center;
            gap: 14px;
            padding: 10px 14px;
            border: 1px solid #e6dfef;
            border-radius: 13px;
            background: #fff;
            box-shadow: 0 2px 7px rgba(41, 31, 62, .11);
        }
        .logo-dot {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: radial-gradient(circle, #fff 0 22%, transparent 23%), #1d4aaa;
            border: 2px solid #e6e0ef;
        }
        .logo-dot.gold { background: radial-gradient(circle, #fff 0 22%, transparent 23%), #f0bd3e; }
        .logo-dot.muted { filter: grayscale(1); opacity: .4; }
        .campus-name {
            color: var(--purple);
            font-size: 13px;
            font-weight: 900;
        }
        .meta strong {
            display: block;
            font-size: 11px;
        }
        .meta span, .doc-link {
            color: var(--muted);
            font-size: 10px;
            font-weight: 700;
        }
        .doc-link { color: var(--purple); }
        .actions {
            display: flex;
            justify-content: flex-end;
            gap: 9px;
        }
        .square-btn, .circle-btn {
            width: 28px;
            height: 28px;
            display: inline-grid;
            place-items: center;
            border: 0;
            color: #fff;
            font-size: 13px;
            font-weight: 900;
            cursor: pointer;
        }
        .square-btn { border-radius: 4px; }
        .circle-btn {
            border-radius: 50%;
            background: #fff;
            color: var(--purple);
            border: 2px solid var(--purple);
        }
        .green { background: var(--green); }
        .red { background: var(--red); }
        .pager {
            display: flex;
            justify-content: flex-end;
            margin-top: 22px;
            color: var(--purple);
            font-size: 11px;
            font-weight: 800;
        }
        .mini-pagination {
            display: inline-flex;
            align-items: center;
            gap: 7px;
        }
        .mini-page {
            width: 24px;
            height: 24px;
            display: inline-grid;
            place-items: center;
            border: 1px solid var(--purple);
            border-radius: 7px;
            background: #fff;
            color: var(--purple);
            font-size: 12px;
            font-weight: 900;
        }
        .mini-page.disabled {
            opacity: .35;
        }
        .mini-page-info {
            color: var(--muted);
            font-size: 10px;
            font-weight: 800;
        }
        .flash {
            margin-bottom: 16px;
            padding: 12px 16px;
            border-radius: 8px;
            background: #e9fff1;
            color: #23623a;
            font-size: 12px;
            font-weight: 800;
        }
        .modal-backdrop {
            position: fixed;
            inset: 0;
            display: grid;
            place-items: center;
            background: rgba(40, 33, 53, .28);
            z-index: 20;
        }
        .letter {
            width: min(410px, calc(100vw - 42px));
            min-height: 560px;
            position: relative;
            padding: 44px 52px;
            background: #fff;
            box-shadow: 0 16px 45px rgba(22, 16, 35, .18);
            font-family: Arial, sans-serif;
            color: #111;
        }
        .letter h2 {
            margin: 0 0 10px;
            text-align: center;
            font-size: 12px;
            text-decoration: underline;
        }
        .letter h3 {
            margin: 0 0 22px;
            text-align: center;
            font-size: 16px;
            letter-spacing: 2px;
            text-decoration: underline;
        }
        .letter p {
            font-size: 10px;
            line-height: 1.55;
        }
        .close {
            position: absolute;
            top: 0;
            right: 0;
            width: 28px;
            height: 28px;
            display: grid;
            place-items: center;
            background: #1f2937;
            color: #fff;
            font-weight: 900;
        }
        @media (max-width: 850px) {
            .app { width: 100%; min-height: 100vh; grid-template-columns: 1fr; margin: 0; }
            .sidebar { padding: 20px; }
            .logo { padding-left: 0; margin-bottom: 16px; }
            .nav { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; }
            .nav a, .nav a.active { justify-content: center; padding: 10px; border-radius: 999px; }
            .logout { display: none; }
            .main { padding: 42px 18px; }
            .toolbar { flex-direction: column; align-items: stretch; }
            .search { width: 100%; }
            .row { grid-template-columns: 44px 1fr; }
            .actions { grid-column: 1 / -1; justify-content: start; }
        }
    </style>
</head>
<body>
    <div class="app">
        <span class="super-badge">SUPER ADMIN</span>
        <aside class="sidebar">
            <a class="logo" href="{{ route('superadmin.approvals') }}">Campus<br>Lapor</a>
            <nav class="nav">
                @foreach ($menu as $item)
                    <a href="{{ route($item['route']) }}" class="{{ ($active ?? '') === $item['route'] ? 'active' : '' }}">
                        {{ $item['label'] }}
                    </a>
                @endforeach
            </nav>
            <form method="POST" action="{{ route('logout') }}" class="logout">
                @csrf
                <button class="link-button" type="submit">Log Out</button>
            </form>
        </aside>
        <main class="main">
            @if (session('success'))
                <div class="flash">{{ session('success') }}</div>
            @endif
            @yield('content')
        </main>
    </div>
</body>
</html>
