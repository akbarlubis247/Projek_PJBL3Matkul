<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class ChatController extends Controller
{
    public function index(): View
    {
        $admin = Auth::user();

        $conversations = Conversation::with(['latestMessage.sender'])
            ->where('campus_id', $admin->campus_id)
            ->where('participant_ids', (string) $admin->id)
            ->latest('updated_at')
            ->get();

        return view('admin.chats', compact('conversations'));
    }

    public function show(Conversation $conversation): View
    {
        $admin = Auth::user();
        $this->authorizeConversation($conversation, $admin);

        $messages = $conversation->messages()->with('sender')->oldest()->get();
        $participant = $conversation->participants->firstWhere('id', '!=', $admin->id);

        return view('admin.chat-detail', compact('conversation', 'messages', 'participant'));
    }

    public function start(User $user): RedirectResponse
    {
        $admin = Auth::user();

        abort_unless(
            $user->campus_id === $admin->campus_id
            && $user->role === 'student'
            && $user->status === 'active',
            404
        );

        $conversation = $this->findOrCreatePrivateConversation($admin, $user);

        return redirect()->route('admin.chats.show', $conversation);
    }

    public function send(Request $request, Conversation $conversation): RedirectResponse
    {
        $admin = Auth::user();
        $this->authorizeConversation($conversation, $admin);

        $validated = $request->validate([
            'message' => ['required', 'string', 'max:1000'],
        ]);

        $message = $conversation->messages()->create([
            'sender_id' => $admin->id,
            'body' => $validated['message'],
        ]);
        $conversation->touch();

        $conversation->participants
            ->where('id', '!=', $admin->id)
            ->each(fn (User $participant) => $participant->notifications()->create([
                'title' => 'Pesan baru dari Admin',
                'body' => $message->body,
            ]));

        return back();
    }

    private function authorizeConversation(Conversation $conversation, User $admin): void
    {
        abort_unless(
            $conversation->campus_id === $admin->campus_id
            && $conversation->hasParticipant($admin),
            404
        );
    }

    private function findOrCreatePrivateConversation(User $admin, User $user): Conversation
    {
        $conversation = Conversation::where('campus_id', $admin->campus_id)
            ->where('participant_ids', (string) $admin->id)
            ->where('participant_ids', (string) $user->id)
            ->first();

        if ($conversation) {
            return $conversation;
        }

        return Conversation::create([
            'campus_id' => $admin->campus_id,
            'subject' => 'Percakapan '.$admin->name.' dan '.$user->name,
            'participant_ids' => [(string) $admin->id, (string) $user->id],
        ]);
    }
}
