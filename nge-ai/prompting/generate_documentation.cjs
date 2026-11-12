const docx = require('docx');
const fs = require('fs');
const path = require('path');

const {
  Document,
  Packer,
  Paragraph,
  TextRun,
  Table,
  TableRow,
  TableCell,
  ImageRun,
  Header,
  Footer,
  AlignmentType,
  BorderStyle,
  WidthType,
  ShadingType,
  PageNumber,
  HeadingLevel,
  ExternalHyperlink,
} = docx;

console.log('Building comprehensive documentation for Campus Lapor...');

// Paths
const ASSETS_DIR = path.resolve(__dirname, 'doc_assets');
const LOGO_PATH = path.resolve(__dirname, 'logo_kampus_lapor.png');
const OUTPUT_DOCX = path.resolve(__dirname, 'DOKUMENTASI_SISTEM_CAMPUS_LAPOR_KELOMPOK_E.docx');

// Theme Colors
const COLOR_PRIMARY = '4F46E5';     // Indigo
const COLOR_SECONDARY = '7C3AED';   // Purple
const COLOR_TEXT_DARK = '0F172A';   // Slate 900
const COLOR_TEXT_MUTED = '475569';  // Slate 600
const COLOR_BG_LIGHT = 'F8FAFC';    // Slate 50
const COLOR_BG_HEADER = '312E81';   // Indigo 900
const COLOR_BORDER = 'CBD5E1';      // Slate 300
const COLOR_CALLOUT_BG = 'EEF2FF';  // Indigo 50
const COLOR_CALLOUT_BORDER = '6366F1'; // Indigo 500

// Helper: Paragraph with default styling
function p(text, options = {}) {
  const children = [];
  if (typeof text === 'string') {
    children.push(new TextRun({
      text,
      font: options.font || 'Calibri',
      size: options.size || 22, // 11pt
      bold: options.bold || false,
      italics: options.italics || false,
      color: options.color || COLOR_TEXT_DARK,
    }));
  } else if (Array.isArray(text)) {
    for (const item of text) {
      if (typeof item === 'string') {
        children.push(new TextRun({
          text: item,
          font: options.font || 'Calibri',
          size: options.size || 22,
          color: options.color || COLOR_TEXT_DARK,
        }));
      } else {
        children.push(new TextRun({
          font: 'Calibri',
          size: 22,
          color: COLOR_TEXT_DARK,
          ...item,
        }));
      }
    }
  }

  return new Paragraph({
    alignment: options.alignment || AlignmentType.LEFT,
    spacing: {
      before: options.spaceBefore !== undefined ? options.spaceBefore : 80,
      after: options.spaceAfter !== undefined ? options.spaceAfter : 140,
      line: options.lineSpacing || 276, // 1.15x
    },
    children,
  });
}

// Helper: Bullet point
function bullet(boldPrefix, text) {
  return new Paragraph({
    bullet: { level: 0 },
    spacing: { before: 40, after: 60, line: 260 },
    children: [
      new TextRun({
        text: boldPrefix + ' ',
        font: 'Calibri',
        size: 22,
        bold: true,
        color: COLOR_TEXT_DARK,
      }),
      new TextRun({
        text: text,
        font: 'Calibri',
        size: 22,
        color: COLOR_TEXT_DARK,
      }),
    ],
  });
}

// Helper: Headings
function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 360, after: 160 },
    children: [
      new TextRun({
        text,
        font: 'Calibri',
        size: 32, // 16pt
        bold: true,
        color: COLOR_BG_HEADER,
      }),
    ],
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 260, after: 120 },
    children: [
      new TextRun({
        text,
        font: 'Calibri',
        size: 26, // 13pt
        bold: true,
        color: COLOR_PRIMARY,
      }),
    ],
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 180, after: 80 },
    children: [
      new TextRun({
        text,
        font: 'Calibri',
        size: 23, // 11.5pt
        bold: true,
        color: COLOR_SECONDARY,
      }),
    ],
  });
}

// Helper: Page Break
function pageBreak() {
  return new Paragraph({
    children: [new TextRun({ text: '', break: 1 })],
    pageBreakBefore: true,
  });
}

// Helper: Callout Box
function calloutBox(title, bodyLines, borderColor = COLOR_CALLOUT_BORDER, bgColor = COLOR_CALLOUT_BG) {
  const content = [
    new Paragraph({
      spacing: { before: 40, after: 60 },
      children: [
        new TextRun({
          text: title,
          font: 'Calibri',
          size: 22,
          bold: true,
          color: COLOR_PRIMARY,
        }),
      ],
    }),
  ];

  for (const line of bodyLines) {
    content.push(new Paragraph({
      spacing: { before: 20, after: 40, line: 260 },
      children: [
        new TextRun({
          text: line,
          font: 'Calibri',
          size: 20,
          color: COLOR_TEXT_DARK,
        }),
      ],
    }));
  }

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          new TableCell({
            margins: { top: 140, bottom: 140, left: 200, right: 180 },
            shading: { fill: bgColor, type: ShadingType.CLEAR, color: 'auto' },
            borders: {
              left: { style: BorderStyle.SINGLE, size: 24, color: borderColor },
              top: { style: BorderStyle.NONE },
              right: { style: BorderStyle.NONE },
              bottom: { style: BorderStyle.NONE },
            },
            children: content,
          }),
        ],
      }),
    ],
  });
}

// Helper: Image with caption
function imageBox(imagePath, caption, width, height) {
  if (!fs.existsSync(imagePath)) {
    return p(`[Image not found: ${path.basename(imagePath)}]`, { italics: true, color: 'DC2626' });
  }

  const imgBuffer = fs.readFileSync(imagePath);
  return [
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 180, after: 80 },
      children: [
        new ImageRun({
          data: imgBuffer,
          transformation: { width, height },
        }),
      ],
    }),
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 40, after: 180 },
      children: [
        new TextRun({
          text: caption,
          font: 'Calibri',
          size: 19, // 9.5pt
          italics: true,
          color: COLOR_TEXT_MUTED,
        }),
      ],
    }),
  ];
}

// Helper: Professional Table
function createTable(headers, rows, colWidths = []) {
  const tableRows = [];

  // Header Row
  const headerCells = headers.map((h, i) => {
    return new TableCell({
      width: colWidths[i] ? { size: colWidths[i], type: WidthType.PERCENTAGE } : undefined,
      margins: { top: 120, bottom: 120, left: 140, right: 140 },
      shading: { fill: COLOR_BG_HEADER, type: ShadingType.CLEAR, color: 'auto' },
      children: [
        new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({
              text: h,
              font: 'Calibri',
              size: 20, // 10pt
              bold: true,
              color: 'FFFFFF',
            }),
          ],
        }),
      ],
    });
  });
  tableRows.push(new TableRow({ children: headerCells, tableHeader: true }));

  // Data Rows
  rows.forEach((row, rIdx) => {
    const isEven = rIdx % 2 === 1;
    const cells = row.map((cellText, cIdx) => {
      let cellParagraphs = [];
      if (Array.isArray(cellText)) {
        cellParagraphs = cellText.map(t => new Paragraph({
          spacing: { before: 20, after: 20, line: 240 },
          children: [new TextRun({ text: t, font: 'Calibri', size: 19, color: COLOR_TEXT_DARK })],
        }));
      } else {
        cellParagraphs = [
          new Paragraph({
            alignment: cIdx === 0 && colWidths[cIdx] && colWidths[cIdx] < 15 ? AlignmentType.CENTER : AlignmentType.LEFT,
            spacing: { before: 40, after: 40, line: 250 },
            children: [
              new TextRun({
                text: String(cellText),
                font: 'Calibri',
                size: 19,
                color: COLOR_TEXT_DARK,
                bold: cIdx === 0,
              }),
            ],
          }),
        ];
      }

      return new TableCell({
        width: colWidths[cIdx] ? { size: colWidths[cIdx], type: WidthType.PERCENTAGE } : undefined,
        margins: { top: 90, bottom: 90, left: 120, right: 120 },
        shading: isEven ? { fill: COLOR_BG_LIGHT, type: ShadingType.CLEAR, color: 'auto' } : undefined,
        borders: {
          top: { style: BorderStyle.SINGLE, size: 4, color: COLOR_BORDER },
          bottom: { style: BorderStyle.SINGLE, size: 4, color: COLOR_BORDER },
          left: { style: BorderStyle.SINGLE, size: 4, color: COLOR_BORDER },
          right: { style: BorderStyle.SINGLE, size: 4, color: COLOR_BORDER },
        },
        children: cellParagraphs,
      });
    });
    tableRows.push(new TableRow({ children: cells }));
  });

  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: tableRows,
  });
}

// Construct Document Sections
const docElements = [];

// ==========================================
// 1. COVER PAGE
// ==========================================
docElements.push(
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 200, after: 120 },
    children: [
      new TextRun({
        text: 'DOKUMENTASI SISTEM & PANDUAN PENGUJIAN',
        font: 'Calibri',
        size: 30,
        bold: true,
        color: COLOR_BG_HEADER,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 0, after: 280 },
    children: [
      new TextRun({
        text: 'SISTEM INFORMASI PELAPORAN BARANG HILANG & FASILITAS KAMPUS TERPADU\n"CAMPUS LAPOR"',
        font: 'Calibri',
        size: 24,
        bold: true,
        color: COLOR_PRIMARY,
      }),
    ],
  })
);

