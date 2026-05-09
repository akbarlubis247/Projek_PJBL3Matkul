@extends('layouts.auth', ['title' => 'Login - Campus Lapor'])

@section('content')
    <section class="auth-shell" style="position: relative;">
        <a class="btn" href="{{ route('superadmin.login') }}" style="position: absolute; right: 0; top: 0; border-radius: 0 0 0 10px;">SUPER ADMIN</a>
        <aside class="auth-panel">
            <div class="brand">
                <h1>Campus<br>Lapor</h1>
                <p>Masukan akun adminmu, semua laporan menunggumu.</p>
            </div>
        </aside>

        <main class="auth-form-wrap">
            <form class="auth-form" method="POST" action="{{ route('login.submit') }}">
                @csrf
                <h2>Sign In</h2>
                <input class="field" type="email" name="email" value="{{ old('email') }}" placeholder="Email Kampus" required>
                <input class="field" type="password" name="password" placeholder="Password" required>
                @if ($errors->any())
                    <p class="hint" style="color: #e34848; font-weight: 800;">{{ $errors->first() }}</p>
                @endif
                @if (session('success'))
                    <p class="hint" style="color: #2f9461; font-weight: 800;">{{ session('success') }}</p>
                @endif
                <p class="hint">Belum punya akun admin? <a href="{{ route('register') }}">klik sign up</a></p>
                <button class="btn" type="submit">SIGN IN</button>
            </form>
        </main>
    </section>
@endsection
