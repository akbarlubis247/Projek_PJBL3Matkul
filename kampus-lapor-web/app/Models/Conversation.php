<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Collection;
use MongoDB\Laravel\Eloquent\Model;

class Conversation extends Model
{
    protected $fillable = [
        'campus_id',
        'subject',
        'participant_ids',
    ];

    public function campus(): BelongsTo
    {
        return $this->belongsTo(Campus::class);
    }

    public function getParticipantsAttribute(): Collection
    {
        return $this->participantUsers();
    }

    public function participantUsers(): Collection
    {
        return User::whereIn('_id', $this->participantIds())->get();
    }

    public function hasParticipant(User|string $user): bool
    {
        $userId = $user instanceof User ? $user->id : $user;

        return in_array((string) $userId, $this->participantIds(), true);
    }

    public function participantIds(): array
    {
        $participantIds = $this->participant_ids ?? [];

        if (is_string($participantIds)) {
            $decoded = json_decode($participantIds, true);
            $participantIds = is_array($decoded) ? $decoded : [];
        }

        return collect($participantIds)
            ->map(fn ($id) => (string) $id)
            ->unique()
            ->values()
            ->all();
    }

    public function syncParticipants(array $participantIds): void
    {
        $this->forceFill([
            'participant_ids' => collect($participantIds)
                ->map(fn ($id) => (string) $id)
                ->unique()
                ->values()
                ->all(),
        ])->save();
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class);
    }

    public function latestMessage(): HasMany
    {
        return $this->hasMany(Message::class)->latest();
    }
}