if (fs.existsSync(LOGO_PATH)) {
  docElements.push(
    new Paragraph({
      alignment: AlignmentType.CENTER,
      spacing: { before: 180, after: 280 },
      children: [
        new ImageRun({
          data: fs.readFileSync(LOGO_PATH),
          transformation: { width: 170, height: 170 },
        }),
      ],
    })
  );
}

docElements.push(
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 120, after: 40 },
    children: [
      new TextRun({
        text: 'Disusun untuk Keperluan Pengujian Sistem (Software Testing)',
        font: 'Calibri',
        size: 21,
        bold: true,
        italics: true,
        color: COLOR_TEXT_MUTED,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 20, after: 320 },
    children: [
      new TextRun({
        text: 'Mata Kuliah: Pengujian Perangkat Lunak / Proyek Terpadu (Awan x Mobile x Web)\nDepartemen Ilmu Komputer - IPB University',
        font: 'Calibri',
        size: 20,
        color: COLOR_TEXT_MUTED,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 200, after: 40 },
    children: [
      new TextRun({
        text: 'TIM PENGEMBANG (KELOMPOK E / KELOMPOK 5):',
        font: 'Calibri',
        size: 20,
        bold: true,
        color: COLOR_PRIMARY,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 40, after: 20 },
    children: [
      new TextRun({
        text: 'Kelompok 5 (Kelompok E) - Kelas Praktikum Awan x Mobile x Web',
        font: 'Calibri',
        size: 20,
        color: COLOR_TEXT_DARK,
      }),
    ],
  }),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 20, after: 20 },
    children: [
      new TextRun({
        text: 'Institut Pertanian Bogor (IPB University) - 2026',
        font: 'Calibri',
        size: 20,
        bold: true,
        color: COLOR_BG_HEADER,
      }),
    ],
  }),
  pageBreak()
);

// ==========================================
// 2. KATA PENGANTAR & RINGKASAN EKSEKUTIF
// ==========================================
docElements.push(
  h1('RINGKASAN EKSEKUTIF UNTUK TIM TESTER'),
  p([
    'Dokumen ini disusun secara khusus oleh ',
    { text: 'Kelompok E (Kelompok 5)', bold: true },
    ' sebagai spesifikasi teknis dan panduan operasional pengujian untuk diserahkan kepada kelompok rekan mahasiswa yang bertugas melakukan pengujian (',
    { text: 'Quality Assurance / Testing Team', italics: true },
    ') dalam mata kuliah Pengujian Perangkat Lunak (Software Testing).'
  ]),
  p('Aplikasi "Campus Lapor" adalah ekosistem aplikasi pelaporan kampus multi-platform (Aplikasi Mobile berbasis Flutter untuk Mahasiswa/Civitas Akademika dan Aplikasi Web berbasis Laravel untuk Admin Fakultas dan Superadmin Universitas). Sistem ini menyediakan solusi terpadu untuk dua problem utama kampus: kehilangan barang dan pelaporan kerusakan fasilitas umum, didukung perpesanan real-time dan notifikasi terpusat.'),
  calloutBox(
    'INFORMASI AKSES LIVE TESTING WEB ADMIN (HOSTED ENVIRONMENT):',
    [
      '• URL Domain Web Admin: https://web-admincampus-lapor-production-3cd2.up.railway.app/login',
      '• Masa Aktif Hosting: 30 Hari Aktif (Expired: 9 Oktober 2026)',
      '• Akun Pengujian Superadmin: Username = superadmin1 | Password = superadmin123',
      '• Akun Pengujian Admin Kampus: Username = admin1 | Password = admin123',
      '• Akun Pengujian Civitas Mobile: Username/NIM = CV-0001 (atau civitas1) | Password = civitas123',
      '• PENTING: Untuk pembaruan link domain jika habis masa sewa, mohon segera hubungi Kelompok E (Kelompok 5).'
    ]
  ),
  p(''),
  pageBreak()
);

// ==========================================
// 3. BAB 1: LATAR BELAKANG & TUJUAN
// ==========================================
docElements.push(
  h1('BAB 1: PENDAHULUAN'),
  h2('1.1 Latar Belakang Masalah'),
  p('Sebagai institusi perguruan tinggi dengan mobilitas civitas akademika yang tinggi dan luas wilayah kampus yang besar, insiden kehilangan barang berharga (seperti Kartu Tanda Mahasiswa/KTM, kunci kendaraan, gawai/laptop, dompet, dan aksesoris) serta kerusakan sarana-prasarana (seperti AC ruang kuliah bocor, proyektor mati, kursi rusak, dan lampu padam) terjadi hampir setiap hari di berbagai sudut gedung.'),
  p('Sebelum adanya sistem terpadu, mekanisme penanganan masalah ini menghadapi kendala serius:'),
  bullet('Penyebaran Informasi Tidak Terstruktur:', 'Informasi kehilangan disebarkan melalui story media sosial atau grup chat WhatsApp angkatan yang cepat tenggelam oleh obrolan lain, sehingga peluang barang kembali ke pemilik sah sangat rendah.'),
  bullet('Ketiadaan Verifikasi Kepemilikan:', 'Tidak ada bukti autentikasi atau pencatatan identitas pelapor dan penemu, yang membuka celah klaim palsu atas barang berharga yang ditemukan.'),
  bullet('Birokrasi Pelaporan Fasilitas Lambat:', 'Mahasiswa tidak mengetahui nomor kontak atau kantor unit pengelola sarana dan prasarana (Sarpras) di masing-masing fakultas, sehingga fasilitas rusak dibiarkan berhari-hari tanpa tindak lanjut.'),
  bullet('Tidak Ada Pelacakan Status:', 'Pelapor tidak mendapatkan transparansi apakah laporan kerusakan telah ditinjau, sedang dikerjakan oleh teknisi, atau sudah terselesaikan.'),

  h2('1.2 Tujuan Pengembangan Sistem'),
  p('Sistem Informasi "Campus Lapor" dikembangkan dengan tujuan:'),
  bullet('Pusat Pelaporan Terpadu (One-Stop Portal):', 'Menyatukan pelaporan barang hilang dan kerusakan fasilitas kampus dalam satu ekosistem yang mudah dijangkau dari ponsel pintar maupun peramban web.'),
  bullet('Meningkatkan Angka Pengembalian Barang:', 'Memfasilitasi penemuan barang dengan pencarian kata kunci, pengelompokan tag barang, lokasi spesifik, dan fitur chat privat langsung antara penemu dan pemilik.'),
  bullet('Mempercepat Penanganan Sarpras:', 'Memberikan dashboard komprehensif bagi admin unit/fakultas untuk memverifikasi, menugaskan perbaikan fasilitas, dan mengubah status laporan menjadi transparan.'),
  bullet('Tata Kelola Bertingkat (Governance):', 'Menjamin hanya staf/admin terverifikasi yang mengelola data fasilitas kampus melalui mekanisme persetujuan seleksi oleh Superadmin.'),

  h2('1.3 Ruang Lingkup Sistem (Scope)'),
  p('Ruang lingkup sistem Campus Lapor mencakup 6 pilar utama:'),
  bullet('1. Modul Autentikasi & Seleksi Akun:', 'Registrasi dan login civitas via mobile, serta registrasi admin dengan seleksi bertingkat oleh Superadmin via web.'),
  bullet('2. Modul Pelaporan Barang Hilang:', 'Pembuatan laporan kehilangan/temuan barang, upload foto bukti, tagging kategori, filter lokasi, serta serah terima barang.'),
  bullet('3. Modul Pelaporan Fasilitas Rusak:', 'Pelaporan kerusakan fasilitas kampus, monitoring timeline perbaikan, dan dokumentasi penyelesaian oleh admin.'),
  bullet('4. Modul Komunikasi Real-time (Chat):', 'Percakapan instan antara civitas dengan pelapor lain (peer-to-peer) dan civitas dengan Admin Kampus.'),
  bullet('5. Modul Notifikasi:', 'Pemberitahuan perubahan status laporan dan pesan baru secara real-time.'),
  bullet('6. Modul Master Data Kampus:', 'Manajemen gedung, area, dan zonasi kampus untuk standardisasi lokasi pelaporan.'),
  pageBreak()
);

