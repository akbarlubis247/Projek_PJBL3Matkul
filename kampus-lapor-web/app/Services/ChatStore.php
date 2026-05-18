<?php

namespace App\Services;

use Illuminate\Support\Str;
use MongoDB\Client;
use MongoDB\Collection;

class ChatStore
{
    private Collection $collection;

    public function __construct()
    {
        $client = new Client(config('database.connections.mongodb.dsn'));
        $this->collection = $client
            ->selectDatabase(config('database.connections.mongodb.database'))
            ->selectCollection('chat_threads');
    }

    public function threads(?array $participantIds = null): array
    {
        $filter = [];
        if (is_array($participantIds)) {
            $filter = ['participant_id' => ['$in' => $participantIds]];
        }

        $threads = $this->collection
            ->find($filter, ['projection' => ['_id' => 0], 'sort' => ['last_at' => -1]])
            ->toArray();

        return array_map(fn ($thread) => json_decode(json_encode($thread), true), $threads);
    }

    public function unreadForAdmin(?array $participantIds = null): int
    {
        return collect($this->threads($participantIds))
            ->filter(fn ($thread) => collect($thread['messages'] ?? [])->contains(
                fn ($message) => ($message['sender_role'] ?? '') === 'civitas' && empty($message['read_by_admin'])
            ))
            ->count();
    }

    public function markAdminRead(string $participantId): void
    {
        $thread = $this->thread($participantId);
        if (! $thread) {
            return;
        }

        foreach ($thread['messages'] as &$message) {
            if (($message['sender_role'] ?? '') === 'civitas') {
                $message['read_by_admin'] = true;
            }
        }

        $this->collection->updateOne(
            ['participant_id' => $participantId],
            ['$set' => ['messages' => $thread['messages']]]
        );
    }

    public function thread(string $participantId): ?array
    {
        $thread = $this->collection->findOne(
            ['participant_id' => $participantId],
            ['projection' => ['_id' => 0]]
        );

        return $thread ? json_decode(json_encode($thread), true) : null;
    }

    public function send(array $payload): array
    {
        $participantId = $payload['sender_role'] === 'admin'
            ? $payload['receiver_id']
            : $payload['sender_id'];

        $message = [
            'id' => (string) Str::uuid(),
            'sender_id' => $payload['sender_id'],
            'sender_name' => $payload['sender_name'],
            'sender_role' => $payload['sender_role'],
            'receiver_id' => $payload['receiver_id'],
            'receiver_name' => $payload['receiver_name'],
            'body' => $payload['body'],
            'read_by_admin' => $payload['sender_role'] === 'admin',
            'created_at' => now()->toIso8601String(),
        ];

        $this->collection->updateOne(
            ['participant_id' => $participantId],
            [
                '$setOnInsert' => [
                    'participant_id' => $participantId,
                    'participant_name' => $payload['sender_role'] === 'admin' ? $payload['receiver_name'] : $payload['sender_name'],
                    'participant_role' => 'civitas',
                    'participant_identifier' => $payload['sender_role'] === 'admin' ? ($payload['receiver_identifier'] ?? $participantId) : ($payload['sender_identifier'] ?? $participantId),
                ],
                '$push' => ['messages' => $message],
                '$set' => [
                    'last_message' => $message['body'],
                    'last_at' => $message['created_at'],
                ],
            ],
            ['upsert' => true]
        );

        return $message;
    }
}
