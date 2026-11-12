<?php

namespace App\Services;

use MongoDB\BSON\ObjectId;
use MongoDB\BSON\Regex;
use MongoDB\Client;
use MongoDB\Collection;

class CampusDataStore
{
    private Collection $locations;
    private Collection $users;
    private Collection $applications;

    public function __construct()
    {
        $client = new Client(config('database.connections.mongodb.dsn'));
        $database = $client->selectDatabase(config('database.connections.mongodb.database'));
        $this->locations = $database->selectCollection('campus_locations');
        $this->users = $database->selectCollection('users');
        $this->applications = $database->selectCollection('admin_applications');
    }

    public function locations(string $campusKey): array
    {
        $shortKey = trim(explode('/', $campusKey)[0]);
        $orConditions = [
            ['campus_key' => $campusKey],
        ];

        if ($shortKey !== '') {
            $regex = new Regex('^' . preg_quote($shortKey) . '(\b|\s|/|$)', 'i');
            $orConditions[] = ['campus_key' => $regex];
        }

        $items = $this->locations
            ->find(['$or' => $orConditions], ['sort' => ['created_at' => -1]])
            ->toArray();

        return array_map(fn ($item) => $this->normalize($item), $items);
    }

    public function addLocation(string $campusKey, array $data): void
    {
        $this->locations->insertOne([
            'campus_key' => $campusKey,
            'nama' => $data['nama'],
            'area' => $data['area'],
            'status' => 'Aktif',
            'created_at' => now()->toIso8601String(),
            'updated_at' => now()->toIso8601String(),
        ]);
    }

    public function civitasUsers(string $campusKey, ?string $adminUsername = null, ?string $campusName = null): array
    {
        $shortKey = trim(explode('/', $campusKey)[0]);
        $orConditions = [
            ['campus_key' => $campusKey],
            ['kode_kampus' => $campusKey],
        ];

        if ($shortKey !== '') {
            $regex = new Regex('^' . preg_quote($shortKey) . '(\b|\s|/|$)', 'i');
            $orConditions[] = ['campus_key' => $regex];
            $orConditions[] = ['kode_kampus' => $regex];
        }

        $sessionCampus = session('auth_kampus') ?: $campusName;
        if (!empty($sessionCampus)) {
            $orConditions[] = ['kampus' => $sessionCampus];
        }

        $sessionUser = session('auth_username') ?: $adminUsername;
        if (!empty($sessionUser)) {
            $orConditions[] = ['admin_username' => $sessionUser];
        }

        $items = $this->users->find(
            ['role' => 'civitas', '$or' => $orConditions],
            ['projection' => ['password' => 0], 'sort' => ['created_at' => -1]]
        )->toArray();

        return array_map(function ($item) {
            $user = $this->normalize($item);
            return [
                'id' => $user['id'],
                'nama' => $user['name'] ?? '-',
                'nim' => $user['identifier'] ?? $user['nim'] ?? '-',
                'email' => $user['email'] ?? '-',
                'role' => $user['civitas_role'] ?? 'Mahasiswa',
                'status' => $user['status'] ?? 'Aktif',
            ];
        }, $items);
    }

    public function adminByUsername(string $username): ?array
    {
        $admin = $this->users->findOne(
            ['username' => $username, 'role' => 'admin'],
            ['projection' => ['password' => 0]]
        );

        return $admin ? $this->normalize($admin) : null;
    }

    public function adminApplicationByUsername(string $username): ?array
    {
        $application = $this->applications->findOne(
            ['username' => $username],
            ['projection' => ['password' => 0]]
        );

        return $application ? $this->normalize($application) : null;
    }

    public function deleteLocation(string $campusKey, string $id): bool
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return false;
        }

        $shortKey = trim(explode('/', $campusKey)[0]);
        $orConditions = [
            ['campus_key' => $campusKey],
        ];

        if ($shortKey !== '') {
            $regex = new Regex('^' . preg_quote($shortKey) . '(\b|\s|/|$)', 'i');
            $orConditions[] = ['campus_key' => $regex];
        }

        $result = $this->locations->deleteOne([
            '_id' => new ObjectId($id),
            '$or' => $orConditions,
        ]);

        return $result->getDeletedCount() > 0;
    }

    public function setCivitasStatus(string $campusKey, string $id, string $status): bool
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return false;
        }

        $shortKey = trim(explode('/', $campusKey)[0]);
        $orConditions = [
            ['campus_key' => $campusKey],
            ['kode_kampus' => $campusKey],
        ];

        if ($shortKey !== '') {
            $regex = new Regex('^' . preg_quote($shortKey) . '(\b|\s|/|$)', 'i');
            $orConditions[] = ['campus_key' => $regex];
            $orConditions[] = ['kode_kampus' => $regex];
        }

        $sessionCampus = session('auth_kampus');
        if (!empty($sessionCampus)) {
            $orConditions[] = ['kampus' => $sessionCampus];
        }

        $sessionUser = session('auth_username');
        if (!empty($sessionUser)) {
            $orConditions[] = ['admin_username' => $sessionUser];
        }

        $result = $this->users->updateOne(
            ['_id' => new ObjectId($id), 'role' => 'civitas', '$or' => $orConditions],
            ['$set' => ['status' => $status, 'updated_at' => now()->toIso8601String()]]
        );

        return $result->getModifiedCount() > 0 || $result->getMatchedCount() > 0;
    }

    private function normalize(object|array $item): array
    {
        $array = json_decode(json_encode($item), true);
        $array['id'] = $array['_id']['$oid'] ?? (string) ($array['_id'] ?? '');

        return $array;
    }
}
