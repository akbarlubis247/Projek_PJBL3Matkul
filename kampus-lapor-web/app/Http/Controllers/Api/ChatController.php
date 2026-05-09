<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $conversations = Conversation::with(['latestMessage.sender'])
            ->where('participant_ids', (string) $user->id)
            ->latest('updated_at')
            ->get();

        return response()->json([
            'data' => $conversations->map(fn (Conversation $conversation) => $this->conversationPayload($conversation, $user->id)),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'user_id' => ['required', 'string'],
            'message' => ['required', 'string'],
        ]);

        $user = $request->user();
        $target = User::findOrFail($validated['user_id']);

        if ($target->id === $user->id) {
            return response()->json(['message' => 'Kamu tidak bisa mengirim pesan ke akun sendiri.'], 422);
        }

        if ($target->campus_id !== $user->campus_id) {
            return response()->json(['message' => 'User tujuan tidak satu kampus.'], 422);
        }

        $conversation = $this->findOrCreatePrivateConversation($user, $target);

        $this->appendMessage($conversation, $user, $validated['message']);

        $conversation->load(['latestMessage.sender']);

        return response()->json([
            'message' => 'Chat berhasil dibuat.',
            'data' => $this->conversationPayload($conversation, $user->id),
        ], 201);
    }

    public function adminStore(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => ['required', 'string'],
        ]);

        $user = $request->user();
        $admin = User::where('campus_id', $user->campus_id)
            ->where('role', 'admin')
            ->where('status', 'active')
            ->oldest()
            ->first();

        if (! $admin) {
            return response()->json(['message' => 'Admin kampus belum tersedia.'], 404);
        }

        $conversation = $this->findOrCreatePrivateConversation($user, $admin);
        $this->appendMessage($conversation, $user, $validated['message']);

        return response()->json([
            'message' => 'Pesan ke admin berhasil dikirim.',
            'data' => $this->conversationPayload($conversation->load(['latestMessage.sender']), $user->id),
        ], 201);
    }

    public function show(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (! $conversation->hasParticipant($user)) {
            return response()->json(['message' => 'Chat tidak ditemukan.'], 404);
        }

        $messages = $conversation->messages()
            ->with('sender')
            ->oldest()
            ->get();

        return response()->json([
            'data' => [
                'conversation' => $this->conversationPayload($conversation, $user->id),
                'messages' => $messages->map(fn (Message $message) => $this->messagePayload($message)),
            ],
        ]);
    }

    public function sendMessage(Request $request, Conversation $conversation): JsonResponse
    {
        $user = $request->user();

        if (! $conversation->hasParticipant($user)) {
            return response()->json(['message' => 'Chat tidak ditemukan.'], 404);
        }

        $validated = $request->validate([
            'message' => ['required', 'string'],
        ]);

        $message = $conversation->messages()->create([
            'sender_id' => $user->id,
            'body' => $validated['message'],
        ]);
        $conversation->touch();

        $conversation->participants
            ->where('id', '!=', $user->id)
            ->each(fn (User $participant) => $participant->notifications()->create([
                'title' => 'Pesan baru dari '.$user->name,
                'body' => $message->body,
            ]));

        return response()->json([
            'message' => 'Pesan berhasil dikirim.',
            'data' => $this->messagePayload($message->load('sender')),
        ], 201);
    }

    private function findOrCreatePrivateConversation(User $user, User $target): Conversation
    {
        $conversation = Conversation::where('campus_id', $user->campus_id)
            ->where('participant_ids', (string) $user->id)
            ->where('participant_ids', (string) $target->id)
            ->first();

        if ($conversation) {
            return $conversation;
        }

        $conversation = Conversation::create([
            'campus_id' => $user->campus_id,
            'subject' => 'Percakapan '.$user->name.' dan '.$target->name,
            'participant_ids' => [(string) $user->id, (string) $target->id],
        ]);

        return $conversation;
    }

    private function appendMessage(Conversation $conversation, User $sender, string $body): Message
    {
        $message = $conversation->messages()->create([
            'sender_id' => $sender->id,
            'body' => $body,
        ]);
        $conversation->touch();

        $conversation->participants
            ->where('id', '!=', $sender->id)
            ->each(fn (User $participant) => $participant->notifications()->create([
                'title' => 'Pesan baru dari '.$sender->name,
                'body' => $message->body,
            ]));

        return $message;
    }

    private function conversationPayload(Conversation $conversation, string $currentUserId): array
    {
        $other = $conversation->participants->firstWhere('id', '!=', $currentUserId)
            ?? $conversation->participants->first();
        $latest = $conversation->latestMessage->first();

        return [
            'id' => $conversation->id,
            'subject' => $conversation->subject,
            'participant' => $other ? [
                'id' => $other->id,
                'name' => $other->name,
                'username' => $other->username,
                'role' => $other->role,
            ] : null,
            'latest_message' => $latest ? $this->messagePayload($latest) : null,
            'updated_at' => $conversation->updated_at?->toISOString(),
        ];
    }

    private function messagePayload(Message $message): array
    {
        return [
            'id' => $message->id,
            'conversation_id' => $message->conversation_id,
            'sender_id' => $message->sender_id,
            'body' => $message->body,
            'read_at' => $message->read_at?->toISOString(),
            'created_at' => $message->created_at?->toISOString(),
            'sender' => [
                'id' => $message->sender?->id,
                'name' => $message->sender?->name,
                'username' => $message->sender?->username,
                'role' => $message->sender?->role,
            ],
        ];
    }
}