// ==========================================
// 4. BAB 2: GAMBARAN UMUM APLIKASI
// ==========================================
docElements.push(
  h1('BAB 2: GAMBARAN UMUM APLIKASI CAMPUS LAPOR'),
  h2('2.1 Deskripsi Umum Sistem Multi-Platform'),
  p('Campus Lapor dirancang dengan arsitektur modern multi-platform yang membagi antarmuka menjadi dua kanal utama:'),
  bullet('Kanal Mobile (Flutter):', 'Diperuntukkan bagi Civitas Akademika (Mahasiswa, Dosen, Tenaga Kependidikan) dengan antarmuka yang ramah pengguna, responsif, dan mudah diakses kapan saja saat berada di lapangan.'),
  bullet('Kanal Web (Laravel + Tailwind CSS):', 'Diperuntukkan bagi Administrator Fakultas dan Superadmin Kampus yang membutuhkan ruang kerja luas (desktop viewport) untuk mengelola antrean laporan, memvalidasi berkas, dan memantau status fasilitas.'),

  h2('2.2 Arsitektur Teknologi (Tech Stack)'),
  p('Sistem dibangun menggunakan kombinasi teknologi tangguh dan teruji:'),
  createTable(
    ['Komponen', 'Teknologi yang Digunakan', 'Fungsi & Peranan dalam Sistem'],
    [
      ['Frontend Mobile', 'Flutter SDK 3.x (Dart)', 'Aplikasi client mobile native Android/iOS dengan Material 3 design.'],
      ['Frontend Web Admin', 'Laravel Blade + Tailwind CSS + Vanilla JS', 'Dashboard web desktop interaktif, responsif, dan ringan tanpa dependensi berat.'],
      ['Backend RESTful API', 'PHP 8.2 + Laravel Framework 11', 'Penyedia endpoint REST API untuk mobile client dan penanganan logika bisnis web.'],
      ['Database Engine', 'MongoDB Atlas (NoSQL Document DB)', 'Penyimpanan dokumen fleksibel untuk laporan multimedia, profil, chat, dan notifikasi.'],
      ['Automated Testing Capture', 'Playwright Test Automation (Chromium)', 'Penangkapan screenshot antarmuka resolusi tinggi dari server lokal secara terotomasi.'],
      ['Cloud Deployment', 'Railway App Platform', 'Hosting server web dan backend API dengan ketersediaan tinggi (High Availability).']
    ],
    [22, 33, 45]
  ),
  p(''),

  h2('2.3 Peran Pengguna (User Roles) & Hak Akses'),
  p('Sistem Campus Lapor membagi hak akses ke dalam 3 hierarki peran:'),
  bullet('1. Superadmin (Tingkat Universitas):', 'Memegang otoritas tertinggi untuk mengawasi seluruh unit kampus, meninjau permohonan pendaftaran admin baru dari fakultas/unit (Approve/Reject), mengaktifkan/menonaktifkan akun admin, serta memantau data master kampus.'),
  bullet('2. Admin Kampus / Fakultas (Tingkat Unit):', 'Bertugas memproses laporan barang hilang (mengubah status menjadi "Menunggu Diambil" atau "Sudah Diambil"), memproses laporan fasilitas rusak (mengubah status "Diproses" dan "Sudah Diperbaiki"), berkomunikasi dengan pelapor via chat, dan mengelola daftar lokasi kampus.'),
  bullet('3. Civitas Akademika (Tingkat Mahasiswa/Staf):', 'Pengguna aplikasi mobile yang dapat membuat laporan kehilangan/temuan, menjelajahi katalog barang hilang, melaporkan fasilitas rusak, berinteraksi via chat dengan pelapor atau admin, serta menerima notifikasi status.'),

  p('Berikut adalah matriks komparasi hak akses antar peran:'),
  createTable(
    ['Fitur & Fungsi Sistem', 'Civitas (Mobile)', 'Admin (Web)', 'Superadmin (Web)'],
    [
      ['Registrasi & Login Mandiri', 'Ya (NIM/Civitas)', 'Ya (Pendaftaran Admin)', 'Login Akun Utama'],
      ['Seleksi & Persetujuan Akun Admin', 'Tidak', 'Tidak', 'Ya (Penuh)'],
      ['Aktivasi / Deaktivasi Admin Aktif', 'Tidak', 'Tidak', 'Ya (Penuh)'],
      ['Membuat Laporan Barang Hilang', 'Ya (Mobile)', 'Dapat Meninjau', 'Dapat Meninjau'],
      ['Membuat Laporan Fasilitas Rusak', 'Ya (Mobile)', 'Dapat Meninjau', 'Dapat Meninjau'],
      ['Ubah Status Barang (Menunggu/Diambil)', 'Hanya Milik Sendiri', 'Ya (Seluruh Laporan)', 'Dapat Memantau'],
      ['Ubah Status Fasilitas (Diproses/Selesai)', 'Tidak', 'Ya (Seluruh Laporan)', 'Dapat Memantau'],
      ['Kirim Pesan Chat ke Admin', 'Ya (Mobile)', 'Ya (Web)', 'Dapat Memantau'],
      ['Kirim Pesan Chat Antar Civitas', 'Ya (Mobile)', 'Tidak', 'Tidak'],
      ['Kelola Data Master Lokasi Kampus', 'Tidak', 'Ya (Tambah/Edit Lokasi)', 'Dapat Memantau']
    ],
    [40, 20, 20, 20]
  ),
  pageBreak()
);

// ==========================================
// 5. BAB 3: KEBUTUHAN FUNGSIONAL & NON-FUNGSIONAL
// ==========================================
docElements.push(
  h1('BAB 3: KEBUTUHAN PERANGKAT LUNAK (SOFTWARE REQUIREMENTS)'),
  h2('3.1 Kebutuhan Fungsional (Functional Requirements)'),
  p('Kebutuhan fungsional mendefinisikan kapabilitas dan layanan yang wajib disediakan oleh sistem Campus Lapor. Tabel di bawah ini menjadi acuan utama bagi tim tester dalam merancang skenario pengujian fungsional (functional test cases):'),
  createTable(
    ['Kode FR', 'Nama Kebutuhan', 'Deskripsi Kebutuhan Fungsional', 'Aktor', 'Prioritas'],
    [
      ['FR-AUTH-01', 'Login Sistem', 'Sistem harus dapat memvalidasi kredensial (username/email dan password) untuk Civitas, Admin, dan Superadmin.', 'Semua Aktor', 'Tinggi'],
      ['FR-AUTH-02', 'Registrasi Civitas', 'Sistem mobile harus memungkinkan civitas mendaftarkan akun baru dengan memasukkan nama, NIM, email, dan password.', 'Civitas', 'Tinggi'],
      ['FR-AUTH-03', 'Pendaftaran Calon Admin', 'Sistem web harus menyediakan formulir pendaftaran admin dengan memilih unit/fakultas dan mengunggah dokumen identitas.', 'Calon Admin', 'Tinggi'],
      ['FR-AUTH-04', 'Logout Sistem', 'Sistem harus dapat menghapus token sesi aktif dan mengembalikan pengguna ke halaman autentikasi.', 'Semua Aktor', 'Tinggi'],
      ['FR-ADM-01', 'Seleksi Pendaftaran Admin', 'Superadmin harus dapat melihat daftar permohonan admin dan mengambil tindakan Approve atau Reject.', 'Superadmin', 'Tinggi'],
      ['FR-ADM-02', 'Manajemen Admin Aktif', 'Superadmin harus dapat melihat daftar admin aktif serta menonaktifkan akun admin yang bermasalah.', 'Superadmin', 'Sedang'],
      ['FR-LOST-01', 'Buat Laporan Barang', 'Civitas harus dapat membuat laporan barang hilang/temuan disertai judul, kategori, lokasi, deskripsi, dan foto bukti.', 'Civitas', 'Tinggi'],
      ['FR-LOST-02', 'Katalog & Pencarian Barang', 'Sistem mobile harus menampilkan feed barang hilang dengan kemampuan pencarian teks dan filter kategori/lokasi.', 'Civitas', 'Tinggi'],
      ['FR-LOST-03', 'Verifikasi Status Barang', 'Admin harus dapat meninjau detail barang hilang dan memperbarui status menjadi Menunggu Diambil atau Sudah Diambil.', 'Admin', 'Tinggi'],
      ['FR-LOST-04', 'Konfirmasi Penemuan Barang', 'Pelapor pada aplikasi mobile harus dapat menandai laporannya telah selesai/ditemukan.', 'Civitas', 'Sedang'],
      ['FR-FAC-01', 'Buat Laporan Fasilitas', 'Civitas harus dapat melaporkan kerusakan sarana kampus beserta foto kondisi dan lokasi spesifik.', 'Civitas', 'Tinggi'],
      ['FR-FAC-02', 'Tinjau Laporan Fasilitas', 'Admin harus dapat melihat antrean laporan kerusakan fasilitas kampus pada dashboard web.', 'Admin', 'Tinggi'],
      ['FR-FAC-03', 'Update Status Perbaikan', 'Admin harus dapat memperbarui tahapan perbaikan (Pending, Diproses, hingga Sudah Diperbaiki).', 'Admin', 'Tinggi'],
      ['FR-CHAT-01', 'Chat Civitas ke Admin', 'Civitas harus dapat mengirim pesan langsung ke Admin Kampus mengenai koordinasi laporan barang atau fasilitas.', 'Civitas, Admin', 'Tinggi'],
      ['FR-CHAT-02', 'Chat Peer-to-Peer Civitas', 'Civitas dapat mengirim pesan privat ke pelapor barang lain untuk konfirmasi serah terima.', 'Civitas', 'Tinggi'],
      ['FR-CHAT-03', 'Indikator Unread Chat', 'Sistem harus menampilkan badge jumlah pesan yang belum dibaca pada bilah navigasi.', 'Civitas, Admin', 'Sedang'],
      ['FR-NOTIF-01', 'Notifikasi Pembaruan Status', 'Sistem harus mengirim notifikasi ke civitas saat status laporan barang atau fasilitasnya diperbarui oleh admin.', 'Civitas', 'Tinggi'],
      ['FR-LOC-01', 'Master Data Lokasi Kampus', 'Admin harus dapat menambah, memperbarui, dan menghapus daftar gedung dan area kampus.', 'Admin', 'Sedang'],
      ['FR-LOC-02', 'Sinkronisasi Dropdown Lokasi', 'Dropdown lokasi di formulir pelaporan mobile harus otomatis tersinkronisasi dengan master data kampus.', 'Civitas', 'Sedang']
    ],
    [15, 20, 38, 17, 10]
  ),
  p(''),

  h2('3.2 Kebutuhan Non-Fungsional (Non-Functional Requirements)'),
  p('Kebutuhan non-fungsional mendefinisikan batasan kinerja, keamanan, ketersediaan, dan kualitas operasional sistem:'),
  createTable(
    ['Kode NFR', 'Kategori Kualitas', 'Parameter / Metrik Pengujian', 'Deskripsi Kebutuhan Non-Fungsional'],
    [
      ['NFR-USAB-01', 'Usability', 'System Usability Scale (SUS) > 75', 'Antarmuka mobile dan web harus intuitif, responsif, dan memiliki navigasi yang jelas dengan waktu adaptasi pengguna baru < 3 menit.'],
      ['NFR-PERF-01', 'Performance', 'Response Time API < 2.0 Detik', 'Setiap request data laporan, chat, dan autentikasi melalui API harus mengembalikan respon dalam waktu kurang dari 2 detik pada kondisi normal.'],
      ['NFR-RELI-01', 'Reliability', 'Ketersediaan Server (Uptime) > 99%', 'Aplikasi web dan backend API harus memiliki tingkat ketersediaan tinggi di cloud Railway tanpa crash tak tertangani.'],
      ['NFR-SECU-01', 'Security', 'Password Hashing & Token Auth', 'Password pengguna wajib di-hash menggunakan algoritma Bcrypt (cost factor 10+) dan request API mobile diamankan dengan Bearer Token.'],
      ['NFR-DATA-01', 'Data Integrity', 'NoSQL Atomic Validation', 'Setiap pembuatan laporan wajib memvalidasi kelengkapan field wajib (judul, kategori, lokasi, identitas pelapor) sebelum disimpan ke MongoDB.'],
      ['NFR-PORT-01', 'Portability', 'Multi-Platform Compatibility', 'Aplikasi mobile dapat dijalankan pada Android OS (v8.0+) dan Web Browser modern (Chrome, Edge, Firefox, Safari).'],
      ['NFR-MAINT-01', 'Maintainability', 'Modular Architecture', 'Kode backend Laravel dan mobile Flutter disusun modular (Controller, Service, Model terpisah) memudahkan debugging dan refactoring.']
    ],
    [16, 16, 28, 40]
  ),
  pageBreak()
);

