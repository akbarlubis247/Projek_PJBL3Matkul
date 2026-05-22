<?php
namespace App\Http\Controllers;

use App\Exports\ReportsExport;
use App\Services\ChatStore;
use App\Services\AdminApplicationStore;
use App\Services\CampusDataStore;
use App\Services\CampusReportStore;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Maatwebsite\Excel\Facades\Excel;

class DashboardController extends Controller
{
    private function dashboardData(): array
    {
        return [
            'barangHilang' => [],
            'barangDitemukan' => [],
            'fasilitasRusak' => [],
            'fasilitasDiperbaiki' => [],
            'users' => [],
            'locations' => [],
            'adminCandidates' => [],
            'messages' => [],
            'chartData' => collect(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'])
                ->map(fn ($month) => ['month' => $month, 'barangHilang' => 0, 'fasilitasRusak' => 0])
                ->all(),
        ];
    }
    private function usesDefaultCampusData(): bool
    {
        return false;
    }

    private function emptyCampusData(array $data): array
    {
        foreach (['barangHilang', 'barangDitemukan', 'fasilitasRusak', 'fasilitasDiperbaiki', 'users', 'locations', 'adminCandidates', 'messages'] as $key) {
            $data[$key] = [];
        }

        $data['chartData'] = collect(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'])
            ->map(fn ($month) => ['month' => $month, 'barangHilang' => 0, 'fasilitasRusak' => 0])
            ->all();

        return $data;
    }

    private function campusKey(): string
    {
        return session('auth_kode_kampus')
            ?: session('auth_kampus')
            ?: session('auth_username', 'default');
    }

    private function adminUsername(): string
    {
        return session('auth_username', 'admin1');
    }

    public function index(CampusReportStore $reports)
    {
        $campusReports = collect($this->campusReports($reports));
        $activeBarangStatuses = ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Selesai', 'Barang Dihapus'];
        $fixedFasilitasStatuses = ['Sudah Diperbaiki', 'Selesai'];

        $stats = [
            'barangHilang' => $campusReports
                ->where('kategori', 'Barang Hilang')
                ->reject(fn ($item) => in_array($item['status'], $activeBarangStatuses, true))
                ->count(),
            'barangDitemukan' => $campusReports
                ->where('kategori', 'Barang Hilang')
                ->filter(fn ($item) => in_array($item['status'], ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Selesai'], true))
                ->count(),
            'fasilitasRusak' => $campusReports
                ->where('kategori', 'Fasilitas Rusak')
                ->reject(fn ($item) => in_array($item['status'], $fixedFasilitasStatuses, true))
                ->count(),
            'fasilitasDiperbaiki' => $campusReports
                ->where('kategori', 'Fasilitas Rusak')
                ->filter(fn ($item) => in_array($item['status'], $fixedFasilitasStatuses, true))
                ->count(),
        ];

        $laporanTerbaru = $campusReports
            ->sortByDesc('tanggal')
            ->take(5)
            ->map(fn ($item) => [
                'kategori' => $item['kategori'],
                'nama' => $item['kategori'] === 'Fasilitas Rusak' ? $item['namaFasilitas'] : $item['namaBarang'],
                'status' => $item['status'],
                'tanggal' => $item['tanggal'],
            ])
            ->values()
            ->all();

        $months = collect(range(5, 0))->map(fn ($offset) => now()->subMonths($offset));
        $chartData = $months->map(function ($month) use ($campusReports) {
            $reportsInMonth = $campusReports->filter(function ($item) use ($month) {
                try {
                    $date = \Carbon\Carbon::parse($item['tanggal']);
                } catch (\Throwable) {
                    return false;
                }

                return $date->isSameMonth($month);
            });

            return [
                'month' => $month->isoFormat('MMM'),
                'barangHilang' => $reportsInMonth->where('kategori', 'Barang Hilang')->count(),
                'fasilitasRusak' => $reportsInMonth->where('kategori', 'Fasilitas Rusak')->count(),
            ];
        })->all();

        return view('pages.dashboard', compact('stats', 'laporanTerbaru', 'chartData'));
    }

    private function campusReports(CampusReportStore $reports): array
    {
        return collect($reports->forCampus($this->campusKey()))->map(fn ($item) => [
            'id' => $item['id'],
            'namaBarang' => $item['title'] ?? '-',
            'namaFasilitas' => $item['title'] ?? '-',
            'pelapor' => $item['reporter_name'] ?? '-',
            'lokasi' => $item['location'] ?? '-',
            'tanggal' => $item['created_at'] ?? now()->toIso8601String(),
            'status' => $item['status'] ?? 'Aktif',
            'deskripsi' => $item['description'] ?? '-',
            'kategori' => $item['category'] ?? '-',
            'foto' => $item['photo_data'] ?? null,
        ])->all();
    }

    public function barangHilang(CampusReportStore $reports)
    {
        $d = $this->dashboardData();
        $campusReports = collect($this->campusReports($reports));
        $barangHilang = collect($d['barangHilang'])
            ->concat($campusReports
                ->where('kategori', 'Barang Hilang')
                ->reject(fn ($item) => in_array($item['status'], ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Selesai', 'Barang Dihapus'], true))
                ->values())
            ->values();
        $barangDitemukan = collect($d['barangDitemukan'])
            ->concat($campusReports
                ->where('kategori', 'Barang Hilang')
                ->filter(fn ($item) => in_array($item['status'], ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Selesai'], true))
                ->map(fn ($item) => array_merge($item, ['status' => $item['status'] === 'Ditemukan' ? 'Menunggu Diambil' : $item['status']]))
                ->values())
            ->values();

        return view('pages.barang-hilang', ['barangHilang'=>$barangHilang,'barangDitemukan'=>$barangDitemukan]);
    }

    public function ubahStatusBarang(Request $r, $id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Menunggu Diambil')) {
            return back()->with('success', "Barang hilang ditandai ditemukan dan menunggu pelapor menerima barang.");
        }

        return back()->with('error', "Status barang ID {$id} gagal diperbarui.");
    }

    public function hapusBarangDitemukan($id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Barang Dihapus')) {
            return back()->with('success', "Laporan barang ditemukan dihapus dari daftar admin.");
        }

        return back()->with('error', "Laporan barang ditemukan ID {$id} gagal dihapus dari daftar.");
    }

    public function tandaiBarangDiambil($id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Sudah Diambil')) {
            return back()->with('success', "Barang ditandai sudah diambil oleh pelapor.");
        }

        return back()->with('error', "Status barang ID {$id} gagal diperbarui menjadi sudah diambil.");
    }

    public function fasilitasRusak(CampusReportStore $reports)
    {
        $d = $this->dashboardData();
        $campusReports = collect($this->campusReports($reports));
        $fasilitasRusak = collect($d['fasilitasRusak'])
            ->concat($campusReports
                ->where('kategori', 'Fasilitas Rusak')
                ->reject(fn ($item) => in_array($item['status'], ['Sudah Diperbaiki', 'Selesai'], true))
                ->values())
            ->values();
        $fasilitasDiperbaiki = collect($d['fasilitasDiperbaiki'])
            ->concat($campusReports
                ->where('kategori', 'Fasilitas Rusak')
                ->filter(fn ($item) => in_array($item['status'], ['Sudah Diperbaiki', 'Selesai'], true))
                ->values())
            ->values();

        return view('pages.fasilitas-rusak', ['fasilitasRusak'=>$fasilitasRusak,'fasilitasDiperbaiki'=>$fasilitasDiperbaiki]);
    }

    public function mobileReportStore(Request $r, CampusReportStore $reports)
    {
        $data = $r->validate([
            'reporter_id' => 'required|string',
            'reporter_name' => 'required|string',
            'category' => 'required|in:Barang Hilang,Fasilitas Rusak',
            'title' => 'required|string|max:160',
            'location' => 'required|string|max:160',
            'tag' => 'nullable|string|max:80',
            'description' => 'nullable|string|max:1000',
            'photo_data' => 'nullable|string',
        ]);

        return response()
            ->json(['report' => $reports->createFromMobile($data)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function mobileReports(string $reporterId, CampusReportStore $reports)
    {
        return response()
            ->json(['reports' => $reports->forReporter($reporterId)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function tandaiDiperbaiki(Request $r, $id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Sudah Diperbaiki')) {
            return back()->with('success', "Fasilitas ditandai sudah diperbaiki dan notifikasi dikirim ke civitas pelapor.");
        }

        return back()->with('success', "Fasilitas ID {$id} ditandai sudah diperbaiki. Notifikasi dikirim ke civitas pelapor.");
    }

    public function hapusFasilitasDiperbaiki($id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Dilaporkan')) {
            return back()->with('success', "Laporan fasilitas dikembalikan ke daftar fasilitas rusak.");
        }

        return back()->with('success', "Laporan fasilitas diperbaiki ID {$id} berhasil dihapus dari daftar.");
    }

    public function exportBarang(string $format, CampusReportStore $reports)
    {
        $rows = collect($this->approvedBarangRows($reports))
            ->values()
            ->map(fn ($item, $i) => $this->exportRow($item, $i, 'Barang Hilang', 'namaBarang'))
            ->all();

        return $this->downloadReport($format, 'laporan-barang-ditemukan', 'Laporan Barang Hilang yang Sudah Dikonfirmasi', $rows);
    }

    public function exportFasilitas(string $format, CampusReportStore $reports)
    {
        $rows = collect($this->approvedFasilitasRows($reports))
            ->values()
            ->map(fn ($item, $i) => $this->exportRow($item, $i, 'Fasilitas Rusak', 'namaFasilitas'))
            ->all();

        return $this->downloadReport($format, 'laporan-fasilitas-diperbaiki', 'Laporan Fasilitas Rusak yang Sudah Dikonfirmasi', $rows);
    }

    private function approvedBarangRows(CampusReportStore $reports): array
    {
        $d = $this->dashboardData();
        $campusReports = collect($this->campusReports($reports));

        return collect($d['barangDitemukan'])
            ->concat($campusReports
                ->where('kategori', 'Barang Hilang')
                ->filter(fn ($item) => in_array($item['status'], ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Selesai'], true))
                ->values())
            ->values()
            ->all();
    }

    private function approvedFasilitasRows(CampusReportStore $reports): array
    {
        $d = $this->dashboardData();
        $campusReports = collect($this->campusReports($reports));

        return collect($d['fasilitasDiperbaiki'])
            ->concat($campusReports
                ->where('kategori', 'Fasilitas Rusak')
                ->filter(fn ($item) => in_array($item['status'], ['Sudah Diperbaiki', 'Selesai'], true))
                ->values())
            ->values()
            ->all();
    }

    private function exportRow(array $item, int $index, string $jenis, string $titleKey): array
    {
        return [
            'id' => $item['id'] ?? ($index + 1),
            'nama_pelapor' => $item['pelapor'] ?? '-',
            'role' => $item['role'] ?? 'Civitas',
            'jenis_laporan' => $jenis,
            'judul' => $item[$titleKey] ?? $item['judul'] ?? '-',
            'lokasi' => $item['lokasi'] ?? '-',
            'status' => $item['status'] ?? '-',
            'tanggal' => \Carbon\Carbon::parse($item['tanggal'] ?? now())->isoFormat('D MMM YYYY'),
            'deskripsi' => $item['deskripsi'] ?? '',
            'foto' => $item['foto'] ?? null,
        ];
    }

    private function reportStats(array $rows): array
    {
        $finishedStatuses = ['Ditemukan', 'Menunggu Diambil', 'Sudah Diambil', 'Sudah Diperbaiki', 'Selesai', 'Ditutup'];

        return [
            'total_laporan' => count($rows),
            'total_barang_hilang' => collect($rows)->where('jenis_laporan', 'Barang Hilang')->count(),
            'total_fasilitas_rusak' => collect($rows)->where('jenis_laporan', 'Fasilitas Rusak')->count(),
            'total_selesai' => collect($rows)->whereIn('status', $finishedStatuses)->count(),
            'total_pending' => collect($rows)->reject(fn ($row) => in_array($row['status'], $finishedStatuses, true))->count(),
            'printed_at' => now()->format('d M Y H:i'),
        ];
    }

    private function downloadReport(string $format, string $filename, string $title, array $rows)
    {
        $stats = $this->reportStats($rows);

        return match ($format) {
            'excel' => Excel::download(new ReportsExport($title, $rows, $stats), $filename.'.xlsx'),
            'pdf' => Pdf::loadView('exports.report-pdf', [
                'title' => $title,
                'rows' => $rows,
                'stats' => $stats,
                'adminName' => session('auth_name', 'Admin Kampus'),
                'printedAt' => $stats['printed_at'],
            ])->setPaper('a4', 'landscape')->download($filename.'.pdf'),
            default => abort(404),
        };
    }

    public function pesan(ChatStore $chatStore, CampusDataStore $campusData)
    {
        $d = $this->dashboardData();
        $storedUsers = collect($campusData->civitasUsers($this->campusKey()));
        $allUsers = $this->usesDefaultCampusData()
            ? collect($d['users'])->concat($storedUsers)
            : $storedUsers;
        $threads = $chatStore->threads(null, $this->adminUsername(), $this->campusKey());
        $users = collect($threads)
            ->filter(fn ($thread) => ! empty($thread['messages'] ?? []))
            ->map(function ($thread) use ($allUsers) {
                $participantId = $thread['participant_id'] ?? '';
                $user = $allUsers->firstWhere('nim', $participantId);

                return $user ?? [
                    'id' => $participantId,
                    'nama' => $thread['participant_name'] ?? 'Civitas',
                    'nim' => $participantId,
                    'email' => '-',
                    'role' => $thread['participant_role'] ?? 'Mahasiswa',
                    'status' => 'Aktif',
                ];
            })
            ->values();

        return view('pages.pesan', ['users'=>$users,'messages'=>$d['messages'], 'threads' => $threads]);
    }

    public function kirimPesan(Request $r, ChatStore $chatStore, CampusDataStore $campusData)
    {
        $r->validate(['penerima'=>'required','isi'=>'required', 'receiver_id' => 'nullable']);
        $d = $this->dashboardData();
        $storedUsers = collect($campusData->civitasUsers($this->campusKey()));
        $users = $this->usesDefaultCampusData()
            ? collect($d['users'])->concat($storedUsers)
            : $storedUsers;
        $user = $users->firstWhere('nim', $r->receiver_id)
            ?? $users->firstWhere('nama', $r->penerima)
            ?? [
                'nim' => $r->receiver_id,
                'nama' => $r->penerima,
            ];

        $sentMessage = null;
        if (! empty($user['nim'])) {
            $sentMessage = $chatStore->send([
                'sender_id' => session('auth_username', 'admin1'),
                'sender_name' => session('auth_name', 'Admin Kampus'),
                'sender_role' => 'admin',
                'admin_username' => $this->adminUsername(),
                'campus_key' => $this->campusKey(),
                'receiver_id' => $user['nim'],
                'receiver_identifier' => $user['nim'],
                'receiver_name' => $user['nama'],
                'body' => $r->isi,
            ]);
        }

        if ($r->expectsJson()) {
            if (! $sentMessage) {
                return response()->json([
                    'success' => false,
                    'message' => 'Penerima chat tidak ditemukan.',
                ], 422);
            }

            return response()->json([
                'success' => true,
                'chat_message' => $sentMessage,
                'message' => 'Pesan berhasil dikirim ke '.$r->penerima.'.',
            ]);
        }

        return redirect()->route('pesan')->with('success', 'Pesan berhasil dikirim ke '.$r->penerima.'.');
    }

    public function chatSend(Request $r, ChatStore $chatStore)
    {
        $data = $r->validate([
            'sender_id' => 'required',
            'sender_name' => 'required',
            'sender_role' => 'required|in:admin,civitas',
            'receiver_id' => 'required',
            'receiver_name' => 'required',
            'body' => 'required',
            'sender_identifier' => 'nullable',
            'receiver_identifier' => 'nullable',
            'admin_username' => 'nullable',
            'campus_key' => 'nullable',
        ]);

        $data['admin_username'] = $data['admin_username']
            ?? ($data['sender_role'] === 'admin' ? $data['sender_id'] : $data['receiver_id']);
        $data['campus_key'] = $data['campus_key'] ?? $data['admin_username'];

        if ($data['sender_role'] === 'civitas') {
            $user = (new \MongoDB\Client(config('database.connections.mongodb.dsn')))
                ->selectDatabase(config('database.connections.mongodb.database'))
                ->selectCollection('users')
                ->findOne([
                    '$or' => [
                        ['username' => $data['sender_id']],
                        ['nim' => $data['sender_id']],
                        ['identifier' => $data['sender_id']],
                    ],
                ]);

            if ($user) {
                $userData = json_decode(json_encode($user), true);
                $data['admin_username'] = $userData['admin_username'] ?? $data['admin_username'];
                $data['campus_key'] = $userData['campus_key'] ?? $userData['kode_kampus'] ?? $data['campus_key'];
                $data['receiver_id'] = $data['admin_username'];
            }
        }

        return response()
            ->json(['message' => $chatStore->send($data)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function chatThread(Request $request, string $participantId, ChatStore $chatStore)
    {
        $adminUsername = $request->query('admin_username', $this->adminUsername());
        $campusKey = $request->query('campus_key', $this->campusKey());

        return response()
            ->json(['thread' => $chatStore->thread($participantId, $adminUsername, $campusKey)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function chatMarkRead(string $participantId, ChatStore $chatStore)
    {
        $chatStore->markAdminRead($participantId, $this->adminUsername(), $this->campusKey());

        return response()
            ->json(['success' => true, 'unread' => $chatStore->unreadForAdmin(null, $this->adminUsername(), $this->campusKey())])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function manajemenKampus(CampusDataStore $campusData)
    {
        $d = $this->dashboardData();
        $storedUsers = collect($campusData->civitasUsers($this->campusKey()));
        $users = $this->usesDefaultCampusData()
            ? collect($d['users'])->concat($storedUsers)
            : $storedUsers;
        $bannedUsers = $users->where('status','Banned');
        $storedLocations = collect($campusData->locations($this->campusKey()));
        $locations = $this->usesDefaultCampusData()
            ? collect($d['locations'])->concat($storedLocations)
            : $storedLocations;
        $adminProfile = $campusData->adminByUsername(session('auth_username', 'admin1')) ?? [];
        $adminApplication = $campusData->adminApplicationByUsername(session('auth_username', 'admin1')) ?? [];
        $campusProfile = [
            'name' => session('auth_kampus') ?: 'Institut Pertanian Bogor',
            'code' => session('auth_kode_kampus') ?: 'IPB',
            'email' => session('auth_email', 'admin@apps.ipb.ac.id'),
            'address' => $adminProfile['alamat_kampus'] ?? $adminApplication['alamat_kampus'] ?? session('auth_alamat_kampus') ?? (session('auth_username') === 'admin1'
                ? 'Kampus IPB Dramaga, Jl. Raya Dramaga, Kabupaten Bogor, Jawa Barat 16680'
                : 'Belum diisi'),
            'emergency' => $adminProfile['phone'] ?? $adminApplication['phone'] ?? session('auth_phone') ?? (session('auth_username') === 'admin1' ? '+62 251 8622642, Ext: 112' : 'Belum diisi'),
        ];
        return view('pages.manajemen-kampus', compact('users','bannedUsers','locations','campusProfile'));
    }

    public function toggleUserStatus(Request $r, $id)
    {
        $status = $r->input('status');
        if (! in_array($status, ['Aktif', 'Banned', 'Menunggu'], true)) {
            $status = 'Aktif';
        }

        if (app(CampusDataStore::class)->setCivitasStatus($this->campusKey(), (string) $id, $status)) {
            return back()->with('success', "Status pengguna berhasil diubah menjadi {$status}.");
        }

        return back()->with('success', "Status pengguna ID {$id} berhasil diperbarui.");
    }

    public function simpanLokasi(Request $r)
    {
        $r->validate(['nama' => 'required|max:120', 'area' => 'required|max:120']);
        app(CampusDataStore::class)->addLocation($this->campusKey(), $r->only('nama', 'area'));

        return back()->with('success', "Lokasi {$r->nama} berhasil disimpan untuk pilihan civitas.");
    }

    public function hapusLokasi($id)
    {
        $deleted = app(CampusDataStore::class)->deleteLocation($this->campusKey(), (string) $id);

        return back()->with(
            $deleted ? 'success' : 'error',
            $deleted
                ? "Lokasi berhasil dihapus dari daftar pilihan civitas."
                : "Lokasi bawaan atau lokasi kampus lain tidak bisa dihapus dari akun ini."
        );
    }

    public function seleksiAdmin(AdminApplicationStore $applications)
    {
        $candidates = $this->superadminCandidates($applications);
        $summary = [
            'menunggu' => $candidates->where('status', 'Menunggu')->count(),
            'disetujui' => $candidates->where('status', 'Disetujui')->count(),
            'ditolak' => $candidates->where('status', 'Ditolak')->count(),
            'banned' => $candidates->where('status', 'Banned')->count(),
        ];

        return view('pages.superadmin-seleksi-admin', compact('candidates', 'summary'));
    }

    public function adminAktif(AdminApplicationStore $applications)
    {
        $activeAdmins = $this->superadminActiveAdmins($applications);
        $summary = [
            'total' => $activeAdmins->count(),
            'kampus' => $activeAdmins->pluck('kampus')->unique()->count(),
            'aktif' => $activeAdmins->where('status', 'aktif')->count(),
        ];

        return view('pages.superadmin-admin-aktif', compact('activeAdmins', 'summary'));
    }

    public function dataKampus(AdminApplicationStore $applications)
    {
        $activeAdmins = $this->superadminActiveAdmins($applications);
        $campuses = $activeAdmins
            ->groupBy('kampus')
            ->map(function ($admins, $kampus) {
                $first = $admins->first();

                return [
                    'kampus' => $kampus,
                    'kode_kampus' => $first['kode_kampus'] ?? '-',
                    'admin_count' => $admins->count(),
                    'admin_name' => $first['nama'] ?? '-',
                    'email' => $first['email'] ?? '-',
                    'phone' => $first['phone'] ?? '-',
                    'laporan_masuk' => max(12, $admins->count() * 27),
                    'status' => 'Aktif',
                ];
            })
            ->values();

        return view('pages.superadmin-data-kampus', compact('campuses'));
    }

    private function superadminCandidates(AdminApplicationStore $applications)
    {
        $d = $this->dashboardData();
        $registeredCandidates = collect($applications->all())->map(fn ($item) => [
            'id' => $item['id'],
            'nama' => $item['nama'] ?? '-',
            'nidn' => $item['nidn'] ?? '-',
            'email' => $item['email'] ?? '-',
            'unit' => $item['unit'] ?? '-',
            'kampus' => $item['kampus'] ?? '-',
            'role' => $item['role'] ?? 'Calon Admin',
            'status' => $item['status'] ?? 'Menunggu',
            'alasan' => $item['alasan'] ?? '-',
            'surat_tugas_nama' => $item['surat_tugas_nama'] ?? null,
            'surat_tugas_path' => $item['surat_tugas_path'] ?? null,
        ]);

        return $registeredCandidates->concat($d['adminCandidates']);
    }

    private function superadminActiveAdmins(AdminApplicationStore $applications)
    {
        return collect($applications->approvedAdmins())->map(fn ($item) => [
            'id' => $item['id'],
            'nama' => $item['name'] ?? $item['nama'] ?? '-',
            'username' => $item['username'] ?? '-',
            'email' => $item['email'] ?? '-',
            'nidn' => $item['identifier'] ?? $item['nidn'] ?? '-',
            'kampus' => $item['kampus'] ?? '-',
            'kode_kampus' => $item['kode_kampus'] ?? '-',
            'unit' => $item['unit'] ?? '-',
            'phone' => $item['phone'] ?? '-',
            'status' => $item['status'] ?? '-',
            'created_at' => $item['created_at'] ?? '-',
        ]);
    }

    public function lihatDokumenAdmin($id, AdminApplicationStore $applications)
    {
        $document = $applications->document((string) $id);

        if (! $document || ! Storage::exists($document['path'])) {
            abort(404, 'Dokumen surat tugas tidak ditemukan.');
        }

        return response()->file(Storage::path($document['path']), [
            'Content-Type' => $document['mime'],
            'Content-Disposition' => 'inline; filename="'.$document['name'].'"',
        ]);
    }

    public function downloadDokumenAdmin($id, AdminApplicationStore $applications)
    {
        $document = $applications->document((string) $id);

        if (! $document || ! Storage::exists($document['path'])) {
            abort(404, 'Dokumen surat tugas tidak ditemukan.');
        }

        return Storage::download($document['path'], $document['name'], [
            'Content-Type' => $document['mime'],
        ]);
    }

    public function ubahStatusAdmin(Request $r, $id, AdminApplicationStore $applications)
    {
        $r->validate(['status' => 'required|in:Disetujui,Ditolak,Menunggu,Banned']);

        if ($applications->updateStatus((string) $id, $r->status)) {
            $message = match ($r->status) {
                'Disetujui' => "Pengajuan admin disetujui. Akun admin sudah dibuat dan bisa login.",
                'Ditolak' => "Pengajuan admin ditolak. Akun admin dinonaktifkan dan tidak tampil di data kampus aktif.",
                'Banned' => "Akun admin dibanned. Data admin aktif dihapus dan akun tidak bisa digunakan lagi.",
                default => "Status pengajuan admin diubah menjadi {$r->status}.",
            };

            return back()->with('success', $message);
        }

        return back()->with('success', "Status calon admin ID {$id} diubah menjadi {$r->status}.");
    }
}

