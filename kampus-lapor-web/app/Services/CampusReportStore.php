<?php

namespace App\Services;

use MongoDB\BSON\ObjectId;
use MongoDB\Client;
use MongoDB\Collection;

class CampusReportStore
{
    private Collection $reports;
    private Collection $users;

    public function __construct()
    {
        $client = new Client(config('database.connections.mongodb.dsn'));
        $database = $client->selectDatabase(config('database.connections.mongodb.database'));
        $this->reports = $database->selectCollection('campus_reports');
        $this->users = $database->selectCollection('users');
    }

    public function createFromMobile(array $data): array
    {
        $user = $this->users->findOne([
            '$or' => [
                ['username' => $data['reporter_id']],
                ['identifier' => $data['reporter_id']],
                ['nim' => $data['reporter_id']],
            ],
            'role' => 'civitas',
        ]);

        $campusKey = $user['campus_key'] ?? $user['kode_kampus'] ?? 'admin1';
        $report = [
            'campus_key' => $campusKey,
            'category' => $data['category'],
            'title' => $data['title'],
            'location' => $data['location'],
            'tag' => $data['tag'] ?? null,
            'status' => $data['category'] === 'Fasilitas Rusak' ? 'Dilaporkan' : 'Aktif',
            'description' => $data['description'] ?? '',
            'reporter_id' => $data['reporter_id'],
            'reporter_name' => $user['name'] ?? $data['reporter_name'],
            'photo_data' => $data['photo_data'] ?? null,
            'created_at' => now()->toIso8601String(),
            'updated_at' => now()->toIso8601String(),
        ];

        $result = $this->reports->insertOne($report);
        $report['id'] = (string) $result->getInsertedId();

        return $report;
    }

    public function forCampus(string $campusKey): array
    {
        $items = $this->reports
            ->find(['campus_key' => $campusKey], ['sort' => ['created_at' => -1]])
            ->toArray();

        return array_map(fn ($item) => $this->normalize($item), $items);
    }

    public function forReporter(string $reporterId): array
    {
        $items = $this->reports
            ->find(['reporter_id' => $reporterId], ['sort' => ['created_at' => -1]])
            ->toArray();

        return array_map(fn ($item) => $this->normalize($item), $items);
    }

    public function updateStatus(string $campusKey, string $id, string $status): bool
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return false;
        }

        $result = $this->reports->updateOne(
            ['_id' => new ObjectId($id), 'campus_key' => $campusKey],
            ['$set' => ['status' => $status, 'updated_at' => now()->toIso8601String()]]
        );

        return $result->getMatchedCount() > 0;
    }

    private function normalize(object|array $item): array
    {
        $array = json_decode(json_encode($item), true);
        $array['id'] = $array['_id']['$oid'] ?? (string) ($array['_id'] ?? '');

        return $array;
    }
}
