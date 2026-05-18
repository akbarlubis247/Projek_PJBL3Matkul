<?php
namespace App\Http\Controllers;

use App\Exports\ReportsExport;
use App\Services\ChatStore;
use App\Services\AdminApplicationStore;
use App\Services\CampusDataStore;
use App\Services\CampusReportStore;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;
use Maatwebsite\Excel\Facades\Excel;

class DashboardController extends Controller
{
    private function dummyData(): array
    {
        $data = [
            'barangHilang' => [
                ['id'=>1,'namaBarang'=>'Laptop Asus ROG','pelapor'=>'Budi Santoso','lokasi'=>'Perpustakaan LSI','tanggal'=>'2024-10-01','status'=>'Aktif','deskripsi'=>'Laptop warna hitam, ada stiker HIMA.'],
                ['id'=>2,'namaBarang'=>'Dompet Kulit Coklat','pelapor'=>'Siti Aminah','lokasi'=>'Gedung Rektorat','tanggal'=>'2024-10-02','status'=>'Ditemukan','deskripsi'=>'Berisi KTP, KTM, dan uang tunai.'],
                ['id'=>3,'namaBarang'=>'Kunci Motor Honda','pelapor'=>'Agus Pranoto','lokasi'=>'Fakultas Pertanian','tanggal'=>'2024-10-05','status'=>'Aktif','deskripsi'=>'Gantungan kunci beruang.'],
                ['id'=>4,'namaBarang'=>'Botol Minum Tupperware','pelapor'=>'Rina Wijaya','lokasi'=>'Lab Biologi','tanggal'=>'2024-10-06','status'=>'Ditutup','deskripsi'=>'Warna biru muda, 1 liter.'],
                ['id'=>5,'namaBarang'=>'Flashdisk Sandisk 32GB','pelapor'=>'Hendra Gunawan','lokasi'=>'Asrama Putri','tanggal'=>'2024-10-08','status'=>'Aktif','deskripsi'=>'Isi data skripsi penting.'],
                ['id'=>6,'namaBarang'=>'Kacamata Minus','pelapor'=>'Dewi Lestari','lokasi'=>'Masjid Al-Hurriyyah','tanggal'=>'2024-10-10','status'=>'Ditemukan','deskripsi'=>'Frame hitam kotak.'],
                ['id'=>7,'namaBarang'=>'Jaket IPB','pelapor'=>'Fajar Ramadhan','lokasi'=>'Kantor Dekan','tanggal'=>'2024-10-12','status'=>'Aktif','deskripsi'=>'Warna biru dongker ukuran L.'],
                ['id'=>8,'namaBarang'=>'Buku Catatan','pelapor'=>'Andi Saputra','lokasi'=>'Gedung Kuliah Bersama','tanggal'=>'2024-10-15','status'=>'Aktif','deskripsi'=>'Sampul spiral warna hijau.'],
            ],
            'barangDitemukan' => [
                ['id'=>1,'namaBarang'=>'Jam Tangan','pelapor'=>'Satpam Budi','lokasi'=>'Masjid Al-Hurriyyah','tanggal'=>'2024-10-02','status'=>'Aktif','deskripsi'=>'Merk Casio tali kulit.'],
                ['id'=>2,'namaBarang'=>'Payung Lipat','pelapor'=>'Siti Rahma','lokasi'=>'Perpustakaan LSI','tanggal'=>'2024-10-04','status'=>'Ditutup','deskripsi'=>'Warna merah marun.'],
                ['id'=>3,'namaBarang'=>'KTM IPB','pelapor'=>'Dodi Setiawan','lokasi'=>'Gedung Rektorat','tanggal'=>'2024-10-07','status'=>'Aktif','deskripsi'=>'Atas nama Rizky Aditya.'],
                ['id'=>4,'namaBarang'=>'Earphone TWS','pelapor'=>'Rini Melati','lokasi'=>'Fakultas Kehutanan','tanggal'=>'2024-10-09','status'=>'Aktif','deskripsi'=>'Warna putih merk Baseus.'],
                ['id'=>5,'namaBarang'=>'Charger Laptop','pelapor'=>'Toni Kusuma','lokasi'=>'Lab Komputer','tanggal'=>'2024-10-11','status'=>'Aktif','deskripsi'=>'Adaptor Lenovo.'],
                ['id'=>6,'namaBarang'=>'Helm SNI','pelapor'=>'Pak Yanto','lokasi'=>'Parkiran Motor Fapet','tanggal'=>'2024-10-13','status'=>'Aktif','deskripsi'=>'Warna hitam doff.'],
                ['id'=>7,'namaBarang'=>'Map Plastik','pelapor'=>'Nina Safitri','lokasi'=>'Kantor Tata Usaha','tanggal'=>'2024-10-14','status'=>'Aktif','deskripsi'=>'Berisi berkas legalisir.'],
                ['id'=>8,'namaBarang'=>'Tas Tote','pelapor'=>'Bambang Mulyono','lokasi'=>'Kantin Cyber','tanggal'=>'2024-10-16','status'=>'Aktif','deskripsi'=>'Motif kucing.'],
            ],
            'fasilitasRusak' => [
                ['id'=>1,'namaFasilitas'=>'AC Ruang Kuliah','pelapor'=>'Dosen A','lokasi'=>'Gedung Kuliah A1','tanggal'=>'2024-10-01','status'=>'Dilaporkan','deskripsi'=>'AC bocor dan meneteskan air.'],
                ['id'=>2,'namaFasilitas'=>'Kran Air Toilet','pelapor'=>'Mahasiswa B','lokasi'=>'Toilet Lt.2 LSI','tanggal'=>'2024-10-03','status'=>'Sedang Diperbaiki','deskripsi'=>'Kran patah air mengalir terus.'],
                ['id'=>3,'namaFasilitas'=>'Proyektor LCD','pelapor'=>'Staff C','lokasi'=>'Ruang Rapat Rektorat','tanggal'=>'2024-10-05','status'=>'Dilaporkan','deskripsi'=>'Lampu proyektor mati.'],
                ['id'=>4,'namaFasilitas'=>'Kursi Kuliah','pelapor'=>'Mahasiswa D','lokasi'=>'Fakultas Pertanian RK2','tanggal'=>'2024-10-08','status'=>'Dilaporkan','deskripsi'=>'Sandaran kursi patah.'],
                ['id'=>5,'namaFasilitas'=>'Lampu Jalan','pelapor'=>'Satpam E','lokasi'=>'Jalan Asrama Putra','tanggal'=>'2024-10-10','status'=>'Sedang Diperbaiki','deskripsi'=>'Lampu redup dan berkedip.'],
                ['id'=>6,'namaFasilitas'=>'Pintu Kaca','pelapor'=>'Dosen F','lokasi'=>'Lobi Lab Biologi','tanggal'=>'2024-10-12','status'=>'Dilaporkan','deskripsi'=>'Engsel pintu macet.'],
                ['id'=>7,'namaFasilitas'=>'WIFI Router','pelapor'=>'Mahasiswa G','lokasi'=>'Kantin Rektorat','tanggal'=>'2024-10-14','status'=>'Dilaporkan','deskripsi'=>'Sinyal hilang timbul.'],
                ['id'=>8,'namaFasilitas'=>'Papan Tulis','pelapor'=>'Staff H','lokasi'=>'Fakultas Peternakan','tanggal'=>'2024-10-15','status'=>'Dilaporkan','deskripsi'=>'Permukaan rusak.'],
            ],
            'fasilitasDiperbaiki' => [
                ['id'=>1,'namaFasilitas'=>'Wastafel','pelapor'=>'Mahasiswa I','lokasi'=>'Toilet FMIPA','tanggal'=>'2024-09-28','status'=>'Sudah Diperbaiki','deskripsi'=>'Saluran mampet.'],
                ['id'=>2,'namaFasilitas'=>'Stop Kontak','pelapor'=>'Dosen J','lokasi'=>'Lab Fisika','tanggal'=>'2024-09-30','status'=>'Sudah Diperbaiki','deskripsi'=>'Konslet.'],
                ['id'=>3,'namaFasilitas'=>'AC Perpus','pelapor'=>'Staff K','lokasi'=>'LSI Lt.1','tanggal'=>'2024-10-02','status'=>'Sudah Diperbaiki','deskripsi'=>'Kurang dingin.'],
                ['id'=>4,'namaFasilitas'=>'Atap Bocor','pelapor'=>'Mahasiswa L','lokasi'=>'Gedung CCR','tanggal'=>'2024-10-04','status'=>'Sudah Diperbaiki','deskripsi'=>'Air masuk saat hujan deras.'],
                ['id'=>5,'namaFasilitas'=>'Kipas Angin','pelapor'=>'Satpam M','lokasi'=>'Pos Jaga Gerbang','tanggal'=>'2024-10-06','status'=>'Sudah Diperbaiki','deskripsi'=>'Kipas tidak berputar.'],
                ['id'=>6,'namaFasilitas'=>'Meja Dosen','pelapor'=>'Dosen N','lokasi'=>'Ruang Sidang','tanggal'=>'2024-10-07','status'=>'Sudah Diperbaiki','deskripsi'=>'Kaki meja goyang.'],
                ['id'=>7,'namaFasilitas'=>'Keran Wudhu','pelapor'=>'Mahasiswa O','lokasi'=>'Masjid Al-Hurriyyah','tanggal'=>'2024-10-09','status'=>'Sudah Diperbaiki','deskripsi'=>'Air keluarnya kecil.'],
                ['id'=>8,'namaFasilitas'=>'Printer','pelapor'=>'Staff P','lokasi'=>'Kantor Tata Usaha','tanggal'=>'2024-10-11','status'=>'Sudah Diperbaiki','deskripsi'=>'Tinta macet.'],
            ],
            'users' => [
                ['id'=>1,'nama'=>'Budi Santoso','nim'=>'G64190001','email'=>'budi.s@apps.ipb.ac.id','role'=>'Mahasiswa','status'=>'Aktif'],
                ['id'=>2,'nama'=>'Dr. Siti Aminah, M.Si','nim'=>'197501012000032001','email'=>'siti.a@apps.ipb.ac.id','role'=>'Dosen','status'=>'Aktif'],
                ['id'=>3,'nama'=>'Agus Pranoto','nim'=>'198002022005011002','email'=>'agus.p@apps.ipb.ac.id','role'=>'Staff','status'=>'Aktif'],
                ['id'=>4,'nama'=>'Rina Wijaya','nim'=>'H14190045','email'=>'rina.w@apps.ipb.ac.id','role'=>'Mahasiswa','status'=>'Banned'],
                ['id'=>5,'nama'=>'Prof. Hendra Gunawan','nim'=>'196805051995021001','email'=>'hendra.g@apps.ipb.ac.id','role'=>'Dosen','status'=>'Aktif'],
                ['id'=>6,'nama'=>'Dewi Lestari','nim'=>'199008082015032001','email'=>'dewi.l@apps.ipb.ac.id','role'=>'Staff','status'=>'Aktif'],
                ['id'=>7,'nama'=>'Fajar Ramadhan','nim'=>'F34180021','email'=>'fajar.r@apps.ipb.ac.id','role'=>'Mahasiswa','status'=>'Aktif'],
                ['id'=>8,'nama'=>'Andi Saputra','nim'=>'198511112010121003','email'=>'andi.s@apps.ipb.ac.id','role'=>'Staff','status'=>'Banned'],
                ['id'=>9,'nama'=>'Dr. Nina Safitri','nim'=>'197804042002122001','email'=>'nina.s@apps.ipb.ac.id','role'=>'Dosen','status'=>'Aktif'],
                ['id'=>10,'nama'=>'Bambang Mulyono','nim'=>'A14170099','email'=>'bambang.m@apps.ipb.ac.id','role'=>'Mahasiswa','status'=>'Aktif'],
                ['id'=>11,'nama'=>'Dodi Setiawan','nim'=>'198207072008011002','email'=>'dodi.s@apps.ipb.ac.id','role'=>'Staff','status'=>'Aktif'],
                ['id'=>12,'nama'=>'Rini Melati','nim'=>'G64190088','email'=>'rini.m@apps.ipb.ac.id','role'=>'Mahasiswa','status'=>'Aktif'],
                ['id'=>13,'nama'=>'Civitas Mobile 1','nim'=>'CV-0001','email'=>'civitas1@kampus-lapor.test','role'=>'Mahasiswa','status'=>'Aktif'],
            ],
            'locations' => [
                ['id'=>1,'nama'=>'Perpustakaan LSI','area'=>'Akademik','status'=>'Aktif'],
                ['id'=>2,'nama'=>'Gedung Rektorat','area'=>'Administrasi','status'=>'Aktif'],
                ['id'=>3,'nama'=>'Kantin Rektorat','area'=>'Fasilitas Umum','status'=>'Aktif'],
                ['id'=>4,'nama'=>'Gedung Kuliah A1','area'=>'Akademik','status'=>'Aktif'],
                ['id'=>5,'nama'=>'Masjid Kampus','area'=>'Fasilitas Umum','status'=>'Aktif'],
                ['id'=>6,'nama'=>'Parkiran Fakultas','area'=>'Transportasi','status'=>'Aktif'],
            ],
            'adminCandidates' => [
                ['id'=>1,'nama'=>'Alya Prameswari','nidn'=>'199105122019032014','email'=>'alya.p@apps.ipb.ac.id','unit'=>'Fakultas Teknik','kampus'=>'Institut Pertanian Bogor','role'=>'Calon Admin','status'=>'Menunggu','alasan'=>'Mengelola laporan fasilitas dan kehilangan di area fakultas.'],
                ['id'=>2,'nama'=>'Bagas Wicaksono','nidn'=>'198901202014041003','email'=>'bagas.w@apps.ipb.ac.id','unit'=>'Direktorat Sarpras','kampus'=>'Institut Pertanian Bogor','role'=>'Calon Admin','status'=>'Disetujui','alasan'=>'Butuh akses tindak lanjut fasilitas rusak lintas gedung.'],
                ['id'=>3,'nama'=>'Citra Lestari','nidn'=>'199211082018032002','email'=>'citra.l@apps.ipb.ac.id','unit'=>'Keamanan Kampus','kampus'=>'Institut Pertanian Bogor','role'=>'Calon Admin','status'=>'Menunggu','alasan'=>'Membantu validasi barang ditemukan dan laporan darurat.'],
                ['id'=>4,'nama'=>'Dimas Rahardian','nidn'=>'198702142012011001','email'=>'dimas.r@apps.ipb.ac.id','unit'=>'Kemahasiswaan','kampus'=>'Institut Pertanian Bogor','role'=>'Calon Admin','status'=>'Ditolak','alasan'=>'Data unit belum lengkap.'],
            ],
            'messages' => [
                ['id'=>1,'penerima'=>'Budi Santoso','judul'=>'Laptop hilang','isi'=>'Halo admin, saya ingin tanya perkembangan laporan laptop saya.','tanggal'=>'2026-05-13','status'=>'Masuk'],
                ['id'=>2,'penerima'=>'Dr. Siti Aminah, M.Si','judul'=>'Fasilitas AC','isi'=>'AC ruang A1 masih bocor, apakah sudah dijadwalkan teknisi?','tanggal'=>'2026-05-13','status'=>'Masuk'],
                ['id'=>3,'penerima'=>'Rina Wijaya','judul'=>'Akun laporan','isi'=>'Saya tidak bisa mengubah detail laporan barang hilang.','tanggal'=>'2026-05-12','status'=>'Masuk'],
                ['id'=>4,'penerima'=>'Agus Pranoto','judul'=>'Barang ditemukan','isi'=>'Saya menemukan kunci motor di parkiran fakultas.','tanggal'=>'2026-05-12','status'=>'Masuk'],
                ['id'=>5,'penerima'=>'Andi Saputra','judul'=>'Tanya laporan','isi'=>'Status laporan saya sudah selesai atau masih diproses?','tanggal'=>'2026-05-11','status'=>'Masuk'],
            ],
            'chartData' => [
                ['month'=>'Jan','barangHilang'=>12,'fasilitasRusak'=>5],
                ['month'=>'Feb','barangHilang'=>15,'fasilitasRusak'=>7],
                ['month'=>'Mar','barangHilang'=>9,'fasilitasRusak'=>10],
                ['month'=>'Apr','barangHilang'=>18,'fasilitasRusak'=>4],
                ['month'=>'May','barangHilang'=>10,'fasilitasRusak'=>8],
                ['month'=>'Jun','barangHilang'=>14,'fasilitasRusak'=>6],
            ],
        ];

        if ($this->usesDefaultCampusData()) {
            return $data;
        }

        return $this->emptyCampusData($data);
    }