// ==========================================
// 6. BAB 4: PERMODELAN SISTEM (USE CASE & ACTIVITY)
// ==========================================
docElements.push(
  h1('BAB 4: PERMODELAN SISTEM (USE CASE & ACTIVITY DIAGRAM)'),
  h2('4.1 Use Case Diagram'),
  p('Use Case Diagram berikut memetakan relasi fungsional antara tiga aktor utama (Civitas Akademika, Admin Kampus, dan Superadmin) dengan use case di dalam batas sistem Campus Lapor:'),
  ...imageBox(path.join(ASSETS_DIR, 'diagram_usecase.png'), 'Gambar 4.1: Use Case Diagram Sistem Campus Lapor (Web & Mobile)', 540, 415),
  p([
    { text: 'Penjelasan Diagram Use Case: ', bold: true },
    'Civitas Akademika berinteraksi melalui kanal mobile untuk membuat laporan kehilangan/temuan, menelusuri katalog barang hilang, melaporkan kerusakan fasilitas kampus, berkomunikasi lewat pesan instan, dan menerima notifikasi. Admin Kampus bertugas memproses antrean laporan fasilitas dan barang, mengelola lokasi kampus, serta membalas pesan. Superadmin memegang wewenang eksklusif untuk menyeleksi pendaftaran admin baru dan mengelola status keaktifan admin.'
  ]),

  h2('4.2 Deskripsi Use Case (Use Case Descriptions - UCD)'),
  p('Berikut adalah rincian Use Case Description untuk use case inti sebagai panduan evaluasi tim penguji:'),

  // UCD-01
  h3('UCD-01: Autentikasi Pengguna & Manajemen Sesi'),
  createTable(
    ['Atribut', 'Spesifikasi Use Case'],
    [
      ['ID & Nama Use Case', 'UCD-01: Login & Autentikasi Pengguna'],
      ['Aktor Utama', 'Civitas Akademika, Admin Kampus, Superadmin'],
      ['Deskripsi', 'Pengguna memasukkan kredensial untuk mendapatkan akses ke modul sistem sesuai perannya.'],
      ['Kondisi Awal (Precondition)', 'Pengguna telah terdaftar di database dan berada pada halaman login (Mobile / Web).'],
      ['Alur Normal (Main Flow)', [
        '1. Pengguna membuka halaman login.',
        '2. Pengguna mengisi username/NIM dan password.',
        '3. Pengguna menekan tombol "Masuk" / "Login".',
        '4. Sistem memverifikasi kredensial ke database MongoDB.',
        '5. Sistem menghasilkan token sesi dan mengarahkan ke dashboard/beranda sesuai peran.'
      ]],
      ['Alur Alternatif (Alt Flow)', [
        '4a. Jika password atau username salah, sistem menampilkan pesan error "Kredensial tidak valid".',
        '4b. Jika akun admin berstatus "Pending" atau "Ditolak", sistem menolak login dan memberi peringatan status akun.'
      ]],
      ['Kondisi Akhir (Postcondition)', 'Pengguna berhasil masuk ke antarmuka aplikasi dengan hak akses terverifikasi.']
    ],
    [28, 72]
  ),
  p(''),

  // UCD-02
  h3('UCD-02: Pendaftaran & Seleksi Admin oleh Superadmin'),
  createTable(
    ['Atribut', 'Spesifikasi Use Case'],
    [
      ['ID & Nama Use Case', 'UCD-02: Pendaftaran & Seleksi Admin Kampus'],
      ['Aktor Utama', 'Calon Admin, Superadmin'],
      ['Deskripsi', 'Calon admin mendaftar melalui formulir web, kemudian Superadmin memvalidasi dan menyetujui akun.'],
      ['Kondisi Awal (Precondition)', 'Calon admin memiliki surat tugas/identitas unit kampus; Superadmin telah login.'],
      ['Alur Normal (Main Flow)', [
        '1. Calon admin mengisi form pendaftaran di web: nama, username, email, unit, dan password.',
        '2. Sistem menyimpan data dengan status "Pending".',
        '3. Superadmin membuka halaman "Seleksi Admin".',
        '4. Superadmin meninjau kelayakan profil calon admin.',
        '5. Superadmin menekan tombol "Setujui" (Approve).',
        '6. Sistem mengubah status akun menjadi "Aktif" dan memindahkan ke daftar Admin Aktif.'
      ]],
      ['Alur Alternatif (Alt Flow)', [
        '5a. Jika data tidak valid, Superadmin menekan tombol "Tolak" (Reject). Status akun menjadi "Ditolak".'
      ]],
      ['Kondisi Akhir (Postcondition)', 'Admin yang disetujui dapat login ke Web Admin; admin yang ditolak tidak dapat login.']
    ],
    [28, 72]
  ),
  p(''),

  // UCD-03
  h3('UCD-03: Pelaporan Barang Hilang & Serah Terima'),
  createTable(
    ['Atribut', 'Spesifikasi Use Case'],
    [
      ['ID & Nama Use Case', 'UCD-03: Pelaporan & Serah Terima Barang Hilang'],
      ['Aktor Utama', 'Civitas Akademika (Pelapor), Admin Kampus'],
      ['Deskripsi', 'Civitas membuat laporan kehilangan/temuan barang, ditinjau admin, dan diproses serah terima.'],
      ['Kondisi Awal (Precondition)', 'Civitas telah login ke aplikasi mobile.'],
      ['Alur Normal (Main Flow)', [
        '1. Civitas membuka menu "Buat Laporan" di mobile.',
        '2. Memilih kategori "Barang Hilang", memilih tag (KTM, Kunci, dll), mengisi lokasi, deskripsi, dan foto.',
        '3. Civitas menekan tombol "Kirim Laporan".',
        '4. Laporan muncul di feed beranda mobile dan tabel "Barang Hilang" pada Web Admin.',
        '5. Admin memverifikasi dan mengubah status menjadi "Menunggu Diambil" saat barang diamankan.',
        '6. Pemilik mengambil barang, dan status diperbarui menjadi "Sudah Diambil" (Selesai).'
      ]],
      ['Alur Alternatif (Alt Flow)', [
        '3a. Jika kolom wajib kosong atau ukuran foto melebihi limit, sistem menampilkan peringatan validasi.',
        '4a. Civitas pemilik langsung menghubungi penemu via chat privat untuk serah terima mandiri.'
      ]],
      ['Kondisi Akhir (Postcondition)', 'Status laporan terarsip sebagai "Sudah Diambil" dan riwayat tercatat di profil.']
    ],
    [28, 72]
  ),
  p(''),

  // UCD-04
  h3('UCD-04: Pelaporan & Penanganan Fasilitas Rusak'),
  createTable(
    ['Atribut', 'Spesifikasi Use Case'],
    [
      ['ID & Nama Use Case', 'UCD-04: Pelaporan & Penanganan Fasilitas Rusak'],
      ['Aktor Utama', 'Civitas Akademika (Pelapor), Admin Kampus'],
      ['Deskripsi', 'Civitas melaporkan sarana kampus rusak, admin menindaklanjuti progres perbaikan secara berkala.'],
      ['Kondisi Awal (Precondition)', 'Civitas telah login di mobile; Admin telah login di web.'],
      ['Alur Normal (Main Flow)', [
        '1. Civitas memilih kategori "Fasilitas Rusak", memilih lokasi gedung/ruang, mengisi uraian kerusakan, dan foto.',
        '2. Laporan dikirim ke server dengan status awal "Pending / Menunggu Verifikasi".',
        '3. Admin melihat laporan masuk pada menu "Fasilitas Rusak" di web.',
        '4. Admin menghubungi teknisi sarpras dan mengubah status menjadi "Diproses".',
        '5. Sistem mengirimkan notifikasi perubahan status ke ponsel civitas pelapor.',
        '6. Setelah teknisi menyelesaikan perbaikan, Admin mengubah status menjadi "Sudah Diperbaiki".'
      ]],
      ['Alur Alternatif (Alt Flow)', [
        '4a. Jika laporan duplikat atau tidak valid, Admin dapat menghapus atau menolak laporan dengan catatan.'
      ]],
      ['Kondisi Akhir (Postcondition)', 'Fasilitas kampus kembali normal dan pelapor menerima notifikasi penyelesaian.']
    ],
    [28, 72]
  ),
  p(''),

  // UCD-05
  h3('UCD-05: Komunikasi Real-time (Chat Antar Pengguna & Admin)'),
  createTable(
    ['Atribut', 'Spesifikasi Use Case'],
    [
      ['ID & Nama Use Case', 'UCD-05: Komunikasi Real-time / Chat'],
      ['Aktor Utama', 'Civitas Akademika, Admin Kampus'],
      ['Deskripsi', 'Fitur pesan langsung untuk mengonfirmasi detail barang atau koordinasi fasilitas.'],
      ['Kondisi Awal (Precondition)', 'Kedua pihak terautentikasi pada sesi aplikasi masing-masing.'],
      ['Alur Normal (Main Flow)', [
        '1. Civitas menekan tombol "Hubungi Pelapor" pada kartu barang hilang atau memilih tab "Pesan".',
        '2. Pengguna mengetik pesan pada kolom input dan menekan kirim.',
        '3. Pesan tersimpan di database dan muncul pada thread obrolan lawan bicara.',
        '4. Lawan bicara membuka pesan dan membalas obrolan secara langsung.'
      ]],
      ['Alur Alternatif (Alt Flow)', [
        '2a. Jika pesan kosong, tombol kirim dinonaktifkan.',
        '3a. Jika lawan bicara offline, pesan tetap tersimpan dan muncul saat lawan bicara login kembali.'
      ]],
      ['Kondisi Akhir (Postcondition)', 'Pesan terkirim dan riwayat obrolan tersimpan aman di database.']
    ],
    [28, 72]
  ),
  pageBreak()
);

