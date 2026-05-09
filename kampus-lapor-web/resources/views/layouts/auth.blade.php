<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'Campus Lapor' }}</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600,700" rel="stylesheet" />
    <style>
        :root {
            --purple: #8037e8;
            --purple-dark: #6f2ddb;
            --purple-soft: #eadcff;
            --ink: #24183d;
            --muted: #8d83a3;
            --surface: #f5efff;
            --white: #fff;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            background: var(--surface);
            color: var(--ink);
            font-family: "Instrument Sans", Arial, sans-serif;
        }

        .auth-shell {
            width: 100%;
            min-height: 100vh;
            display: grid;
            grid-template-columns: 1fr 1.25fr;
            overflow: hidden;
            background: var(--surface);
        }

        .auth-panel {
            display: grid;
            place-items: center;
            padding: 44px;
            background: linear-gradient(135deg, var(--purple), var(--purple-dark));
            color: var(--white);
            border-radius: 0 22px 22px 0;
        }

        .auth-panel.right { border-radius: 22px 0 0 22px; }

        .brand {
            text-align: center;
        }

        .brand h1 {
            margin: 0;
            font-size: clamp(36px, 5vw, 58px);
            line-height: .9;
            letter-spacing: 0;
        }

        .brand p {
            max-width: 290px;
            margin: 22px auto 0;
            font-size: 14px;
            font-weight: 700;
            line-height: 1.45;
        }

        .auth-form-wrap {
            display: grid;
            place-items: center;
            padding: 54px;
        }

        .auth-form {
            width: min(360px, 100%);
            text-align: center;
        }

        .auth-form h2 {
            margin: 0 0 32px;
            color: var(--purple);
            font-size: 31px;
            line-height: 1;
        }

        .field {
            width: 100%;
            height: 38px;
            margin-bottom: 16px;
            border: 0;
            border-radius: 7px;
            padding: 0 18px;
            background: var(--white);
            color: var(--ink);
            box-shadow: 0 1px 0 rgba(60, 41, 95, .08);
            outline: none;
        }

        .field::placeholder { color: #b6abc7; }

        .hint {
            margin: -2px 0 16px;
            color: var(--purple);
            font-size: 11px;
            font-weight: 600;
        }

        .btn {
            min-width: 170px;
            height: 36px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 0;
            border-radius: 5px;
            background: var(--purple);
            color: var(--white);
            font-weight: 800;
            font-size: 12px;
            text-decoration: none;
            cursor: pointer;
        }

        .steps {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            align-items: end;
            gap: 12px;
            margin-bottom: 28px;
            color: var(--purple);
            font-size: 10px;
            font-weight: 600;
        }

        .step {
            position: relative;
            display: grid;
            justify-items: center;
            gap: 8px;
        }

        .step::after {
            content: "";
            position: absolute;
            left: 50%;
            right: -50%;
            bottom: 5px;
            height: 2px;
            background: #d8c2ff;
            z-index: 0;
        }

        .step:last-child::after { display: none; }
        .dot {
            width: 18px;
            height: 18px;
            border-radius: 50%;
            background: #d8c2ff;
            z-index: 1;
        }
        .step.active .dot { background: var(--purple); }

        .upload-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin: 10px 0 18px;
        }

        .upload {
            min-height: 88px;
            display: grid;
            place-items: center;
            border: 1px dashed #b99df0;
            border-radius: 7px;
            background: rgba(255,255,255,.55);
            color: var(--muted);
            font-size: 10px;
            font-weight: 700;
        }

        .actions {
            display: flex;
            justify-content: space-between;
            gap: 16px;
        }

        @media (max-width: 800px) {
            .auth-shell { grid-template-columns: 1fr; min-height: auto; }
            .auth-panel, .auth-panel.right { min-height: 280px; border-radius: 0 0 22px 22px; }
            .auth-panel.right { order: -1; }
            .auth-form-wrap { padding: 40px 24px; }
        }
    </style>
</head>
<body>
    @yield('content')
</body>
</html>
