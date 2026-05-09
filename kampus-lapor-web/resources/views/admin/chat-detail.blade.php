@extends('layouts.admin', ['title' => 'Detail Pesan', 'active' => 'admin.chats'])

@section('content')
    <div class="topbar">
        <div class="chat-header">
            <a href="{{ route('admin.chats') }}" style="color: var(--purple); font-weight: 900; font-size: 24px;">&lt;</a>
            <span class="avatar"></span>
            <div>
                <h1 style="font-size: 24px;">{{ $participant?->name ?? 'Civitas' }}</h1>
                <span style="color: var(--muted); font-size: 12px; font-weight: 700;">{{ $participant?->username ? '@'.$participant->username : '' }}</span>
            </div>
        </div>
    </div>

    <section class="panel chat-page">
        <div></div>
        <div class="chat-messages">
            @forelse ($messages as $message)
                <div class="bubble {{ (string) $message->sender_id === (string) auth()->id() ? 'mine' : '' }}">
                    {{ $message->body }}
                </div>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada pesan.</p>
            @endforelse
        </div>
        <form class="chat-form" method="POST" action="{{ route('admin.chats.send', $conversation) }}">
            @csrf
            <input class="chat-input" type="text" name="message" placeholder="Ketik pesan ..." required>
            <button class="btn" type="submit">Kirim</button>
        </form>
    </section>
@endsection
