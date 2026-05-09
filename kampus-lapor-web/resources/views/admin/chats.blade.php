@extends('layouts.admin', ['title' => 'Pesan', 'active' => 'admin.chats'])

@section('content')
    <div class="topbar">
        <h1>Pesan</h1>
    </div>

    <section class="panel">
        <div class="chat-list">
            @forelse ($conversations as $conversation)
                @php
                    $participant = $conversation->participants->firstWhere('id', '!=', (string) auth()->id());
                    $latest = $conversation->latestMessage->first();
                @endphp
                <a class="chat-row" href="{{ route('admin.chats.show', $conversation) }}">
                    <span class="avatar"></span>
                    <span>
                        <strong>{{ $participant?->name ?? 'Civitas' }} {{ $participant?->username ? '@'.$participant->username : '' }}</strong>
                        <p>{{ $latest?->body ?? 'Belum ada pesan.' }}</p>
                    </span>
                    <span style="color: var(--muted); font-size: 11px; font-weight: 700;">
                        {{ $conversation->updated_at?->diffForHumans() }}
                    </span>
                </a>
            @empty
                <p style="color: var(--muted); font-weight: 800;">Belum ada pesan dari civitas.</p>
            @endforelse
        </div>
    </section>
@endsection