// ==========================================
// 7. ACTIVITY DIAGRAMS
// ==========================================
docElements.push(
  h2('4.3 Activity Diagram Sistem'),
  p('Activity diagram menggambarkan aliran aktivitas bisnis (business workflow) dari satu aktivitas ke aktivitas lainnya dalam sistem:'),

  h3('4.3.1 Activity Diagram: Pelaporan & Serah Terima Barang Hilang'),
  p('Diagram alur aktivitas proses pelaporan barang hilang hingga barang diserahkan kembali kepada pemilik yang sah:'),
  ...imageBox(path.join(ASSETS_DIR, 'diagram_activity_barang.png'), 'Gambar 4.2: Activity Diagram Pelaporan & Serah Terima Barang Hilang', 540, 360),
  p([
    { text: 'Narasi Alur: ', bold: true },
    'Proses dimulai saat civitas menemukan atau kehilangan barang dan mengisi form pada mobile app. Laporan dipublikasikan ke katalog umum. Jika barang diamankan oleh admin/satpam, admin mengubah status menjadi "Menunggu Diambil". Pemilik yang mengenali barangnya dapat mendatangi pos keamanan atau menghubungi via chat, menunjukkan bukti kepemilikan, dan admin mengubah status akhir menjadi "Sudah Diambil".'
  ]),

  h3('4.3.2 Activity Diagram: Pelaporan & Penanganan Fasilitas Rusak'),
  p('Diagram alur aktivitas penanganan fasilitas sarpras rusak dari pelaporan hingga tuntas diperbaiki:'),
  ...imageBox(path.join(ASSETS_DIR, 'diagram_activity_fasilitas.png'), 'Gambar 4.3: Activity Diagram Pelaporan & Perbaikan Fasilitas Rusak', 540, 360),
  p([
    { text: 'Narasi Alur: ', bold: true },
    'Civitas mengambil foto fasilitas yang rusak dan mengirim laporan dari ponsel. Admin Fakultas menerima laporan pada dashboard web, memverifikasi tingkat urgensi, meneruskan surat penugasan ke tim teknisi sarpras, dan memperbarui status sistem menjadi "Diproses". Setelah perbaikan fisik selesai, admin memverifikasi hasil kerja teknisi dan menutup laporan dengan status "Sudah Diperbaiki".'
  ]),

  h3('4.3.3 Activity Diagram: Pendaftaran & Seleksi Admin oleh Superadmin'),
  p('Diagram alur aktivitas proses registrasi calon admin fakultas hingga verifikasi oleh Superadmin:'),
  ...imageBox(path.join(ASSETS_DIR, 'diagram_activity_seleksi_admin.png'), 'Gambar 4.4: Activity Diagram Seleksi Akun Admin oleh Superadmin', 540, 360),
  p([
    { text: 'Narasi Alur: ', bold: true },
    'Calon admin mengisi form registrasi di web admin dengan menyertakan unit tugas. Data masuk ke antrean seleksi dengan status "Pending". Superadmin meninjau identitas pendaftar. Jika disetujui, akun diaktivasi sehingga admin dapat login mengelola data. Jika ditolak, akun dibatalkan dan calon admin tidak memperoleh hak akses ke sistem.'
  ]),
  pageBreak()
);

