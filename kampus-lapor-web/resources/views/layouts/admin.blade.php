@php
    $menu = [
        ['label' => 'Barang Hilang', 'route' => 'lost-items'],
        ['label' => 'Fasilitas Rusak', 'route' => 'damaged-facilities'],
        ['label' => 'Pesan', 'route' => 'admin.chats'],
        ['label' => 'Manajemen Kampus', 'route' => 'campus-profile'],
    ];
@endphp

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'Admin Campus Lapor' }}</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700,800" rel="stylesheet" />
    <style>
        :root {
            --purple: #8138e9;
            --purple-2: #9a67f0;
            --purple-soft: #efe4ff;
            --page: #f4edff;
            --panel: #f9fcff;
            --line: #dfd7ea;
            --ink: #2b2240;
            --muted: #857996;
            --white: #fff;
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

        .app {
            width: 100%;
            min-height: 100vh;
            display: grid;
            grid-template-columns: 260px 1fr;
            margin: 0;
            background: var(--page);
        }

        .sidebar {
            display: flex;
            flex-direction: column;
            padding: 60px 0 38px;
            background: var(--purple);
            color: var(--white);
        }

        .logo {
            margin: 0 0 48px;
            padding-left: 68px;
            font-size: 32px;
            line-height: .9;
            font-weight: 800;
        }

        .nav {
            display: grid;
            gap: 0;
        }

        .nav a {
            min-height: 44px;
            display: flex;
            align-items: center;
            padding: 0 26px 0 68px;
            font-size: 13px;
            font-weight: 800;
        }

        .nav a.active {
            background: rgba(255,255,255,.26);
            border-radius: 0 22px 22px 0;
        }

        .logout {
            margin: auto auto 0;
            font-size: 13px;
            font-weight: 800;
        }

        .main {
            padding: 58px 52px 44px;
        }

        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 28px;
        }

        h1 {
            margin: 0;
            color: var(--purple);
            font-size: 31px;
            line-height: 1;
            letter-spacing: 0;
        }

        .panel {
            min-height: 548px;
            padding: 28px;
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 18px;
            box-shadow: 0 3px 12px rgba(67, 45, 98, .08);
        }

        .toolbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            margin-bottom: 22px;
        }

        .tabs, .pill-group {
            display: inline-flex;
            align-items: center;
            border: 1px solid var(--purple);
            border-radius: 999px;
            overflow: hidden;
            background: var(--white);
        }

        .tab, .pill {
            min-width: 116px;
            height: 29px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 0;
            background: transparent;
            color: var(--purple);
            font-size: 11px;
            font-weight: 800;
        }

        .tab.active, .pill.active {
            background: var(--purple);
            color: var(--white);
        }

        .search, .select {
            height: 30px;
            border: 1px solid #e2dbea;
            border-radius: 999px;
            background: var(--white);
            color: var(--muted);
            padding: 0 16px;
            outline: none;
            font-size: 11px;
        }

        .search { min-width: 300px; }
        .select { min-width: 150px; }
        .tag-search {
            min-width: 300px;
            appearance: auto;
        }

        .report-list {
            display: grid;
            gap: 18px;
        }

        .report-card, .user-row {
            display: grid;
            align-items: center;
            background: var(--white);
            border: 1px solid #e6dfef;
            border-radius: 14px;
            box-shadow: 0 2px 7px rgba(41, 31, 62, .11);
        }

        .report-card {
            grid-template-columns: 128px 112px 1fr 36px;
            gap: 22px;
            min-height: 104px;
            padding: 14px 16px;
        }

        .person {
            display: grid;
            justify-items: center;
            gap: 7px;
            text-align: center;
            font-size: 10px;
            color: var(--muted);
        }

        .avatar {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background:
                radial-gradient(circle at 50% 42%, #ffe1be 0 18%, transparent 19%),
                radial-gradient(circle at 50% 100%, #72b27d 0 35%, transparent 36%),
                #d7f0dc;
            border: 2px solid #e8dff5;
        }

        .person strong {
            display: block;
            color: var(--ink);
            font-size: 12px;
            line-height: 1.1;
        }

        .thumb {
            width: 112px;
            height: 78px;
            border-radius: 4px;
            background:
                linear-gradient(135deg, rgba(255,255,255,.2), rgba(255,255,255,0)),
                linear-gradient(90deg, #d7dfe1 0 38%, #875a45 39% 48%, #e8f0f2 49% 100%);
            border: 1px solid #ddd5e8;
        }

        .thumb.facility {
            background:
                linear-gradient(0deg, rgba(255,255,255,.3), rgba(255,255,255,0)),
                repeating-linear-gradient(90deg, #c5d6d3 0 18px, #f6f8f9 19px 40px),
                #b8c8c8;
        }

        .thumb-img {
            width: 112px;
            height: 78px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #ddd5e8;
            background: #eef3f6;
        }

        .report-text {
            min-width: 0;
            font-size: 12px;
            line-height: 1.35;
        }

        .location {
            margin-top: 9px;
            color: var(--muted);
            font-size: 10px;
            font-weight: 700;
        }

        .icon-actions {
            display: grid;
            gap: 10px;
            justify-items: center;
            color: var(--purple);
            font-weight: 900;
        }

        .pager {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 28px;
            color: var(--purple);
            font-size: 12px;
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
            background: var(--white);
            color: var(--purple);
            font-size: 12px;
            font-weight: 900;
        }

        .mini-page.disabled {
            opacity: .35;
        }

        .mini-page-info {
            color: var(--muted);
            font-size: 11px;
            font-weight: 800;
        }

        .page-current {
            width: 22px;
            height: 22px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: var(--purple);
            color: var(--white);
        }

        .btn {
            height: 30px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--purple);
            border-radius: 7px;
            padding: 0 16px;
            background: var(--purple);
            color: var(--white);
            font-size: 11px;
            font-weight: 800;
        }

        .btn.outline {
            background: var(--white);
            color: var(--purple);
        }

        .link-button {
            border: 0;
            padding: 0;
            background: transparent;
            color: inherit;
            cursor: pointer;
            font: inherit;
        }

        .chat-list {
            display: grid;
            gap: 14px;
        }

        .chat-row {
            min-height: 72px;
            display: grid;
            grid-template-columns: 54px 1fr auto;
            align-items: center;
            gap: 16px;
            padding: 12px 16px;
            border: 1px solid #e6dfef;
            border-radius: 14px;
            background: var(--white);
            box-shadow: 0 2px 7px rgba(41, 31, 62, .11);
        }

        .chat-row strong {
            display: block;
            font-size: 14px;
        }

        .chat-row p {
            margin: 4px 0 0;
            color: var(--muted);
            font-size: 12px;
        }

        .chat-page {
            min-height: 640px;
            display: grid;
            grid-template-rows: auto 1fr auto;
            gap: 18px;
        }

        .chat-header {
            display: flex;
            align-items: center;
            gap: 14px;
            font-weight: 800;
        }

        .chat-messages {
            display: flex;
            flex-direction: column;
            gap: 12px;
            overflow-y: auto;
            padding: 10px 4px;
        }

        .bubble {
            max-width: min(520px, 80%);
            padding: 12px 16px;
            border-radius: 16px;
            background: var(--white);
            box-shadow: 0 2px 7px rgba(41, 31, 62, .11);
            font-size: 13px;
            line-height: 1.4;
        }

        .bubble.mine {
            align-self: flex-end;
            background: var(--purple);
            color: var(--white);
        }

        .chat-form {
            display: flex;
            gap: 12px;
        }

        .chat-input {
            flex: 1;
            min-height: 42px;
            border: 1px solid #d8cfe7;
            border-radius: 999px;
            padding: 0 18px;
            outline: none;
        }

        .flash {
            margin-bottom: 18px;
            padding: 12px 16px;
            border-radius: 8px;
            background: #e9fff1;
            color: #23623a;
            font-size: 12px;
            font-weight: 800;
        }

        .management-tabs {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 0;
        }

        .profile-card {
            min-height: 548px;
            display: grid;
            place-items: center;
        }

        .profile-form {
            width: min(360px, 100%);
            display: grid;
            gap: 14px;
        }

        .profile-avatar {
            width: 132px;
            height: 132px;
            justify-self: center;
            border-radius: 50%;
            background:
                radial-gradient(circle at 50% 38%, transparent 0 19%, #5f4087 20% 23%, transparent 24%),
                radial-gradient(circle at 50% 80%, transparent 0 36%, #5f4087 37% 40%, transparent 41%),
                #ead8ff;
            border: 0;
        }

        .profile-avatar.image {
            object-fit: cover;
            border: 3px solid #d8c6f1;
            background: #ead8ff;
        }

        .upload-btn {
            justify-self: center;
            cursor: pointer;
        }

        .file-input {
            width: 1px;
            height: 1px;
            position: absolute;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
        }

        .form-error {
            display: block;
            margin-top: 6px;
            color: #c2414a;
            font-size: 11px;
            font-weight: 800;
        }

        label {
            color: var(--purple);
            font-size: 12px;
            font-weight: 800;
        }

        .input-line, textarea {
            width: 100%;
            border: 0;
            border-bottom: 1px solid #d9d2e6;
            background: var(--white);
            padding: 9px 14px;
            color: var(--muted);
            outline: none;
        }

        textarea {
            min-height: 92px;
            resize: vertical;
            border: 1px solid #e1d9ed;
            border-radius: 7px;
        }

        .user-list {
            display: grid;
            gap: 15px;
            margin-top: 20px;
        }

        .user-tools {
            display: grid;
            justify-items: center;
            gap: 16px;
        }

        .user-search-form {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            width: 100%;
        }

        .user-row {
            grid-template-columns: 56px 1fr 70px;
            min-height: 52px;
            padding: 8px 16px;
        }

        .mini-avatar {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: #eaddff;
            border: 2px solid #d7c7ef;
        }

        .user-meta strong {
            display: block;
            font-size: 12px;
        }

        .user-meta span {
            color: var(--muted);
            font-size: 10px;
            font-weight: 700;
        }

        .report-document {
            display: grid;
            justify-items: center;
            gap: 8px;
        }

        .paper {
            width: 360px;
            min-height: 520px;
            padding: 44px 42px;
            background: var(--white);
            border: 1px solid #8b8790;
            color: #111;
            font-family: Arial, sans-serif;
        }

        .paper h2 {
            margin: 0 0 2px;
            text-align: center;
            font-size: 12px;
        }

        .paper p {
            margin: 0 0 18px;
            text-align: center;
            color: var(--purple);
            font-size: 10px;
            font-weight: 700;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 9px;
        }

        th {
            background: var(--purple);
            color: var(--white);
        }

        th, td {
            border: 1px solid #777;
            padding: 5px;
            vertical-align: top;
        }

        .table-img {
            width: 72px;
            height: 54px;
            display: block;
            object-fit: cover;
            background: linear-gradient(135deg, #d5dddd, #869da0);
        }

        .empty-img {
            display: grid;
            place-items: center;
            background: #f4f0fa;
            color: #777;
            font-size: 7px;
            text-align: center;
        }

        @media (max-width: 900px) {
            .app {
                width: 100%;
                min-height: 100vh;
                grid-template-columns: 1fr;
                margin: 0;
            }
            .sidebar {
                padding: 22px;
            }
            .logo { padding-left: 0; margin-bottom: 18px; font-size: 26px; }
            .nav { grid-template-columns: repeat(4, 1fr); gap: 8px; }
            .nav a { justify-content: center; padding: 10px; border-radius: 999px; text-align: center; }
            .nav a.active { border-radius: 999px; }
            .logout { display: none; }
            .main { padding: 32px 18px; }
            .topbar, .toolbar { align-items: stretch; flex-direction: column; }
            .search, .select { min-width: 0; width: 100%; }
            .report-card { grid-template-columns: 1fr; justify-items: start; }
            .chat-row { grid-template-columns: 44px 1fr; }
            .chat-form { flex-direction: column; }
            .user-search-form { flex-direction: column; }
            .paper { width: 100%; }
        }

        @media print {
            body {
                background: #fff;
            }

            .app {
                display: block;
                background: #fff;
            }

            .sidebar,
            .no-print,
            .flash {
                display: none !important;
            }

            .main {
                padding: 0;
            }

            .panel {
                min-height: 0;
                padding: 0;
                border: 0;
                border-radius: 0;
                box-shadow: none;
                background: #fff;
            }

            .report-document {
                display: block;
            }

            .paper {
                width: 100%;
                min-height: 0;
                page-break-after: always;
                border: 0;
                padding: 24px 32px;
            }

            .table-img {
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }

            .paper:last-child {
                page-break-after: auto;
            }
        }
    </style>
</head>
<body>
    <div class="app">
        <aside class="sidebar">
            <a class="logo" href="{{ route('lost-items') }}">Campus<br>Lapor</a>
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
