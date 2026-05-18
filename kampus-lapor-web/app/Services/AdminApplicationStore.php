<?php

namespace App\Services;

use Illuminate\Support\Facades\Hash;
use MongoDB\BSON\ObjectId;
use MongoDB\Client;
use MongoDB\Collection;

class AdminApplicationStore
{
    private Collection $applications;

    private Collection $users;

    public function __construct()
    {
        $client = new Client(config('database.connections.mongodb.dsn'));
        $database = $client->selectDatabase(config('database.connections.mongodb.database'));
        $this->applications = $database->selectCollection('admin_applications');
        $this->users = $database->selectCollection('users');
    }

    public function all(): array
    {
        $items = $this->applications
            ->find([], ['projection' => ['password' => 0], 'sort' => ['created_at' => -1]])
            ->toArray();

        return array_map(fn ($item) => $this->normalize($item), $items);
    }

    public function approvedAdmins(): array
    {
        $items = $this->users
            ->find(
                ['role' => 'admin'],
                ['projection' => ['password' => 0], 'sort' => ['created_at' => -1, 'name' => 1]]
            )
            ->toArray();

        return array_map(fn ($item) => $this->normalize($item), $items);
    }

    public function create(array $data): string
    {
        $insert = $this->applications->insertOne([
            'nama' => $data['nama'],
            'username' => $data['username'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'nidn' => $data['nidn'],
            'phone' => $data['phone'] ?? null,
            'kampus' => $data['kampus'],
            'kode_kampus' => $data['kode_kampus'] ?? null,
            'alamat_kampus' => $data['alamat_kampus'] ?? null,
            'unit' => $data['unit'],
            'role' => 'Calon Admin',
            'status' => 'Menunggu',
            'alasan' => $data['alasan'],
            'created_at' => now()->toIso8601String(),
            'updated_at' => now()->toIso8601String(),
        ]);

        return (string) $insert->getInsertedId();
    }

    public function updateStatus(string $id, string $status): bool
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return false;
        }

        $application = $this->applications->findOne(['_id' => new ObjectId($id)]);
        if (! $application) {
            return false;
        }

        $this->applications->updateOne(
            ['_id' => new ObjectId($id)],
            ['$set' => ['status' => $status, 'updated_at' => now()->toIso8601String()]]
        );

        if ($status === 'Disetujui') {
            $this->users->updateOne(
                ['username' => $application['username']],
                ['$set' => [
                    'name' => $application['nama'],
                    'username' => $application['username'],
                    'email' => $application['email'],
                    'password' => $application['password'],
                    'role' => 'admin',
                    'status' => 'aktif',
                    'identifier' => $application['nidn'],
                    'unit' => $application['unit'],
                    'kampus' => $application['kampus'],
                    'kode_kampus' => $application['kode_kampus'] ?? null,
                    'alamat_kampus' => $application['alamat_kampus'] ?? null,
                    'phone' => $application['phone'] ?? null,
                    'updated_at' => now()->toIso8601String(),
                ], '$setOnInsert' => ['created_at' => now()->toIso8601String()]],
                ['upsert' => true]
            );
        }

        return true;
    }

    private function normalize(object|array $item): array
    {
        $array = json_decode(json_encode($item), true);
        $array['id'] = $array['_id']['$oid'] ?? (string) ($array['_id'] ?? '');

        return $array;
    }
}