// ==========================================
// 8. BAB 5: ARSITEKTUR BASIS DATA
// ==========================================
docElements.push(
  h1('BAB 5: PERANCANGAN ARSITEKTUR BASIS DATA (DATABASE)'),
  h2('5.1 Konsep Basis Data NoSQL Document-Based (MongoDB Atlas)'),
  p('Sistem Campus Lapor mengadopsi basis data NoSQL MongoDB Atlas yang diakses menggunakan driver MongoDB terintegrasi pada Laravel ORM. Pendekatan dokumen (JSON/BSON) dipilih karena:'),
  bullet('Fleksibilitas Struktur Laporan:', 'Laporan fasilitas dan barang memiliki atribut opsional yang dinamis (seperti foto Base64/URI, penandaan tag, koordinat/nama ruangan spesifik).'),
  bullet('Struktur Pesan Chat Bersarang (Embedded / Referenced):', 'Percakapan dapat dikelompokkan per-thread dengan performa baca-tulis tinggi tanpa locking tabel relational.'),
  bullet('Skalabilitas Cloud:', 'MongoDB Atlas mendukung pemeliharaan indeks otomatis, replikasi data, dan kemudahan backup di lingkungan cloud.'),

  h2('5.2 Entity Relationship / Collection Schema Diagram'),
  p('Berikut adalah diagram arsitektur skema koleksi data dan keterhubungan referensi logis antar entitas:'),
  ...imageBox(path.join(ASSETS_DIR, 'diagram_database_schema.png'), 'Gambar 5.1: Skema Arsitektur Basis Data MongoDB Campus Lapor', 550, 393),

  h2('5.3 Spesifikasi Kamus Data Koleksi (Data Dictionary)'),
  p('Rincian struktur kolom/field setiap koleksi pada database sistem:'),

  h3('1. Koleksi: `users` (Data Akun Pengguna Sistem)'),
  createTable(
    ['Nama Field', 'Tipe Data', 'Keterangan & Aturan Nilai', 'Indeks'],
    [
      ['_id', 'ObjectId', 'Pengenal unik primer dokumen pengguna.', 'Primary Key'],
      ['name', 'String', 'Nama lengkap civitas atau administrator.', 'Normal'],
      ['username', 'String', 'Username unik untuk login web (admin/superadmin).', 'Unique'],
      ['identifier', 'String', 'NIM / NIP identitas civitas pada mobile app.', 'Unique / Sparse'],
      ['email', 'String', 'Alamat email pengguna yang valid.', 'Unique'],
      ['password', 'String', 'Hash kata sandi terenkripsi algoritma Bcrypt.', 'None'],
      ['role', 'String', 'Peran pengguna: "superadmin", "admin", atau "civitas".', 'Index'],
      ['campus_key', 'String', 'Kode unit / fakultas (contoh: "admin1", "FMIPA").', 'Normal'],
      ['status', 'String', 'Status akun: "active", "pending", "rejected", "banned".', 'Index'],
      ['created_at', 'Timestamp', 'Waktu pembuatan akun.', 'None']
    ],
    [20, 18, 47, 15]
  ),
  p(''),

  h3('2. Koleksi: `laporan_barang` (Laporan Kehilangan & Temuan)'),
  createTable(
    ['Nama Field', 'Tipe Data', 'Keterangan & Aturan Nilai', 'Indeks'],
    [
      ['_id', 'ObjectId', 'Pengenal unik laporan barang.', 'Primary Key'],
      ['reporter_id', 'String', 'NIM/ID civitas pelapor.', 'Index'],
      ['reporter_name', 'String', 'Nama civitas yang membuat laporan.', 'None'],
      ['title', 'String', 'Judul ringkas barang (contoh: "KTM a.n. Budi").', 'Text Search'],
      ['category', 'String', 'Kategori: "Barang Hilang" atau "Barang Ditemukan".', 'Index'],
      ['tag', 'String', 'Tag jenis: "Laptop", "Kunci", "HP", "Dompet", dll.', 'Index'],
      ['location', 'String', 'Titik lokasi kejadian (contoh: "Perpustakaan LSI").', 'Index'],
      ['description', 'String', 'Uraian detail ciri-ciri fisik barang.', 'None'],
      ['photo_data', 'String / Text', 'Data foto bukti barang (Base64 / URL path).', 'None'],
      ['status', 'String', 'Status: "Aktif", "Menunggu Diambil", "Sudah Diambil".', 'Index'],
      ['campus_key', 'String', 'Kode unit kampus yang menangani laporan.', 'Index'],
      ['created_at', 'Timestamp', 'Waktu pembuatan laporan.', 'Index']
    ],
    [20, 18, 47, 15]
  ),
  p(''),

  h3('3. Koleksi: `laporan_fasilitas` (Laporan Kerusakan Sarpras Kampus)'),
  createTable(
    ['Nama Field', 'Tipe Data', 'Keterangan & Aturan Nilai', 'Indeks'],
    [
      ['_id', 'ObjectId', 'Pengenal unik laporan kerusakan fasilitas.', 'Primary Key'],
      ['reporter_id', 'String', 'NIM/ID civitas pelapor.', 'Index'],
      ['reporter_name', 'String', 'Nama pelapor fasilitas rusak.', 'None'],
      ['title', 'String', 'Judul masalah (contoh: "AC Bocor di RK A1.02").', 'Text Search'],
      ['location', 'String', 'Nama gedung dan nomor ruangan spesifik.', 'Index'],
      ['description', 'String', 'Uraian tingkat kerusakan fasilitas.', 'None'],
      ['photo_data', 'String / Text', 'Foto dokumentasi kerusakan fisik sarana.', 'None'],
      ['status', 'String', 'Status: "Pending", "Diproses", "Sudah Diperbaiki".', 'Index'],
      ['assigned_admin', 'String', 'Username admin yang menangani proses perbaikan.', 'Normal'],
      ['created_at', 'Timestamp', 'Waktu pelaporan kerusakan.', 'Index']
    ],
    [20, 18, 47, 15]
  ),
  p(''),

  h3('4. Koleksi: `chats` & `chat_messages` (Komunikasi Real-Time)'),
  createTable(
    ['Nama Field', 'Tipe Data', 'Keterangan & Aturan Nilai', 'Indeks'],
    [
      ['_id', 'ObjectId', 'Pengenal unik thread atau pesan.', 'Primary Key'],
      ['sender_id', 'String', 'ID pengirim pesan (NIM atau username admin).', 'Index'],
      ['receiver_id', 'String', 'ID penerima pesan.', 'Index'],
      ['sender_role', 'String', 'Peran pengirim: "civitas" atau "admin".', 'Normal'],
      ['body', 'String', 'Isi teks percakapan.', 'None'],
      ['is_read', 'Boolean', 'Status pesan apakah telah dibaca penerima (true/false).', 'Index'],
      ['campus_key', 'String', 'Lingkup kampus obrolan.', 'Index'],
      ['created_at', 'Timestamp', 'Waktu pengiriman pesan.', 'Index']
    ],
    [20, 18, 47, 15]
  ),
  pageBreak()
);

// ==========================================
// 9. BAB 6: PANDUAN PENGUJIAN & SETUP LINGKUNGAN
// ==========================================
docElements.push(
  h1('BAB 6: PANDUAN MENJALANKAN SISTEM & LINGKUNGAN PENGUJIAN'),
  h2('6.1 Akses Sistem Cloud (Hosted Environment - Direkomendasikan)'),
  p('Untuk mempermudah dan mempercepat pengujian tanpa perlu mengonfigurasi database atau web server lokal, tim penguji sangat disarankan menggunakan lingkungan cloud yang telah kami deploy:'),
  calloutBox(
    'LINK WEB ADMIN CAMPUS LAPOR (RAILWAY PRODUCTION):',
    [
      'URL Akses: https://web-admincampus-lapor-production-3cd2.up.railway.app/login',
      'Masa Berlaku Domain: 30 Hari Aktif (Expired: 9 Oktober 2026)',
      'Catatan Tim Pengembang: Apabila mendekati atau melampaui tanggal tersebut tim tester membutuhkan pembaruan link, silakan langsung mengabari kontak Kelompok E (Kelompok 5).'
    ]
  ),
  p(''),
  p('Kredensial akun siap pakai untuk skenario pengujian:'),
  createTable(
    ['Peran Pengguna', 'Username / ID', 'Password', 'Cakupan Hak Akses Pengujian'],
    [
      ['Superadmin', 'superadmin1', 'superadmin123', 'Akses penuh ke menu Seleksi Admin, Admin Aktif, dan monitoring global sistem.'],
      ['Admin Kampus', 'admin1', 'admin123', 'Akses ke Dashboard, Manajemen Barang Hilang, Fasilitas Rusak, Chat, dan Lokasi Kampus.'],
      ['Civitas Mobile', 'CV-0001 (atau civitas1)', 'civitas123', 'Akses ke aplikasi mobile: Buat laporan barang & fasilitas, feed beranda, chat, dan profil.']
    ],
    [20, 25, 20, 35]
  ),
  p(''),

  h2('6.2 Prasyarat Menjalankan Lingkungan Lokal (Prerequisites)'),
  p('Jika tim penguji hendak menjalankan source code secara utuh di komputer lokal:'),
  bullet('PHP Environment:', 'PHP versi 8.2 atau lebih tinggi dengan ekstensi `ext-mongodb`, `ext-curl`, `ext-mbstring`, `ext-openssl`.'),
  bullet('Composer:', 'Composer versi 2.x untuk instalasi pustaka Laravel.'),
  bullet('Node.js & NPM:', 'Node.js LTS (v18.x atau v20.x) untuk build Tailwind CSS dan asset compiler.'),
  bullet('Flutter SDK:', 'Flutter versi 3.19+ (Channel Stable) beserta Android Studio / Chrome untuk eksekusi mobile client.'),
  bullet('Database:', 'Akun MongoDB Atlas aktif atau instance MongoDB lokal port 27017.'),

  h2('6.3 Panduan Menjalankan Web Admin (Laravel)'),
  p('Ikuti langkah-langkah berikut untuk menjalankan Web Admin di komputer lokal:'),
  bullet('Langkah 1: Masuk ke direktori web:', 'Buka terminal dan navigasikan ke folder `kampus-lapor-web`.'),
  bullet('Langkah 2: Konfigurasi Environment:', 'Salin `.env.example` menjadi `.env`. Pastikan variabel koneksi MongoDB terisi:'),
  calloutBox(
    'KONFIGURASI .ENV LARAVEL MONGODB:',
    [
      'DB_CONNECTION=mongodb',
      'DB_HOST=127.0.0.1 (atau URI MongoDB Atlas)',
      'DB_PORT=27017',
      'DB_DATABASE=campus_lapor',
      'DB_USERNAME=...',
      'DB_PASSWORD=...'
    ]
  ),
  p(''),
  bullet('Langkah 3: Instalasi Dependensi PHP:', 'Jalankan perintah `composer install`.'),
  bullet('Langkah 4: Instalasi Dependensi Frontend:', 'Jalankan perintah `npm install && npm run build` (atau `npm run dev`).'),
  bullet('Langkah 5: Generate Application Key:', 'Jalankan perintah `php artisan key:generate`.'),
  bullet('Langkah 6: Jalankan Server Lokal:', 'Eksekusi `php artisan serve`. Buka browser pada alamat `http://127.0.0.1:8000`.'),

  h2('6.4 Panduan Menjalankan Aplikasi Mobile (Flutter)'),
  p('Ikuti langkah-langkah berikut untuk menjalankan aplikasi mobile civitas:'),
  bullet('Langkah 1: Masuk ke direktori mobile:', 'Buka terminal dan arahkan ke folder `kampus_lapor_mobile`.'),
  bullet('Langkah 2: Unduh Pustaka Flutter:', 'Jalankan perintah `flutter pub get`.'),
  bullet('Langkah 3: Verifikasi Endpoint Server:', 'Buka file `lib/controllers/auth_controller.dart`. Pastikan `_apiBases` mengarah ke server yang aktif (contoh: `http://10.0.2.2:8000` untuk Android Emulator atau link hosted Railway).'),
  bullet('Langkah 4: Jalankan Aplikasi:', 'Ketik `flutter run` untuk menjalankan di emulator Android/perangkat fisik, atau `flutter run -d chrome` untuk preview di peramban web.'),
  pageBreak()
);

