<?php

namespace App\Http\Controllers\Api;

use App\Services\AdminApplicationStore;
use App\Services\CampusDataStore;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthApiController extends BaseApiController
{
    public function loginSuperAdmin(Request $request)
    {
        return $this->loginRole($request, 'superadmin');
    }

    public function loginAdminKampus(Request $request)
    {
        return $this->loginRole($request, 'admin');
    }

    public function loginCivitas(Request $request, CampusDataStore $campusData)
    {
        $data = $request->validate(['username' => 'required|string', 'password' => 'required|string']);
        $user = $this->users()->findOne([
            'username' => $data['username'],
            'role' => 'civitas',
            'status' => ['$in' => ['Aktif', 'aktif']],
        ]);

        if (! $user || ! Hash::check($data['password'], $user['password'] ?? '')) {
            return response()->json(['message' => 'Username atau password tidak sesuai.'], 422);
        }

        $payload = $this->publicUser($user);
        $payload['locations'] = $campusData->locations($payload['campus_key'] ?? $payload['kode_kampus'] ?? '');

        return response()->json(['message' => 'Login berhasil.', 'user' => $payload]);
    }

    public function registerKampus(Request $request, AdminApplicationStore $applications)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:120',
            'username' => 'required|string|max:60',
            'email' => 'required|email|max:160',
            'password' => 'required|string|min:6',
            'nidn' => 'required|string|max:60',
            'phone' => 'required|string|max:40',
            'kampus' => 'required|string|max:160',
            'kode_kampus' => 'required|string|max:80',
            'alamat_kampus' => 'required|string|max:220',
            'unit' => 'required|string|max:120',
            'alasan' => 'required|string|max:500',
        ]);

        if ($applications->activeIdentityExists($data['username'], $data['email'])) {
            return response()->json([
                'message' => 'Username atau email sudah digunakan. Coba pakai data admin kampus yang lain.',
            ], 422);
        }

        return response()->json(['id' => $applications->create($data), 'status' => 'Menunggu'], 201);
    }

    public function registerCivitas(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:120',
            'nim' => 'required|string|max:60',
            'email' => 'required|email|max:160',
            'password' => 'required|string|min:6',
        ]);

        $domain = strtolower(substr(strrchr($data['email'], '@') ?: '', 1));
        $admin = $this->findAdminByDomain($domain);
        if (! $admin) {
            return response()->json(['message' => "Domain @{$domain} belum punya admin aktif."], 422);
        }

        $user = [
            'name' => $data['name'],
            'username' => $data['nim'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => 'civitas',
            'civitas_role' => 'Mahasiswa',
            'status' => 'Menunggu',
            'identifier' => $data['nim'],
            'nim' => $data['nim'],
            'kampus' => $admin['kampus'] ?? null,
            'kode_kampus' => $admin['kode_kampus'] ?? $domain,
            'campus_key' => $admin['kode_kampus'] ?? $domain,
            'admin_username' => $admin['username'],
            'created_at' => now()->toIso8601String(),
            'updated_at' => now()->toIso8601String(),
        ];
        $this->users()->insertOne($user);

        return response()->json(['message' => 'Akun menunggu persetujuan admin kampus.', 'pending' => true, 'status' => 'Menunggu'], 201);
    }

    private function loginRole(Request $request, string $role)
    {
        $data = $request->validate(['username' => 'required|string', 'password' => 'required|string']);
        $user = $this->users()->findOne(['username' => $data['username'], 'role' => $role, 'status' => 'aktif']);

        if (! $user || ! Hash::check($data['password'], $user['password'] ?? '')) {
            return response()->json(['message' => 'Username atau password tidak sesuai.'], 422);
        }

        return response()->json(['user' => $this->publicUser($user)]);
    }

    private function findAdminByDomain(string $domain): ?array
    {
        foreach ($this->users()->find(['role' => 'admin', 'status' => 'aktif']) as $admin) {
            $item = $admin->getArrayCopy();
            $code = strtolower((string) ($item['kode_kampus'] ?? ''));
            if ($code === $domain || str_contains($code, $domain)) {
                return $item;
            }
        }

        return null;
    }
}
