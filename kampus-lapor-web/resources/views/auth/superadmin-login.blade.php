@extends('layouts.auth', ['title' => 'Super Admin Login - Campus Lapor'])

@section('content')
    <section class="auth-shell" style="position: relative;">
        <a class="btn" href="{{ route('login') }}" style="position: absolute; right: 0; top: 0; border-radius: 0 0 0 10px;">ADMIN</a>
        <aside class="auth-panel">
            <div class="brand">
                <h1>Campus<br>Lapor</h1>
                <p>Masuk akun super adminmu broder</p>
            </div>
        </aside>

        <main class="auth-form-wrap">
            <form class="auth-form" method="POST" action="{{ route('superadmin.login.submit') }}">
                @csrf
                <h2>Sign In</h2>
                <input class="field" type="email" name="email" value="{{ old('email') }}" placeholder="Email" required>
                <input class="field" type="password" name="password" placeholder="Password" required>
                @if ($errors->any())
                    <p class="hint" style="color: #e34848; font-weight: 800;">{{ $errors->first() }}</p>
                @endif
                <button class="btn" type="submit">SIGN IN</button>
            </form>
        </main>
    </section>
@endsection