// ==========================================
// 10. BAB 7: KATALOG SCREENSHOT ANTARMUKA (PLAYWRIGHT AUTOMATED CAPTURE)
// ==========================================
docElements.push(
  h1('BAB 7: KATALOG SCREENSHOT ANTARMUKA APLIKASI (AUTOMATED PLAYWRIGHT CAPTURE)'),
  p('Seluruh tangkapan layar di bawah ini diambil secara terotomasi langsung dari kode sumber sistem yang sedang berjalan (live instance) menggunakan tools pengujian ', { text: 'Playwright (Chromium)', bold: true }, '. Untuk aplikasi Web menggunakan frame Desktop resolusi 1440x900, dan untuk aplikasi Mobile menggunakan frame Smartphone resolusi 390x844 (aspek rasio smartphone modern).'),

  h2('7.1 Antarmuka Web Administrator & Superadmin (Frame Desktop)'),

  h3('1. Halaman Login Web Admin & Superadmin'),
  p('Halaman pintu masuk untuk administrator dan superadmin dengan validasi autentikasi peran:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_01_login.png'), 'Gambar 7.1: Halaman Login Web Administrator & Superadmin (web_01_login.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Desain split layout bernuansa ungu modern dengan banner informasi sistem di sisi kiri dan panel input kredensial di sisi kanan. Menyediakan opsi pintasan pendaftaran admin baru di bagian bawah.'
  ]),

  h3('2. Halaman Pendaftaran Calon Admin Baru'),
  p('Formulir pengajuan akun admin fakultas/unit yang akan masuk ke antrean seleksi Superadmin:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_02_daftar_admin.png'), 'Gambar 7.2: Halaman Registrasi Calon Admin Fakultas (web_02_daftar_admin.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Input form terstruktur mencakup Nama Lengkap, Username, Email Resmi, Pilihan Unit Kampus, serta unggah dokumen verifikasi identitas pegawai/staf.'
  ]),

  h3('3. Dashboard Utama Administrator Kampus'),
  p('Pusat kendali admin untuk melihat ringkasan statistik laporan dan aktivitas terkini:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_03_dashboard_admin.png'), 'Gambar 7.3: Dashboard Administrator Kampus (web_03_dashboard_admin.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Kartu statistik ringkasan (Total Barang Hilang, Fasilitas Perlu Ditangani, Pesan Masuk, Lokasi Terdaftar) serta tabel pemantauan laporan terbaru yang membutuhkan aksi cepat.'
  ]),

  h3('4. Manajemen Laporan Barang Hilang'),
  p('Halaman pengelolaan data laporan kehilangan dan penemuan barang dari civitas:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_04_barang_hilang.png'), 'Gambar 7.4: Halaman Manajemen Barang Hilang (web_04_barang_hilang.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Tabel interaktif dilengkapi filter status, foto thumbnail barang, lokasi penemuan, identitas pelapor, serta tombol aksi untuk memvalidasi serah terima barang.'
  ]),

  h3('5. Manajemen Laporan Fasilitas Rusak'),
  p('Halaman penanganan keluhan fasilitas sarana dan prasarana kampus:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_05_fasilitas_rusak.png'), 'Gambar 7.5: Halaman Penanganan Fasilitas Rusak (web_05_fasilitas_rusak.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Menampilkan daftar keluhan fasilitas, foto bukti kerusakan, ruangan spesifik, dan kontrol pengubahan status ("Pending" -> "Diproses" -> "Sudah Diperbaiki").'
  ]),

  h3('6. Pusat Komunikasi & Chat Web Admin'),
  p('Kanal obrolan langsung admin dengan civitas pelapor:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_06_pesan_chat.png'), 'Gambar 7.6: Halaman Pesan & Chat Administrator (web_06_pesan_chat.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Panel daftar percakapan aktif di sisi kiri dan jendela percakapan interaktif di sisi kanan untuk membalas pesan dan mengoordinasikan pengambilan barang.'
  ]),

  h3('7. Manajemen Master Data Lokasi Kampus'),
  p('Pengelolaan data gedung, laboratorium, ruang kuliah, dan fasilitas umum kampus:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_07_manajemen_kampus.png'), 'Gambar 7.7: Halaman Manajemen Lokasi Kampus (web_07_manajemen_kampus.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Tabel master lokasi kampus dengan kemampuan tambah lokasi baru, edit nama area, dan sinkronisasi otomatis ke dropdown aplikasi mobile civitas.'
  ]),

  h3('8. Halaman Seleksi Calon Admin (Hak Akses Superadmin)'),
  p('Modul verifikasi penerimaan atau penolakan permohonan admin baru:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_08_superadmin_seleksi.png'), 'Gambar 7.8: Halaman Seleksi Calon Admin oleh Superadmin (web_08_superadmin_seleksi.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Daftar kartu pendaftar admin dengan informasi unit/fakultas, tanggal pendaftaran, serta tombol aksi tegas "Setujui" (hijau) dan "Tolak" (merah).'
  ]),

  h3('9. Halaman Pengelolaan Admin Aktif (Superadmin)'),
  p('Daftar seluruh administrator kampus yang memiliki hak akses aktif:'),
  ...imageBox(path.join(ASSETS_DIR, 'web_09_superadmin_admin_aktif.png'), 'Gambar 7.9: Halaman Daftar Administrator Aktif (web_09_superadmin_admin_aktif.png)', 530, 331),
  p([
    { text: 'Fitur Antarmuka: ', bold: true },
    'Tabel data admin aktif dengan opsi penonaktifan akun (Nonaktifkan / Blokir) apabila staf bersangkutan sudah tidak bertugas.'
  ]),
  pageBreak()
);

// ==========================================
// 11. KATALOG SCREENSHOT MOBILE
// ==========================================
docElements.push(
  h2('7.2 Antarmuka Mobile Civitas Akademika (Frame Smartphone)'),
  p('Berikut adalah tampilan aplikasi mobile pada resolusi smartphone (390x844 viewport):'),

  h3('1. Halaman Login Civitas Mobile'),
  p('Antarmuka login mahasiswa dan civitas akademika dengan nuansa ungu khas Campus Lapor:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_01_login.png'), 'Gambar 7.10: Halaman Login Civitas Mobile (mobile_01_login.png)', 220, 476),

  h3('2. Halaman Registrasi Akun Civitas'),
  p('Formulir pendaftaran akun mahasiswa baru dengan verifikasi NIM dan email kampus:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_02_daftar.png'), 'Gambar 7.11: Halaman Registrasi Civitas (mobile_02_daftar.png)', 220, 476),

  h3('3. Beranda & Feed Barang Hilang'),
  p('Katalog utama pencarian barang hilang dengan fitur search bar, filter tag, dan kartu laporan:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_03_beranda.png'), 'Gambar 7.12: Beranda & Feed Barang Hilang Mobile (mobile_03_beranda.png)', 220, 476),

  h3('4. Pusat Notifikasi Real-Time'),
  p('Daftar pemberitahuan pembaruan status laporan fasilitas dan barang hilang:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_04_notifikasi.png'), 'Gambar 7.13: Pusat Notifikasi Real-Time (mobile_04_notifikasi.png)', 220, 476),

  h3('5. Formulir Buat Laporan Baru'),
  p('Formulir pengisian laporan kerusakan fasilitas atau kehilangan barang lengkap dengan lampiran foto:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_05_buat_laporan.png'), 'Gambar 7.14: Formulir Pembuatan Laporan Mobile (mobile_05_buat_laporan.png)', 220, 476),

  h3('6. Kotak Masuk Pesan / Chat Masuk'),
  p('Daftar percakapan aktif antara civitas dengan Admin Kampus maupun pelapor lain:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_06_pesan_chat.png'), 'Gambar 7.15: Kotak Masuk Pesan Chat Mobile (mobile_06_pesan_chat.png)', 220, 476),

  h3('7. Profil Pengguna & Riwayat Laporan'),
  p('Halaman pengelolaan identitas diri dan pemantauan riwayat status laporan yang pernah dibuat:'),
  ...imageBox(path.join(ASSETS_DIR, 'mobile_07_profil.png'), 'Gambar 7.16: Profil Pengguna & Riwayat Laporan (mobile_07_profil.png)', 220, 476),
  pageBreak()
);