    private function usesDefaultCampusData(): bool
    {
        return session('auth_role') !== 'admin' || session('auth_username') === 'admin1';
    }

    private function emptyCampusData(array $data): array
    {
        foreach (['barangHilang', 'barangDitemukan', 'fasilitasRusak', 'fasilitasDiperbaiki', 'users', 'locations', 'messages'] as $key) {
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

    public function index()
    {
        $data = $this->dummyData();
        $stats = [
            'barangHilang'      => count($data['barangHilang']),
            'barangDitemukan'   => count($data['barangDitemukan']),
            'fasilitasRusak'    => count($data['fasilitasRusak']),
            'fasilitasDiperbaiki' => count($data['fasilitasDiperbaiki']),
        ];
        $laporanTerbaru = array_merge(
            array_map(fn($i)=>['kategori'=>'Barang Hilang','nama'=>$i['namaBarang'],'status'=>$i['status'],'tanggal'=>$i['tanggal']], array_slice($data['barangHilang'],0,3)),
            array_map(fn($i)=>['kategori'=>'Fasilitas Rusak','nama'=>$i['namaFasilitas'],'status'=>$i['status'],'tanggal'=>$i['tanggal']], array_slice($data['fasilitasRusak'],0,2))
        );
        usort($laporanTerbaru, fn($a,$b)=>strcmp($b['tanggal'],$a['tanggal']));
        return view('pages.dashboard', compact('stats','laporanTerbaru'))->with('chartData', $data['chartData']);
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
        $d = $this->dummyData();
        $campusReports = collect($this->campusReports($reports));
        $barangHilang = collect($d['barangHilang'])
            ->concat($campusReports
                ->where('kategori', 'Barang Hilang')
                ->reject(fn ($item) => in_array($item['status'], ['Ditemukan', 'Menunggu Diambil', 'Selesai'], true))
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

        return back()->with('success', "Barang hilang ID {$id} ditandai ditemukan. Notifikasi dikirim ke civitas pelapor.");
    }

    public function hapusBarangDitemukan($id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Aktif')) {
            return back()->with('success', "Laporan barang dikembalikan ke daftar barang hilang.");
        }

        return back()->with('success', "Laporan barang ditemukan ID {$id} berhasil dihapus dari daftar.");
    }

    public function tandaiBarangDiambil($id, CampusReportStore $reports)
    {
        if ($reports->updateStatus($this->campusKey(), (string) $id, 'Sudah Diambil')) {
            return back()->with('success', "Barang ditandai sudah diambil oleh pelapor.");
        }

        return back()->with('success', "Status barang ID {$id} diperbarui menjadi sudah diambil.");
    }

    public function fasilitasRusak(CampusReportStore $reports)
    {
        $d = $this->dummyData();
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
        $d = $this->dummyData();
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
        $d = $this->dummyData();
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
        $d = $this->dummyData();
        $storedUsers = collect($campusData->civitasUsers($this->campusKey()));
        $users = $this->usesDefaultCampusData()
            ? collect($d['users'])->concat($storedUsers)
            : $storedUsers;
        $allowedParticipants = $users->pluck('nim')->all();
        $threads = $this->usesDefaultCampusData()
            ? $chatStore->threads()
            : $chatStore->threads($allowedParticipants);

        return view('pages.pesan', ['users'=>$users,'messages'=>$d['messages'], 'threads' => $threads]);
    }

    public function kirimPesan(Request $r, ChatStore $chatStore, CampusDataStore $campusData)
    {
        $r->validate(['penerima'=>'required','isi'=>'required']);
        $d = $this->dummyData();
        $storedUsers = collect($campusData->civitasUsers($this->campusKey()));
        $users = $this->usesDefaultCampusData()
            ? collect($d['users'])->concat($storedUsers)
            : $storedUsers;
        $user = $users->firstWhere('nama', $r->penerima);

        if ($user) {
            $chatStore->send([
                'sender_id' => session('auth_username', 'admin1'),
                'sender_name' => session('auth_name', 'Admin Kampus'),
                'sender_role' => 'admin',
                'receiver_id' => $user['nim'],
                'receiver_identifier' => $user['nim'],
                'receiver_name' => $user['nama'],
                'body' => $r->isi,
            ]);
        }

        if ($r->expectsJson()) {
            return response()->json([
                'success' => true,
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
        ]);

        return response()
            ->json(['message' => $chatStore->send($data)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function chatThread(string $participantId, ChatStore $chatStore)
    {
        return response()
            ->json(['thread' => $chatStore->thread($participantId)])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function chatMarkRead(string $participantId, ChatStore $chatStore)
    {
        $chatStore->markAdminRead($participantId);

        return response()
            ->json(['success' => true, 'unread' => $chatStore->unreadForAdmin()])
            ->header('Access-Control-Allow-Origin', '*');
    }

    public function manajemenKampus(CampusDataStore $campusData)
    {
        $d = $this->dummyData();
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
        $d = $this->dummyData();
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
        ]);
        $candidates = $registeredCandidates->concat($d['adminCandidates']);
        $summary = [
            'menunggu' => $candidates->where('status', 'Menunggu')->count(),
            'disetujui' => $candidates->where('status', 'Disetujui')->count(),
            'ditolak' => $candidates->where('status', 'Ditolak')->count(),
        ];
        $activeAdmins = collect($applications->approvedAdmins())->map(fn ($item) => [
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

        return view('pages.superadmin-seleksi-admin', compact('candidates', 'summary', 'activeAdmins'));
    }

    public function ubahStatusAdmin(Request $r, $id, AdminApplicationStore $applications)
    {
        $r->validate(['status' => 'required|in:Disetujui,Ditolak,Menunggu']);

        if ($applications->updateStatus((string) $id, $r->status)) {
            $message = $r->status === 'Disetujui'
                ? "Pengajuan admin disetujui. Akun admin sudah dibuat dan bisa login."
                : "Status pengajuan admin diubah menjadi {$r->status}.";

            return back()->with('success', $message);
        }

        return back()->with('success', "Status calon admin ID {$id} diubah menjadi {$r->status}.");
    }
}
