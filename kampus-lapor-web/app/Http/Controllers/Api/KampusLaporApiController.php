<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AdminApplicationStore;
use App\Services\CampusDataStore;
use App\Services\CampusReportStore;
use App\Services\ChatStore;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use MongoDB\BSON\ObjectId;
use MongoDB\Client;

class KampusLaporApiController extends Controller
{
    public function loginSuperAdmin(Request $request)
    {
        return $this->loginRole($request, 'superadmin');
    }

    public function loginAdminKampus(Request $request)
    {
        return $this->loginRole($request, 'admin');
    }

    public function loginCivitas(Request $request)
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

        return response()->json(['user' => $this->publicUser($user)]);
    }

    public function registerKampus(Request $request, AdminApplicationStore $applications)
    {
        $data = $request->validate([
            'nama' => 'required|string|max:120',
            'username' => 'required|string|max:60',
            'email' => 'required|email|max:160',
            'password' => 'required|string|min:6',
            'nidn' => 'required|string|max:60',
            'phone' => 'nullable|string|max:40',
            'kampus' => 'required|string|max:160',
            'kode_kampus' => 'required|string|max:80',
            'alamat_kampus' => 'nullable|string|max:220',
            'unit' => 'required|string|max:120',
            'alasan' => 'required|string|max:500',
        ]);

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

        return response()->json(['message' => 'Akun menunggu persetujuan admin kampus.', 'status' => 'Menunggu'], 201);
    }

    public function kampusList(AdminApplicationStore $applications)
    {
        return response()->json(['data' => $applications->all()]);
    }

    public function kampusStatus(string $id, Request $request, AdminApplicationStore $applications)
    {
        $data = $request->validate(['status' => 'required|in:Disetujui,Ditolak,Menunggu']);

        return response()->json(['success' => $applications->updateStatus($id, $data['status'])]);
    }

    public function civitasList(Request $request, CampusDataStore $campusData)
    {
        return response()->json(['data' => $campusData->civitasUsers($request->query('campus_key', $request->query('kode_kampus', '')))]);
    }

    public function civitasStatus(string $id, Request $request, CampusDataStore $campusData)
    {
        $data = $request->validate(['status' => 'required|in:Aktif,Banned,Menunggu', 'campus_key' => 'required|string']);

        return response()->json(['success' => $campusData->setCivitasStatus($data['campus_key'], $id, $data['status'])]);
    }

    public function approvedKampus()
    {
        $admins = $this->users()->find(['role' => 'admin', 'status' => 'aktif'], ['projection' => ['password' => 0]])->toArray();

        return response()->json(['data' => array_map(fn ($item) => $this->publicUser($item), $admins)]);
    }

    public function storeLaporanBarang(Request $request, CampusReportStore $reports)
    {
        return $this->storeReport($request, $reports, 'Barang Hilang');
    }

    public function storeLaporanFasilitas(Request $request, CampusReportStore $reports)
    {
        return $this->storeReport($request, $reports, 'Fasilitas Rusak');
    }

    public function laporanBarang(Request $request, CampusReportStore $reports)
    {
        return $this->reportList($request, $reports, 'Barang Hilang');
    }

    public function laporanFasilitas(Request $request, CampusReportStore $reports)
    {
        return $this->reportList($request, $reports, 'Fasilitas Rusak');
    }

    public function laporanDetail(string $id)
    {
        $report = $this->reportById($id);

        return $report ? response()->json(['data' => $report]) : response()->json(['message' => 'Laporan tidak ditemukan.'], 404);
    }

    public function laporanStatus(string $id, Request $request)
    {
        $data = $request->validate(['status' => 'required|string']);
        $updated = $this->updateReport($id, ['status' => $data['status']]);

        return response()->json(['success' => $updated]);
    }

    public function laporanUpdate(string $id, Request $request)
    {
        $data = $request->only(['title', 'location', 'tag', 'description', 'photo_data']);
        $updated = $this->updateReport($id, array_filter($data, fn ($value) => $value !== null));

        return response()->json(['success' => $updated]);
    }

    public function storeChat(Request $request, ChatStore $chatStore)
    {
        $data = $request->validate([
            'sender_id' => 'required',
            'sender_name' => 'required',
            'sender_role' => 'required|in:admin,civitas',
            'receiver_id' => 'required',
            'receiver_name' => 'required',
            'body' => 'required',
            'sender_identifier' => 'nullable',
            'receiver_identifier' => 'nullable',
        ]);

        return response()->json(['message' => $chatStore->send($data)], 201);
    }

    public function chatThread(string $participantId, ChatStore $chatStore)
    {
        return response()->json(['thread' => $chatStore->thread($participantId)]);
    }

    public function notifications(Request $request)
    {
        return response()->json(['data' => []]);
    }

    public function notificationRead(string $id)
    {
        return response()->json(['success' => true, 'id' => $id]);
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

    private function storeReport(Request $request, CampusReportStore $reports, string $category)
    {
        $data = $request->validate([
            'reporter_id' => 'required|string',
            'reporter_name' => 'required|string',
            'title' => 'required|string|max:160',
            'location' => 'required|string|max:160',
            'tag' => 'nullable|string|max:80',
            'description' => 'nullable|string|max:1000',
            'photo_data' => 'nullable|string',
        ]);
        $data['category'] = $category;

        return response()->json(['report' => $reports->createFromMobile($data)], 201);
    }

    private function reportList(Request $request, CampusReportStore $reports, string $category)
    {
        $items = collect($reports->forCampus($request->query('campus_key', $request->query('kode_kampus', ''))))
            ->where('category', $category)
            ->values();

        return response()->json(['data' => $items]);
    }

    private function reportById(string $id): ?array
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return null;
        }

        $report = $this->db()->selectCollection('campus_reports')->findOne(['_id' => new ObjectId($id)]);
        if (! $report) {
            return null;
        }

        $array = json_decode(json_encode($report), true);
        $array['id'] = $array['_id']['$oid'] ?? $id;

        return $array;
    }

    private function updateReport(string $id, array $data): bool
    {
        if (! preg_match('/^[a-f\d]{24}$/i', $id)) {
            return false;
        }

        $data['updated_at'] = now()->toIso8601String();
        $result = $this->db()->selectCollection('campus_reports')->updateOne(['_id' => new ObjectId($id)], ['$set' => $data]);

        return $result->getMatchedCount() > 0;
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

    private function publicUser(object|array $user): array
    {
        $array = json_decode(json_encode($user), true);
        $array['id'] = $array['_id']['$oid'] ?? (string) ($array['_id'] ?? '');
        unset($array['_id'], $array['password']);

        return $array;
    }

    private function users()
    {
        return $this->db()->selectCollection('users');
    }

    private function db()
    {
        return (new Client(config('database.connections.mongodb.dsn')))
            ->selectDatabase(config('database.connections.mongodb.database'));
    }
}