// ==========================================
// 12. BAB 8: REKOMENDASI SKENARIO PENGUJIAN
// ==========================================
docElements.push(
  h1('BAB 8: REKOMENDASI SKENARIO PENGUJIAN (TESTING SCENARIOS)'),
  p('Untuk mendukung tim tester dalam menyusun matriks pengujian (Test Matrix) dan laporan hasil pengujian (Test Report), berikut kami rekomendasikan skenario uji Black-Box utama:'),
  createTable(
    ['ID Test', 'Modul yang Diuji', 'Langkah Pengujian', 'Data Uji (Input)', 'Hasil yang Diharapkan (Expected Result)'],
    [
      ['TC-01', 'Login Superadmin', '1. Buka web /login\n2. Isi kredensial\n3. Klik Masuk', 'user: superadmin1\npass: superadmin123', 'Berhasil login dan diarahkan ke /superadmin/seleksi-admin.'],
      ['TC-02', 'Login Admin Kampus', '1. Buka web /login\n2. Isi kredensial\n3. Klik Masuk', 'user: admin1\npass: admin123', 'Berhasil login dan diarahkan ke dashboard statistik admin.'],
      ['TC-03', 'Login Civitas Mobile', '1. Buka aplikasi mobile\n2. Masukkan NIM & pass\n3. Tekan Masuk', 'nim: CV-0001\npass: civitas123', 'Berhasil login dan membuka feed Beranda Barang Hilang.'],
      ['TC-04', 'Login Gagal (Negative)', '1. Masukkan password keliru\n2. Klik Masuk', 'user: admin1\npass: salah1234', 'Sistem menolak dan menampilkan pesan error kredensial.'],
      ['TC-05', 'Registrasi Admin', '1. Buka /daftar-admin\n2. Isi form lengkap\n3. Submit', 'Unit: FMIPA\nStatus awal: Pending', 'Data pendaftar masuk ke daftar seleksi Superadmin.'],
      ['TC-06', 'Seleksi Admin (Approve)', '1. Login superadmin\n2. Buka Seleksi Admin\n3. Klik Setujui', 'ID Calon Admin', 'Status berubah Aktif dan akun dapat login ke web admin.'],
      ['TC-07', 'Buat Laporan Barang', '1. Login civitas mobile\n2. Menu Buat Laporan\n3. Isi data + foto\n4. Submit', 'Judul: KTM Budi\nTag: Lainnya\nLokasi: LSI', 'Laporan tersimpan dan muncul di feed beranda serta web admin.'],
      ['TC-08', 'Filter & Pencarian', '1. Buka Beranda mobile\n2. Ketik kata kunci\n3. Pilih filter tag', 'Keyword: "KTM"\nTag: "Lainnya"', 'Hanya menampilkan kartu barang yang sesuai kriteria.'],
      ['TC-09', 'Buat Laporan Fasilitas', '1. Pilih kategori Fasilitas\n2. Isi lokasi & deskripsi\n3. Submit', 'Judul: AC Rusak\nLokasi: RK A1.02', 'Laporan muncul di menu Fasilitas Rusak pada Web Admin.'],
      ['TC-10', 'Update Status Fasilitas', '1. Buka web Fasilitas Rusak\n2. Ubah status\n3. Klik Simpan', 'Status: Diproses -> Sudah Diperbaiki', 'Status terupdate di web dan ponsel pelapor menerima notifikasi.'],
      ['TC-11', 'Kirim Pesan Chat', '1. Buka detail laporan\n2. Klik Hubungi Pelapor\n3. Ketik & kirim pesan', 'Pesan: "Barang ada di meja satpam"', 'Pesan tampil instan di layar percakapan kedua pihak.'],
      ['TC-12', 'Tambah Lokasi Kampus', '1. Menu Manajemen Kampus\n2. Klik Tambah\n3. Simpan data', 'Gedung: "Lab Komputer"\nArea: "Lt. 2"', 'Lokasi baru muncul di dropdown formulir mobile civitas.']
    ],
    [10, 18, 22, 22, 28]
  ),
  p(''),

  h2('8.2 Catatan Pengujian Boundary & Validasi Input'),
  p('Tim tester dianjurkan menguji kasus-kasus batas (boundary cases) berikut:'),
  bullet('Ukuran Berkas Foto:', 'Pastikan sistem menolak unggahan foto di atas 5MB dengan pesan ramah pengguna.'),
  bullet('Pencegahan Duplikasi Akun:', 'Pendaftaran dengan NIM atau email yang sudah terdaftar harus dicegah oleh validasi unik sistem.'),
  bullet('Form Kosong (Empty Form):', 'Menekan tombol submit saat kolom judul atau deskripsi kosong harus memicu indikator validasi merah.'),
  bullet('Ketahanan Offline Mobile:', 'Saat koneksi internet terputus, aplikasi mobile tetap dapat menampilkan data lokal tanpa mengalami force close.'),

  h2('8.3 Kontak Dukungan Pengujian (Kelompok E / Kelompok 5)'),
  p('Apabila tim penguji menemukan kendala lingkungan (seperti database reset, perpanjangan masa aktif link hosting Railway, atau pertanyaan seputar business logic), silakan menghubungi kontak perwakilan tim kami:'),
  calloutBox(
    'KONTAK DUKUNGAN TIM PENGEMBANG (KELOMPOK E / KELOMPOK 5):',
    [
      '• Nama Tim: Kelompok E (Kelompok 5) - Proyek Terpadu IPB 2026',
      '• Portal Hosting: https://web-admincampus-lapor-production-3cd2.up.railway.app/login',
      '• Saluran Komunikasi: Grup Koordinasi Mata Kuliah Pengujian Perangkat Lunak',
      '• Kami siap memberikan pendampingan teknis dan akun demo tambahan demi kelancaran tugas pengujian rekan-rekan penguji.'
    ]
  ),
  p(''),
  new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 240, after: 120 },
    children: [
      new TextRun({
        text: '--- AKHIR DOKUMEN SPESIFIKASI & PANDUAN PENGUJIAN ---',
        font: 'Calibri',
        size: 20,
        bold: true,
        color: COLOR_TEXT_MUTED,
      }),
    ],
  })
);

// Create Document
const doc = new Document({
  styles: {
    default: {
      document: {
        run: {
          font: 'Calibri',
          size: 22,
          color: COLOR_TEXT_DARK,
        },
      },
    },
  },
  sections: [
    {
      properties: {
        page: {
          margin: {
            top: 1440, // 1 inch
            bottom: 1440,
            left: 1440,
            right: 1440,
          },
        },
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              alignment: AlignmentType.RIGHT,
              spacing: { before: 0, after: 100 },
              children: [
                new TextRun({
                  text: 'CAMPUS LAPOR | DOKUMENTASI SISTEM & PANDUAN PENGUJIAN (KELOMPOK E)',
                  font: 'Calibri',
                  size: 17, // 8.5pt
                  color: COLOR_TEXT_MUTED,
                }),
              ],
            }),
          ],
        }),
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              alignment: AlignmentType.RIGHT,
              spacing: { before: 100, after: 0 },
              children: [
                new TextRun({
                  text: 'Mata Kuliah Pengujian Perangkat Lunak  |  Halaman ',
                  font: 'Calibri',
                  size: 18,
                  color: COLOR_TEXT_MUTED,
                }),
                new TextRun({
                  children: [PageNumber.CURRENT],
                  font: 'Calibri',
                  size: 18,
                  bold: true,
                  color: COLOR_PRIMARY,
                }),
                new TextRun({
                  text: ' dari ',
                  font: 'Calibri',
                  size: 18,
                  color: COLOR_TEXT_MUTED,
                }),
                new TextRun({
                  children: [PageNumber.TOTAL_PAGES],
                  font: 'Calibri',
                  size: 18,
                  bold: true,
                  color: COLOR_PRIMARY,
                }),
              ],
            }),
          ],
        }),
      },
      children: docElements,
    },
  ],
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUTPUT_DOCX, buffer);
  console.log('====================================================');
  console.log(`Dokumen Word berhasil dibuat: ${OUTPUT_DOCX}`);
  console.log(`Ukuran file: ${(buffer.length / 1024 / 1024).toFixed(2)} MB`);
  console.log('====================================================');
}).catch(err => {
  console.error('Gagal membuat dokumen:', err);
  process.exit(1);
});
