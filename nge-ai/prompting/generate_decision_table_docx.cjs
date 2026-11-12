const docx = require('docx');
const fs = require('fs');
const path = require('path');

const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  WidthType, AlignmentType, BorderStyle, HeadingLevel, ShadingType,
  PageBreak, ImageRun, Header, Footer, PageNumber
} = docx;

// Common styles
const FONT_FAMILY = "Times New Roman";
const COLOR_PRIMARY = "000000";
const COLOR_HEADER_BG = "EAEAEA";
const COLOR_SUBTLE_BG = "F7F9FA";
const COLOR_PASS = "008000";

// Helper for paragraph
function p(text, options = {}) {
  const runs = [];
  if (typeof text === 'string') {
    runs.push(new TextRun({
      text: text,
      font: FONT_FAMILY,
      size: options.size || 24, // 12pt default
      bold: options.bold || false,
      italics: options.italics || false,
      color: options.color || COLOR_PRIMARY,
    }));
  } else if (Array.isArray(text)) {
    for (const item of text) {
      runs.push(new TextRun({
        text: item.text,
        font: FONT_FAMILY,
        size: item.size || options.size || 24,
        bold: item.bold || false,
        italics: item.italics || false,
        color: item.color || COLOR_PRIMARY,
      }));
    }
  }

  return new Paragraph({
    alignment: options.alignment || AlignmentType.LEFT,
    spacing: {
      before: options.spaceBefore !== undefined ? options.spaceBefore : 0,
      after: options.spaceAfter !== undefined ? options.spaceAfter : 120, // ~6pt after
      line: options.lineSpacing || 276, // 1.15 line spacing
    },
    bullet: options.bullet ? { level: 0 } : undefined,
    children: runs,
  });
}

// Helper for section title (A. Tujuan Latihan, etc.)
function sectionTitle(title) {
  return new Paragraph({
    alignment: AlignmentType.LEFT,
    spacing: { before: 240, after: 120, line: 276 },
    children: [
      new TextRun({
        text: title,
        font: FONT_FAMILY,
        size: 24, // 12pt
        bold: true,
        color: COLOR_PRIMARY,
      })
    ]
  });
}

// Helper for question title in Section I
function questionTitle(qNum, qText) {
  return new Paragraph({
    alignment: AlignmentType.LEFT,
    spacing: { before: 200, after: 80, line: 276 },
    children: [
      new TextRun({
        text: `${qNum}. ${qText}`,
        font: FONT_FAMILY,
        size: 24,
        bold: true,
        color: COLOR_PRIMARY,
      })
    ]
  });
}

function answerHeading() {
  return new Paragraph({
    alignment: AlignmentType.LEFT,
    spacing: { before: 60, after: 60, line: 276 },
    children: [
      new TextRun({
        text: "Jawaban:",
        font: FONT_FAMILY,
        size: 24,
        bold: true,
        italics: true,
        color: COLOR_PRIMARY,
      })
    ]
  });
}

// Standard border configuration
const borderConfig = {
  top: { style: BorderStyle.SINGLE, size: 4, color: "777777" },
  bottom: { style: BorderStyle.SINGLE, size: 4, color: "777777" },
  left: { style: BorderStyle.SINGLE, size: 4, color: "777777" },
  right: { style: BorderStyle.SINGLE, size: 4, color: "777777" },
};

// Helper for table cell
function cell(content, options = {}) {
  let paragraphs = [];
  if (typeof content === 'string') {
    paragraphs.push(new Paragraph({
      alignment: options.alignment || AlignmentType.LEFT,
      spacing: { before: 40, after: 40, line: 240 },
      children: [
        new TextRun({
          text: content,
          font: FONT_FAMILY,
          size: options.size || 21, // ~10.5pt
          bold: options.bold || false,
          italics: options.italics || false,
          color: options.color || COLOR_PRIMARY,
        })
      ]
    }));
  } else if (Array.isArray(content)) {
    paragraphs = content.map(item => {
      if (item instanceof Paragraph) return item;
      return new Paragraph({
        alignment: options.alignment || AlignmentType.LEFT,
        spacing: { before: 20, after: 20, line: 240 },
        bullet: item.bullet ? { level: 0 } : undefined,
        children: [
          new TextRun({
            text: typeof item === 'string' ? item : item.text,
            font: FONT_FAMILY,
            size: options.size || 21,
            bold: item.bold || options.bold || false,
            italics: item.italics || false,
            color: item.color || COLOR_PRIMARY,
          })
        ]
      });
    });
  }

  return new TableCell({
    borders: borderConfig,
    shading: options.shading ? { fill: options.shading, type: ShadingType.CLEAR } : undefined,
    width: options.width ? { size: options.width, type: WidthType.PERCENTAGE } : undefined,
    columnSpan: options.columnSpan || 1,
    rowSpan: options.rowSpan || 1,
    margins: {
      top: options.padTop || 100,
      bottom: options.padBottom || 100,
      left: options.padLeft || 140,
      right: options.padRight || 140,
    },
    children: paragraphs,
  });
}

// Function to generate the identity header table
function createIdentityHeader() {
  return [
    p("LATIHAN PRAKTIKUM DECISION TABLE TESTING", {
      bold: true,
      size: 28, // 14pt
      alignment: AlignmentType.CENTER,
      spaceAfter: 200,
    }),
    new Table({
      width: { size: 100, type: WidthType.PERCENTAGE },
      rows: [
        new TableRow({
          children: [
            cell("Nama", { bold: true, width: 12, alignment: AlignmentType.LEFT }),
            cell([
              "- Kayla Fadh Suroso",
              "- Salsabila",
              "- Ega Restiyani",
              "- Ari Rahman",
              "- Siti Nayla Alikha Nisrina",
            ], { width: 38 }),
            cell("NIM", { bold: true, width: 12, alignment: AlignmentType.LEFT }),
            cell([
              "- J0403241034",
              "- J0403241059",
              "- J0403241061",
              "- J0403241143",
              "- J0403241162",
            ], { width: 38 }),
          ]
        }),
        new TableRow({
          children: [
            cell("Kelompok", { bold: true, width: 12 }),
            cell("E", { width: 38 }),
            cell("Tanggal", { bold: true, width: 12 }),
            cell("Kamis, 10 September 2026", { width: 38 }),
          ]
        })
      ]
    }),
    p("", { spaceAfter: 180 })
  ];
}

console.log("Setting up document structure...");

// ==========================================
// BUILD SECTION 1: KASUS COD (PAGES 1 - 7)
// ==========================================
const section1Elements = [
  ...createIdentityHeader(),

  sectionTitle("A. Tujuan Latihan"),
  p("Mahasiswa mampu menerjemahkan business rules menjadi conditions dan actions, menyusun complete decision table, mengidentifikasi Don't Care (–), melakukan simplification, serta menurunkan effective rules menjadi test cases."),

  sectionTitle("B. Kasus Latihan: Persetujuan Pesanan COD"),
  p("Sebuah aplikasi e-commerce menyediakan metode pembayaran Cash on Delivery (COD). Sistem menentukan apakah pesanan dapat diproses menggunakan COD berdasarkan tiga kondisi berikut:"),
  p("● Alamat pengiriman berada dalam wilayah layanan COD.", { spaceAfter: 40 }),
  p("● Nilai pesanan tidak melebihi batas maksimum COD.", { spaceAfter: 40 }),
  p("● Pelanggan tidak berstatus diblokir.", { spaceAfter: 80 }),
  p("Ketentuan bisnis yang mengatur proses persetujuan COD adalah sebagai berikut:"),
  p("● Jika pelanggan diblokir, pesanan COD ditolak tanpa mempertimbangkan kondisi lainnya.", { spaceAfter: 40 }),
  p("● Jika pelanggan tidak diblokir tetapi alamat di luar wilayah COD, pesanan COD ditolak.", { spaceAfter: 40 }),
  p("● Jika pelanggan tidak diblokir dan alamat terjangkau tetapi nilai pesanan melebihi batas COD, sistem meminta pelanggan memilih metode pembayaran lain.", { spaceAfter: 40 }),
  p("● Jika seluruh persyaratan terpenuhi, pesanan COD disetujui.", { spaceAfter: 120 }),

  sectionTitle("C. Langkah 1 . Identifikasi Business Rules"),
  p("Tuliskan kembali aturan bisnis dalam bentuk IF THEN yang lebih eksplisit."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("No.", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Business Rule (IF)", { bold: true, width: 52, shading: COLOR_HEADER_BG }),
          cell("Expected Action (THEN)", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("1", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF pelanggan diblokir (C3 = N)", { width: 52 }),
          cell("THEN pesanan COD ditolak, tanpa mempertimbangkan kondisi alamat dan nilai pesanan", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("2", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF pelanggan tidak diblokir (C3 = Y) AND alamat di luar wilayah COD (C1 = N)", { width: 52 }),
          cell("THEN pesanan COD ditolak", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("3", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF pelanggan tidak diblokir (C3 = Y) AND alamat berada dalam wilayah COD (C1 = Y) AND nilai pesanan melebihi batas maksimum (C2 = N)", { width: 52 }),
          cell("THEN sistem meminta pelanggan memilih metode pembayaran lain", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("4", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF pelanggan tidak diblokir (C3 = Y) AND alamat berada dalam wilayah COD (C1 = Y) AND nilai pesanan tidak melebihi batas maksimum (C2 = Y)", { width: 52 }),
          cell("THEN pesanan COD disetujui", { width: 40 }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("D. Langkah 2 . Identifikasi Conditions dan Actions"),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Conditions", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Actions", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("C1", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Alamat pengiriman berada dalam wilayah layanan COD", { width: 40 }),
          cell("A1", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pesanan COD disetujui", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C2", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Nilai pesanan tidak melebihi batas maksimum COD", { width: 40 }),
          cell("A2", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pesanan COD ditolak", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C3", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pelanggan tidak berstatus diblokir", { width: 40 }),
          cell("A3", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pelanggan diminta memilih metode pembayaran lain", { width: 40 }),
        ]
      }),
    ]
  }),
  p("Gunakan nilai Y = kondisi terpenuhi, N = kondisi tidak terpenuhi.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("E. Langkah 3 . Complete Decision Table"),
  p("Karena terdapat 3 conditions Boolean, buat seluruh 2³ = 8 kombinasi terlebih dahulu."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Elemen Decision Table", { bold: true, width: 36, shading: COLOR_HEADER_BG }),
          cell("R1", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R2", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R3", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R4", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R5", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R6", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R7", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R8", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("C1. Alamat berada dalam wilayah layanan COD", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C2. Nilai pesanan tidak melebihi batas maksimum COD", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C3. Pelanggan tidak berstatus diblokir", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A1. Pesanan COD disetujui", { bold: true, width: 36 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A2. Pesanan COD ditolak", { bold: true, width: 36 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A3. Pelanggan diminta memilih metode pembayaran lain", { bold: true, width: 36 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
    ]
  }),
  p("Petunjuk: isi baris condition dengan Y/N. Beri tanda X pada action yang diharapkan untuk setiap rule.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("F. Langkah 4. Analisis Rule dan Don't Care"),
  p("Periksa apakah ada condition yang tidak lagi memengaruhi keputusan pada rule tertentu. Gunakan simbol “-“ untuk Don't Care."),
  p([
    { text: "Penjelasan penyederhanaan: ", bold: true },
    { text: "Penyederhanaan decision table dilakukan dengan membandingkan beberapa rule yang memiliki action yang sama. Jika terdapat condition yang berbeda tetapi condition tersebut tidak memengaruhi keputusan akhir berdasarkan business rule, maka condition tersebut dapat diubah menjadi Don't Care (-). Dengan demikian, beberapa kombinasi rule yang memiliki hasil sama dapat digabung menjadi satu effective rule tanpa menghilangkan coverage." }
  ]),
  p("Pada kasus ini, terdapat dua penyederhanaan utama. Pertama, R2 dan R4 dapat digabung karena keduanya menghasilkan A2 (pesanan COD ditolak) dan sama-sama memiliki C1=Y dan C3=N, yang berarti pelanggan berada di dalam wilayah layanan COD dan berstatus diblokir. Berdasarkan business rule, pelanggan yang berada di dalam wilayah layanan COD tetapi berstatus diblokir langsung ditolak tanpa mempertimbangkan nilai pesanan, sehingga C2 dapat menjadi Don't Care (-). Kedua, R5, R6, R7, dan R8 dapat digabung karena semuanya memiliki C1=N, yaitu alamat berada di luar wilayah layanan COD, dan seluruhnya menghasilkan A2. Dalam kondisi tersebut, COD tetap ditolak tanpa mempertimbangkan nilai pesanan maupun status pelanggan. Oleh karena itu, C2 dan C3 dapat menjadi Don't Care (-). Sementara itu, R1 dan R3 tidak dapat digabung karena masing-masing menghasilkan action yang berbeda dan memiliki kondisi yang menentukan keputusan secara spesifik. R1 menghasilkan COD disetujui, sedangkan R3 meminta pelanggan memilih metode pembayaran lain."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Rule yang dibandingkan", { bold: true, width: 18, shading: COLOR_HEADER_BG }),
          cell("Condition yang berbeda", { bold: true, width: 18, shading: COLOR_HEADER_BG }),
          cell("Action sama?", { bold: true, width: 16, shading: COLOR_HEADER_BG }),
          cell("Dapat digabung? Alasan", { bold: true, width: 48, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("R2, R4", { bold: true, width: 18 }),
          cell("C2", { width: 18 }),
          cell("Ya, A2", { width: 16 }),
          cell("Dapat digabung, karena pada kedua rule pelanggan berstatus diblokir (C3=N), sehingga pesanan COD selalu ditolak tanpa mempertimbangkan nilai pesanan. Oleh karena itu, C2 menjadi Don't Care (-).", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R5, R6, R7, R8", { bold: true, width: 18 }),
          cell("C2, C3", { width: 18 }),
          cell("Ya, A2", { width: 16 }),
          cell("Dapat digabung, karena pada keempat rule alamat berada di luar wilayah layanan COD (C1=N), sehingga pesanan COD tetap ditolak tanpa mempertimbangkan nilai pesanan maupun status pelanggan. Oleh karena itu, C2 dan C3 menjadi Don't Care (-).", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R1 dengan R lainnya", { bold: true, width: 18 }),
          cell("-", { width: 18, alignment: AlignmentType.CENTER }),
          cell("Tidak", { width: 16 }),
          cell("Tidak dapat digabung, karena R1 menghasilkan A1 (COD disetujui), sedangkan rule lainnya tidak memiliki kondisi yang dapat digabung dengan R1 tanpa mengubah hasil yang seharusnya.", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R3 dengan R lainnya", { bold: true, width: 18 }),
          cell("-", { width: 18, alignment: AlignmentType.CENTER }),
          cell("Tidak", { width: 16 }),
          cell("Tidak dapat digabung, karena R3 menghasilkan A3 (memilih metode pembayaran lain), sehingga tidak memiliki rule lain dengan action yang sama dan kondisi yang dapat disederhanakan.", { width: 48 }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("G. Langkah 5 . Simplified Decision Table"),
  p("Gabungkan rules yang ekuivalen tanpa mengurangi coverage. Jumlah effective rules tidak harus sama dengan template baris di bawah."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Effective Rule", { bold: true, width: 22, shading: COLOR_HEADER_BG }),
          cell("C1", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C2", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C3", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Expected Action", { bold: true, width: 42, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER1", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A1. Pesanan COD disetujui", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER2", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A3. Minta pilih metode pembayaran lain", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER3", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A2. Pesanan COD ditolak.", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER4", { bold: true, width: 22 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A2. Pesanan COD ditolak", { width: 42 }),
        ]
      }),
    ]
  }),
  p("Catatan: simplification tidak boleh mengubah business rule atau menghilangkan kombinasi yang seharusnya tercakup.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("H. Langkah 6 . Derive Test Cases"),
  p("Turunkan setiap effective rule yang feasible menjadi minimal satu test case dengan data uji konkret."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Pre-condition", { bold: true, width: 24, shading: COLOR_HEADER_BG }),
          cell("Test Data / Steps", { bold: true, width: 34, shading: COLOR_HEADER_BG }),
          cell("Expected Output", { bold: true, width: 16, shading: COLOR_HEADER_BG }),
          cell("Actual Output", { bold: true, width: 10, shading: COLOR_HEADER_BG }),
          cell("Status", { bold: true, width: 6, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC01", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Pelanggan tidak berstatus diblokir", { width: 24 }),
          cell("Alamat: Jakarta (Dalam wilayah COD),\nTotal pesanan: Rp500.000 (⩽ Batas max COD);\nLanjutkan checkout menggunakan COD", { width: 34 }),
          cell("Pesanan COD disetujui", { width: 16 }),
          cell("Sesuai hasil eksekusi", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC02", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Pelanggan tidak berstatus diblokir", { width: 24 }),
          cell("Alamat: Jakarta (Dalam wilayah COD),\nTotal pesanan: Rp1.500.000 (> Batas max COD);\nLanjutkan checkout menggunakan COD", { width: 34 }),
          cell("Pelanggan diminta memilih metode pembayaran lain", { width: 16 }),
          cell("Sesuai hasil eksekusi", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC03", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Pelanggan tidak berstatus diblokir", { width: 24 }),
          cell("Alamat: Bandung (Luar wilayah COD),\nTotal pesanan: Rp500.000 (⩽ Batas max COD);\nLanjutkan checkout menggunakan COD", { width: 34 }),
          cell("Pesanan COD ditolak", { width: 16 }),
          cell("Sesuai hasil eksekusi", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC04", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Pelanggan berstatus diblokir", { width: 24 }),
          cell("Alamat: Jakarta (Dalam wilayah COD),\nTotal pesanan: Rp500.000 (⩽ Batas max COD);\nLanjutkan checkout menggunakan COD", { width: 34 }),
          cell("Pesanan COD ditolak", { width: 16 }),
          cell("Sesuai hasil eksekusi", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("I. Pertanyaan Analisis"),
  questionTitle(1, "Mengapa complete decision table pada kasus ini memiliki maksimum 8 rules?"),
  answerHeading(),
  p("Complete decision table pada kasus ini memiliki maksimum 8 rules karena terdapat 3 conditions Boolean, yaitu C1, C2, dan C3. Setiap condition memiliki dua kemungkinan nilai, yaitu Y (terpenuhi) dan N (tidak terpenuhi). Oleh karena itu, jumlah seluruh kemungkinan kombinasi dapat dihitung dengan rumus 2^n, dengan n adalah jumlah conditions. Karena terdapat 3 conditions, maka 2^3 = 8 kombinasi. Setiap kombinasi tersebut direpresentasikan sebagai satu rule pada complete decision table."),

  questionTitle(2, "Condition mana yang dapat menjadi Don't Care? Jelaskan berdasarkan business rule."),
  answerHeading(),
  p("Condition yang dapat menjadi Don't Care (-) adalah C2 dan C3 ketika C1 = N, karena jika pelanggan berada di luar wilayah layanan COD, pesanan COD langsung ditolak tanpa mempertimbangkan nilai pesanan maupun status pemblokiran. Selain itu, C2 dapat menjadi Don't Care ketika C3 = N dan C1 = Y, karena jika alamat berada di dalam wilayah COD tetapi pelanggan diblokir, pesanan tetap ditolak berapa pun nilai pesanannya. Dengan demikian, condition yang tidak memengaruhi keputusan pada rule tersebut dapat diganti dengan simbol “-“."),

  questionTitle(3, "Berapa effective rules setelah simplification? Mengapa jumlahnya dapat lebih sedikit dari 8?"),
  answerHeading(),
  p("Setelah dilakukan simplification, terdapat 4 effective rules. Jumlah tersebut lebih sedikit dari 8 karena beberapa kombinasi pada complete decision table menghasilkan action yang sama dan memiliki kondisi tertentu yang tidak memengaruhi keputusan. R2 dan R4 dapat digabung karena pelanggan yang diblokir selalu ditolak tanpa mempertimbangkan nilai pesanan. R5, R6, R7, dan R8 juga dapat digabung karena alamat yang berada di luar wilayah COD selalu menyebabkan penolakan tanpa mempertimbangkan nilai pesanan maupun status pelanggan. Dengan menggunakan Don't Care, beberapa kombinasi dapat direpresentasikan oleh satu effective rule."),

  questionTitle(4, "Apakah simplification mengurangi test coverage? Jelaskan."),
  answerHeading(),
  p("Tidak, selama simplification dilakukan dengan benar. Simplification hanya menggabungkan beberapa rule yang memiliki hasil yang sama dan mengubah condition yang tidak memengaruhi keputusan menjadi Don't Care. Seluruh kombinasi yang sebelumnya tercakup oleh complete decision table tetap direpresentasikan oleh effective rules. Pada kasus ini, 8 kombinasi awal disederhanakan menjadi 4 effective rules, kemudian masing-masing effective rule diturunkan menjadi minimal satu test case. Dengan demikian, coverage terhadap seluruh business rule tetap dipertahankan meskipun jumlah test case menjadi lebih sedikit."),

  questionTitle(5, "Jika salah satu condition berupa nilai numerik (misalnya batas maksimum COD), bagaimana BVA dapat dikombinasikan dengan Decision Table untuk memilih test data?"),
  answerHeading(),
  p("BVA dapat dikombinasikan dengan Decision Table dengan terlebih dahulu menggunakan Decision Table untuk menentukan kombinasi kondisi yang harus diuji, kemudian menggunakan BVA untuk memilih nilai konkret di sekitar boundary pada condition numerik. Misalnya batas maksimum COD adalah Rp1.000.000. Untuk condition C2, nilai yang dapat digunakan adalah nilai di bawah batas, tepat pada batas, dan di atas batas, seperti Rp999.999, Rp1.000.000, dan Rp1.000.001. Nilai tersebut kemudian digunakan pada rule yang dipengaruhi oleh C2, khususnya kondisi pelanggan tidak diblokir dan alamat berada dalam wilayah COD."),

  sectionTitle("J. Penerapan pada Proyek Kelompok"),
  p("Pilih satu fitur utama (bukan login) pada proyek kelompok yang memiliki minimal dua business conditions. Ulangi langkah C - H menggunakan requirement proyek masing-masing. Lampirkan: business rules, conditions/actions, complete decision table, simplified decision table (jika memungkinkan), test cases, serta hasil eksekusi PASS/FAIL."),

  // Page break to start Case 2
  new Paragraph({
    children: [new PageBreak()]
  }),
];

console.log("Section 1 built successfully. Now building Section 2: Real Web PTB...");

// =========================================================================
// BUILD SECTION 2: PENERAPAN PADA PROYEK KELOMPOK - WEB PTB (PAGES 8 - 13+)
// =========================================================================
const section2Elements = [
  ...createIdentityHeader(),

  sectionTitle("A. Tujuan Latihan"),
  p("Mahasiswa mampu menerjemahkan business rules menjadi conditions dan actions, menyusun complete decision table, mengidentifikasi Don't Care (–), melakukan simplification, serta menurunkan effective rules menjadi test cases pada fitur aplikasi riil yang sedang dikembangkan (Website Portal Penerimaan Tenaga Baru / PTB IPB)."),

  sectionTitle("B. Kasus Latihan: Web PTB (Fitur Upload Konten / Tambah Artikel)"),
  p("Website resmi Program Studi Pemuliaan Tanaman dan Teknologi Benih (PTB) IPB (https://ptb-ipb.freedev.app/) menyediakan portal informasi publik serta Content Management System (CMS) bagi Administrator program studi. Salah satu fitur utama di luar modul autentikasi adalah Fitur Upload Konten (Tambah Artikel) yang beralamat pada URL:"),
  p("https://ptb-ipb.freedev.app/upload.php?type=article", { italics: true, bold: true }),
  p("Fitur ini digunakan oleh admin untuk mempublikasikan artikel berita, rilis riset pemuliaan tanaman, atau pengumuman prodi. Formulir pengunggahan konten mengevaluasi kelayakan publikasi berdasarkan tiga kondisi input utama:"),
  p("● Field Judul (Title) diisi dengan teks judul yang valid (tidak kosong).", { spaceAfter: 40 }),
  p("● Field Deskripsi (Description) diisi dengan uraian/isi artikel yang valid (tidak kosong).", { spaceAfter: 40 }),
  p("● Field Berkas Thumbnail (File) diunggah dengan berkas gambar/dokumen yang valid (accept: image/*, application/pdf).", { spaceAfter: 80 }),
  p("Ketentuan bisnis dan aturan validasi form (Business Rules) yang diterapkan pada sistem adalah sebagai berikut:"),
  p("● Jika Judul tidak diisi, formulir secara otomatis menolak pengunggahan dan sistem menampilkan peringatan validasi pada input Judul, tanpa memproses field deskripsi maupun berkas thumbnail (fail-fast validation).", { spaceAfter: 40 }),
  p("● Jika Judul diisi namun Deskripsi tidak diisi, sistem menolak pengunggahan dan menampilkan peringatan validasi pada field Deskripsi, tanpa mempertimbangkan apakah berkas thumbnail telah dipilih atau belum.", { spaceAfter: 40 }),
  p("● Jika Judul dan Deskripsi diisi namun Berkas Thumbnail belum diunggah, sistem menolak pengunggahan dan meminta admin melampirkan berkas thumbnail/dokumen pendukung.", { spaceAfter: 40 }),
  p("● Jika seluruh persyaratan terpenuhi (Judul diisi, Deskripsi diisi, dan Berkas Thumbnail diunggah), formulir berhasil dikirimkan ke endpoint backend (upload_process.php), data tersimpan ke database, dan sistem mengarahkan (redirect) admin ke halaman daftar artikel (artikel.php) dengan status artikel baru terbit.", { spaceAfter: 120 }),

  sectionTitle("C. Langkah 1 . Identifikasi Business Rules"),
  p("Tuliskan kembali aturan bisnis dalam bentuk IF THEN yang lebih eksplisit."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("No.", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Business Rule (IF)", { bold: true, width: 52, shading: COLOR_HEADER_BG }),
          cell("Expected Action (THEN)", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("1", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF Judul artikel kosong / tidak diisi (C1 = N)", { width: 52 }),
          cell("THEN pengunggahan ditolak dan sistem menampilkan pesan validasi error pada field Judul, tanpa mengevaluasi kondisi Deskripsi dan Berkas Thumbnail", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("2", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF Judul artikel diisi (C1 = Y) AND Deskripsi artikel kosong / tidak diisi (C2 = N)", { width: 52 }),
          cell("THEN pengunggahan ditolak dan sistem menampilkan pesan validasi error pada field Deskripsi, tanpa mempertimbangkan kondisi Berkas Thumbnail", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("3", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF Judul artikel diisi (C1 = Y) AND Deskripsi artikel diisi (C2 = Y) AND Berkas Thumbnail tidak diunggah (C3 = N)", { width: 52 }),
          cell("THEN pengunggahan ditolak dan sistem menampilkan pesan validasi untuk melampirkan berkas thumbnail", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("4", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("IF Judul artikel diisi (C1 = Y) AND Deskripsi artikel diisi (C2 = Y) AND Berkas Thumbnail diunggah secara valid (C3 = Y)", { width: 52 }),
          cell("THEN pengunggahan disetujui, artikel tersimpan ke database, dan sistem me-redirect admin ke halaman daftar artikel (artikel.php)", { width: 40 }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("D. Langkah 2 . Identifikasi Conditions dan Actions"),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Conditions", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Actions", { bold: true, width: 40, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("C1", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Judul artikel diisi (tidak kosong)", { width: 40 }),
          cell("A1", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pengunggahan disetujui & artikel dipublikasikan (Redirect ke artikel.php)", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C2", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Deskripsi artikel diisi (tidak kosong)", { width: 40 }),
          cell("A2", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pengunggahan ditolak, sistem menampilkan validasi error field teks wajib diisi", { width: 40 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C3", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Berkas thumbnail/dokumen diunggah", { width: 40 }),
          cell("A3", { alignment: AlignmentType.CENTER, bold: true, width: 10 }),
          cell("Pengunggahan ditolak, sistem meminta pengguna melampirkan berkas thumbnail", { width: 40 }),
        ]
      }),
    ]
  }),
  p("Gunakan nilai Y = kondisi terpenuhi, N = kondisi tidak terpenuhi.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("E. Langkah 3 . Complete Decision Table"),
  p("Karena terdapat 3 conditions Boolean, buat seluruh 2³ = 8 kombinasi terlebih dahulu."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Elemen Decision Table", { bold: true, width: 36, shading: COLOR_HEADER_BG }),
          cell("R1", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R2", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R3", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R4", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R5", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R6", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R7", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("R8", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("C1. Judul artikel diisi", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C2. Deskripsi artikel diisi", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("C3. Berkas thumbnail diunggah", { width: 36 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A1. Pengunggahan disetujui & artikel dipublikasikan", { bold: true, width: 36 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A2. Pengunggahan ditolak (validasi input teks)", { bold: true, width: 36 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
      new TableRow({
        children: [
          cell("A3. Pengunggahan ditolak (validasi berkas thumbnail)", { bold: true, width: 36 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("X", { bold: true, alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
          cell("", { alignment: AlignmentType.CENTER, width: 8 }),
        ]
      }),
    ]
  }),
  p("Petunjuk: isi baris condition dengan Y/N. Beri tanda X pada action yang diharapkan untuk setiap rule.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("F. Langkah 4. Analisis Rule dan Don't Care"),
  p("Periksa apakah ada condition yang tidak lagi memengaruhi keputusan pada rule tertentu. Gunakan simbol “-“ untuk Don't Care."),
  p([
    { text: "Penjelasan penyederhanaan: ", bold: true },
    { text: "Penyederhanaan decision table dilakukan dengan membandingkan beberapa rule yang memiliki action yang sama. Jika terdapat condition yang berbeda tetapi condition tersebut tidak memengaruhi keputusan akhir berdasarkan business rule dan alur validasi aplikasi web (fail-fast validation), maka condition tersebut dapat diubah menjadi Don't Care (-). Dengan demikian, beberapa kombinasi rule yang memiliki hasil sama dapat digabung menjadi satu effective rule tanpa menghilangkan test coverage." }
  ]),
  p("Pada kasus pengujian Web PTB ini, terdapat dua penyederhanaan utama:"),
  p("Pertama, R3 dan R4 dapat digabung karena keduanya menghasilkan Action A2 (pengunggahan ditolak akibat validasi input teks) dan sama-sama memiliki kondisi C1=Y serta C2=N, yang berarti admin telah mengisi Judul namun mengosongkan Deskripsi. Berdasarkan alur evaluasi form web secara berurutan (top-to-bottom fail-fast evaluation), ketika field Deskripsi belum terisi, sistem langsung menghentikan proses pengiriman formulir dan memfokuskan validasi pada field Deskripsi dengan pesan wajib diisi. Pada titik ini, apakah berkas thumbnail diunggah (C3=Y) atau tidak diunggah (C3=N) tidak lagi memengaruhi keputusan penolakan. Oleh karena itu, C3 dapat disederhanakan menjadi Don't Care (-)."),
  p("Kedua, R5, R6, R7, dan R8 dapat digabung karena seluruhnya memiliki C1=N, yaitu field Judul tidak diisi oleh pengguna, dan seluruhnya menghasilkan Action A2. Berdasarkan prinsip validasi formulir web, Judul merupakan field masukan urutan pertama. Ketika field Judul kosong, eksekusi validasi form langsung membatalkan request HTTP POST dan menahan kursor pengguna pada field Judul. Dalam kondisi kegagalan pada tahap awal ini, sistem tidak akan memeriksa apakah field Deskripsi diisi (C2) maupun apakah Berkas Thumbnail telah dipilih (C3). Dengan demikian, kondisi C2 dan C3 sama sekali tidak relevan terhadap luaran keputusan akhir dan dapat diubah menjadi Don't Care (-)."),
  p("Sementara itu, aturan R1 dan R2 tidak dapat digabung. R1 menghasilkan Action A1 (pengunggahan disetujui dan diarahkan ke halaman artikel.php) karena seluruh kondisi C1=Y, C2=Y, dan C3=Y terpenuhi. Sedangkan R2 menghasilkan Action A3 (pengunggahan ditolak khusus karena berkas thumbnail belum dilampirkan) dengan kondisi C1=Y, C2=Y, C3=N. Karena masing-masing menghasilkan action yang berbeda dan memiliki kombinasi kondisi yang menentukan alur keputusan secara spesifik, R1 dan R2 harus tetap dipertahankan sebagai rule yang terpisah."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Rule yang dibandingkan", { bold: true, width: 18, shading: COLOR_HEADER_BG }),
          cell("Condition yang berbeda", { bold: true, width: 18, shading: COLOR_HEADER_BG }),
          cell("Action sama?", { bold: true, width: 16, shading: COLOR_HEADER_BG }),
          cell("Dapat digabung? Alasan", { bold: true, width: 48, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("R3, R4", { bold: true, width: 18 }),
          cell("C3", { width: 18 }),
          cell("Ya, A2", { width: 16 }),
          cell("Dapat digabung, karena pada kedua rule Judul telah diisi (C1=Y) namun Deskripsi kosong (C2=N). Sistem langsung menghentikan proses submit pada field Deskripsi tanpa memedulikan keberadaan berkas thumbnail. Oleh karena itu, C3 menjadi Don't Care (-).", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R5, R6, R7, R8", { bold: true, width: 18 }),
          cell("C2, C3", { width: 18 }),
          cell("Ya, A2", { width: 16 }),
          cell("Dapat digabung, karena pada keempat rule field Judul tidak diisi (C1=N). Berdasarkan validasi urutan form (fail-fast), sistem langsung menolak proses submit pada field Judul tanpa mengevaluasi Deskripsi maupun Thumbnail. Oleh karena itu, C2 dan C3 menjadi Don't Care (-).", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R1 dengan R lainnya", { bold: true, width: 18 }),
          cell("-", { width: 18, alignment: AlignmentType.CENTER }),
          cell("Tidak", { width: 16 }),
          cell("Tidak dapat digabung, karena R1 adalah satu-satunya kombinasi yang menghasilkan A1 (Pengunggahan artikel disetujui & berhasil dipublikasikan), sehingga tidak memiliki rule lain dengan action yang sama.", { width: 48 }),
        ]
      }),
      new TableRow({
        children: [
          cell("R2 dengan R lainnya", { bold: true, width: 18 }),
          cell("-", { width: 18, alignment: AlignmentType.CENTER }),
          cell("Tidak", { width: 16 }),
          cell("Tidak dapat digabung, karena R2 menghasilkan A3 (Pengunggahan ditolak khusus karena berkas thumbnail belum dilampirkan), sehingga memiliki action yang berbeda dari rule kegagalan lainnya.", { width: 48 }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("G. Langkah 5 . Simplified Decision Table"),
  p("Gabungkan rules yang ekuivalen tanpa mengurangi coverage. Jumlah effective rules tidak harus sama dengan template baris di bawah."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Effective Rule", { bold: true, width: 22, shading: COLOR_HEADER_BG }),
          cell("C1", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C2", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C3", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Expected Action", { bold: true, width: 42, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER1", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A1. Pengunggahan disetujui & artikel dipublikasikan", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER2", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A3. Pengunggahan ditolak (validasi berkas thumbnail)", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER3", { bold: true, width: 22 }),
          cell("Y", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A2. Pengunggahan ditolak (validasi deskripsi)", { width: 42 }),
        ]
      }),
      new TableRow({
        children: [
          cell("ER4", { bold: true, width: 22 }),
          cell("N", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("-", { alignment: AlignmentType.CENTER, width: 12 }),
          cell("A2. Pengunggahan ditolak (validasi judul)", { width: 42 }),
        ]
      }),
    ]
  }),
  p("Catatan: simplification tidak boleh mengubah business rule atau menghilangkan kombinasi yang seharusnya tercakup.", { italics: true, size: 22, spaceBefore: 60, spaceAfter: 120 }),

  sectionTitle("H. Langkah 6 . Derive Test Cases"),
  p("Turunkan setiap effective rule yang feasible menjadi minimal satu test case dengan data uji konkret."),
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("ID", { bold: true, width: 10, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Pre-condition", { bold: true, width: 24, shading: COLOR_HEADER_BG }),
          cell("Test Data / Steps", { bold: true, width: 34, shading: COLOR_HEADER_BG }),
          cell("Expected Output", { bold: true, width: 16, shading: COLOR_HEADER_BG }),
          cell("Actual Output", { bold: true, width: 10, shading: COLOR_HEADER_BG }),
          cell("Status", { bold: true, width: 6, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC01", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Admin telah login ke dashboard PTB (undang@ptb.ac.id) dan berada di halaman upload.php?type=article", { width: 24 }),
          cell("Judul: 'Inovasi Pemuliaan Padi Tahan Hama Wereng IPB';\nDeskripsi: 'Program studi PTB IPB meluncurkan galur benih unggul dengan ketahanan tinggi';\nBerkas: sample_thumbnail.png (valid);\nKlik tombol 'Kirim Konten'", { width: 34 }),
          cell("Pengunggahan disetujui, artikel tersimpan ke database, dialihkan ke artikel.php", { width: 16 }),
          cell("Sesuai hasil eksekusi (Redirect ke artikel.php)", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC02", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Admin telah login ke dashboard PTB (undang@ptb.ac.id) dan berada di halaman upload.php?type=article", { width: 24 }),
          cell("Judul: 'Uji Multilokasi Benih Jagung Hibrida PTB';\nDeskripsi: 'Pelaksanaan riset daya hasil di lahan percobaan Sawah Baru IPB';\nBerkas: (Kosong / tidak diunggah);\nKlik tombol 'Kirim Konten'", { width: 34 }),
          cell("Pengunggahan ditolak, muncul notifikasi validasi 'Please select a file' pada input file, tetap di upload.php", { width: 16 }),
          cell("Sesuai hasil eksekusi (Submit dibatalkan, tooltip validasi muncul)", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC03", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Admin telah login ke dashboard PTB (undang@ptb.ac.id) dan berada di halaman upload.php?type=article", { width: 24 }),
          cell("Judul: 'Workshop Kultur Jaringan dan Bioteknologi Benih';\nDeskripsi: '' (Kosong);\nBerkas: sample_thumbnail.png (terpilih);\nKlik tombol 'Kirim Konten'", { width: 34 }),
          cell("Pengunggahan ditolak, muncul peringatan validasi 'Please fill out this field' pada textarea deskripsi, tetap di upload.php", { width: 16 }),
          cell("Sesuai hasil eksekusi (Submit dibatalkan, kursor tertahan pada deskripsi)", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("TC04", { bold: true, width: 10, alignment: AlignmentType.CENTER }),
          cell("Admin telah login ke dashboard PTB (undang@ptb.ac.id) dan berada di halaman upload.php?type=article", { width: 24 }),
          cell("Judul: '' (Kosong);\nDeskripsi: 'Penjelasan konten sudah disiapkan lengkap oleh admin';\nBerkas: sample_thumbnail.png;\nKlik tombol 'Kirim Konten'", { width: 34 }),
          cell("Pengunggahan ditolak, proses langsung dihentikan pada input Judul dengan peringatan 'Please fill out this field', tetap di upload.php", { width: 16 }),
          cell("Sesuai hasil eksekusi (Submit dibatalkan, kursor fokus pada input judul)", { width: 10 }),
          cell("PASS", { bold: true, width: 6, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),

  sectionTitle("I. Pertanyaan Analisis"),
  questionTitle(1, "Mengapa complete decision table pada kasus pengujian Web PTB ini memiliki maksimum 8 rules?"),
  answerHeading(),
  p("Complete decision table pada kasus pengujian fitur Upload Konten Web PTB memiliki maksimum 8 rules karena sistem mengevaluasi 3 kondisi input (conditions) bertipe Boolean, yaitu: C1 (Judul artikel diisi), C2 (Deskripsi artikel diisi), dan C3 (Berkas thumbnail diunggah). Setiap kondisi memiliki tepat 2 kemungkinan status logika, yaitu Y (Yes / True / Terpenuhi) dan N (No / False / Tidak terpenuhi)."),
  p("Berdasarkan prinsip matematika kombinatorika dalam pengujian perangkat lunak, ruang kemungkinan kombinasi keputusan dihitung menggunakan formula:"),
  p("Jumlah Kombinasi (Rules) = 2^n = 2^3 = 8 rules", { bold: true, alignment: AlignmentType.CENTER }),
  p("di mana n merepresentasikan jumlah conditions Boolean yang independen. Oleh karena itu, terdapat tepat 8 kombinasi aturan logika (R1 sampai R8). Setiap kombinasi aturan mewakili satu skenario masukan pengguna yang unik pada formulir upload konten, sehingga menjamin bahwa seluruh ruang keadaan (state space) input telah didefinisikan secara lengkap tanpa ada kombinasi yang tertinggal."),

  questionTitle(2, "Condition mana yang dapat menjadi Don't Care? Jelaskan berdasarkan business rule dan arsitektur validasi form web."),
  answerHeading(),
  p("Condition yang dapat menjadi Don't Care (-) pada kasus pengujian Web PTB ini adalah:"),
  p("a. Kondisi C2 (Deskripsi) dan C3 (Thumbnail) dapat menjadi Don't Care (-) ketika C1 = N (Judul kosong). Berdasarkan business rule dan mekanisme validasi form web (fail-fast validation berbasis DOM), atribut 'required' pada field Judul bertindak sebagai penjaga gerbang pertama. Saat form disubmit dan Judul dalam kondisi kosong, browser serta handler validasi langsung membatalkan pengiriman HTTP POST dan menahan kursor pengguna pada field Judul. Dalam kondisi ini, sistem tidak akan memeriksa apakah field Deskripsi sudah diisi atau belum, serta tidak memvalidasi keberadaan berkas thumbnail. Hasil akhirnya tetap sama, yaitu pengunggahan ditolak (Action A2). Oleh karena itu, status C2 dan C3 tidak lagi memengaruhi keputusan akhir.", { spaceAfter: 60 }),
  p("b. Kondisi C3 (Thumbnail) dapat menjadi Don't Care (-) ketika C1 = Y (Judul diisi) dan C2 = N (Deskripsi kosong). Jika Judul telah valid namun field Deskripsi diabaikan oleh pengguna, sistem validasi akan menghentikan proses submit pada elemen textarea Deskripsi. Pengguna diwajibkan melengkapi konten teks terlebih dahulu sebelum proses berlanjut ke pemeriksaan berkas thumbnail. Dengan demikian, status ada atau tidaknya berkas thumbnail (C3) pada kondisi ini tidak memengaruhi luaran penolakan form, sehingga C3 menjadi Don't Care (-).", { spaceAfter: 120 }),

  questionTitle(3, "Berapa effective rules setelah simplification? Mengapa jumlahnya dapat lebih sedikit dari 8?"),
  answerHeading(),
  p("Setelah dilakukan proses penyederhanaan (simplification), jumlah aturan berkurang dari 8 complete rules menjadi 4 effective rules (ER1, ER2, ER3, dan ER4)."),
  p("Jumlah effective rules dapat berkurang secara signifikan karena beberapa kombinasi aturan pada complete decision table menghasilkan expected action yang identik (yaitu Action A2: penolakan form dan pemunculan error validasi teks) serta dipicu oleh kondisi kegagalan pada tahapan yang lebih awal. Rincian penggabungan aturan adalah sebagai berikut:"),
  p("1. Aturan R5, R6, R7, dan R8 memiliki nilai kondisi C1 = N dan seluruhnya menghasilkan Action A2. Karena C2 dan C3 adalah Don't Care (-), keempat aturan ini dilebur menjadi satu aturan efektif ER4 (N - - -> A2)."),
  p("2. Aturan R3 dan R4 memiliki nilai kondisi C1 = Y, C2 = N dan keduanya menghasilkan Action A2. Karena C3 adalah Don't Care (-), kedua aturan ini dilebur menjadi satu aturan efektif ER3 (Y N - -> A2)."),
  p("Penerapan simbol Don't Care (-) memungkinkan tim penguji mengeliminasi redundansi pengujian tanpa mengubah logika bisnis, sehingga pengujian menjadi jauh lebih fokus, terstruktur, dan efisien."),

  questionTitle(4, "Apakah simplification mengurangi test coverage? Jelaskan."),
  answerHeading(),
  p("Tidak, simplification sama sekali tidak mengurangi test coverage selama proses penyederhanaan dilakukan secara valid dan matematis."),
  p("Penjelasan teknisnya mencakup tiga poin fundamental:"),
  p("a. Representasi Logika Tetap 100%: Penggabungan aturan hanya dilakukan pada rules yang memiliki luaran (action) yang sama dan dihubungkan oleh kondisi yang terbukti tidak memengaruhi keputusan. Dalam effective rules, simbol '-' (Don't Care) secara implisit mencakup seluruh permutasi biner di baliknya:"),
  p("   • ER1 (Y Y Y) merepresentasikan 1 aturan biner (R1).", { spaceAfter: 30 }),
  p("   • ER2 (Y Y N) merepresentasikan 1 aturan biner (R2).", { spaceAfter: 30 }),
  p("   • ER3 (Y N -) merepresentasikan 2 aturan biner (R3 dan R4, karena 2^1 = 2).", { spaceAfter: 30 }),
  p("   • ER4 (N - -) merepresentasikan 4 aturan biner (R5, R6, R7, dan R8, karena 2^2 = 4).", { spaceAfter: 30 }),
  p("   Total cakupan kombinasi: 1 + 1 + 2 + 4 = 8 kombinasi (100% complete logic coverage)."),
  p("b. Menghindari Uji Berlebih (Over-Testing): Menguji kombinasi di mana field pertama kosong dan field ketiga diisi atau dikosongkan secara terpisah akan menghasilkan perilaku sistem yang sama persis (kursor tertahan di field pertama). Oleh karena itu, simplifikasi menghilangkan eksekusi berulang yang tidak memberikan nilai uji tambah."),
  p("c. Efisiensi Eksekusi (Test Optimization): Dengan 4 effective rules, tim QA dapat memvalidasi seluruh jalur keputusan sistem (decision paths) dengan efisiensi waktu 50% lebih cepat tanpa ada risiko celah kecacatan (defect escape)."),

  questionTitle(5, "Jika salah satu condition berupa nilai numerik (misalnya batas ukuran file thumbnail atau batas panjang karakter judul), bagaimana BVA dapat dikombinasikan dengan Decision Table untuk memilih test data?"),
  answerHeading(),
  p("Boundary Value Analysis (BVA) dapat dikombinasikan secara sinergis dengan Decision Table Testing melalui pendekatan Hybrid Black-Box Testing Method:"),
  p("1. Decision Table Berperan pada Level Makro (Decision Logic): Decision Table digunakan terlebih dahulu untuk menentukan kombinasi logika dan skenario cabang yang harus diuji (kapan sistem harus menerima atau menolak input berdasarkan kelengkapan kondisi)."),
  p("2. BVA Berperan pada Level Mikro (Test Data Selection): Untuk setiap kondisi yang memiliki batasan numerik atau rentang nilai (boundary constraints), BVA digunakan untuk memilih nilai uji konkret tepat di sekitar batas ambang (boundary points), yaitu: nilai tepat pada batas (boundary), tepat di bawah batas (just below boundary), dan tepat di atas batas (just above boundary)."),
  p("Penerapan konkret pada fitur Upload Konten Web PTB:"),
  p("• Batasan Ukuran Berkas Thumbnail (Misal: Maksimum 2 MB = 2.048 KB):", { bold: true }),
  p("  - Nilai Uji Valid (C3 = Y): Berkas gambar berukuran 2.047 KB (just below) dan 2.048 KB (exact maximum boundary)."),
  p("  - Nilai Uji Tidak Valid (C3 = N): Berkas berukuran 2.049 KB (just above maximum boundary, sistem harus menolak dan memunculkan pesan file terlalu besar) serta berkas berukuran 0 KB (empty file)."),
  p("• Batasan Panjang Karakter Judul Artikel (Misal: Minimum 5 karakter, Maksimum 150 karakter):", { bold: true }),
  p("  - Nilai Uji Batas Bawah: 4 karakter (invalid / C1=N), 5 karakter (valid / C1=Y)."),
  p("  - Nilai Uji Batas Atas: 150 karakter (valid / C1=Y), 151 karakter (invalid / C1=N)."),
  p("Kombinasi kedua teknik ini memberikan jaminan mutu pengujian tertinggi: Decision Table memastikan kelengkapan logika keputusan, sedangkan BVA memastikan ketahanan sistem terhadap galat pemrograman di titik-titik kritis batas (off-by-one errors)."),

  sectionTitle("J. Lampiran: Bukti Eksekusi Pengujian Otomatis (Automated Playwright Execution Evidence)"),
  p("Sebagai bukti validitas dan kepastian bahwa pengujian telah dilakukan secara nyata pada website PTB IPB (https://ptb-ipb.freedev.app/), seluruh 8 kombinasi complete decision table telah dieksekusi secara otomatis menggunakan Playwright Automation Suite pada lingkungan Node.js dengan browser engine Chromium Headless."),
  
  new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [
      new TableRow({
        children: [
          cell("Rule", { bold: true, width: 8, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C1 (Judul)", { bold: true, width: 14, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C2 (Deskripsi)", { bold: true, width: 14, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("C3 (Thumbnail)", { bold: true, width: 14, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
          cell("Expected Output", { bold: true, width: 16, shading: COLOR_HEADER_BG }),
          cell("Actual Output (Playwright)", { bold: true, width: 22, shading: COLOR_HEADER_BG }),
          cell("Status", { bold: true, width: 12, alignment: AlignmentType.CENTER, shading: COLOR_HEADER_BG }),
        ]
      }),
      new TableRow({
        children: [
          cell("R1", { bold: true, alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("Y (Diunggah)", { alignment: AlignmentType.CENTER }),
          cell("Success (Redirect artikel.php)", {}),
          cell("Redirect ke artikel.php, artikel tersimpan", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R2", { bold: true, alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi File", {}),
          cell("Submit tertahan di upload.php, tooltip muncul", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R3", { bold: true, alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Y (Diunggah)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Deskripsi", {}),
          cell("Submit tertahan di upload.php, fokus deskripsi", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R4", { bold: true, alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Deskripsi", {}),
          cell("Submit tertahan di upload.php, fokus deskripsi", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R5", { bold: true, alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("Y (Diunggah)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Judul", {}),
          cell("Submit tertahan di upload.php, fokus judul", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R6", { bold: true, alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Y (Terisi)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Judul", {}),
          cell("Submit tertahan di upload.php, fokus judul", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R7", { bold: true, alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Y (Diunggah)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Judul", {}),
          cell("Submit tertahan di upload.php, fokus judul", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
      new TableRow({
        children: [
          cell("R8", { bold: true, alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("N (Kosong)", { alignment: AlignmentType.CENTER }),
          cell("Error / Validasi Judul", {}),
          cell("Submit tertahan di upload.php, fokus judul", {}),
          cell("PASS", { bold: true, alignment: AlignmentType.CENTER, color: COLOR_PASS }),
        ]
      }),
    ]
  }),
  p("", { spaceAfter: 120 }),
  p("Tingkat Kelulusan Uji (Test Pass Rate): 8 dari 8 Rules PASS (100%). Seluruh perilaku sistem sesuai dengan ekspektasi business logic dan aturan perancangan Decision Table.", { bold: true, italics: true, color: COLOR_PASS }),
];

// Add screenshots into the document if available
const decisionTableDir = path.join(__dirname, '..', 'doc_assets', 'decision_table');
const screenshotFiles = [
  { file: 'rule1_filled.png', label: 'Gambar 1: Form Upload Terisi Lengkap (Rule 1 / ER1 - C1=Y, C2=Y, C3=Y)' },
  { file: 'rule1_result.png', label: 'Gambar 2: Pengunggahan Berhasil & Dialihkan ke Daftar Artikel (Rule 1 / ER1 Result)' },
  { file: 'rule2_filled.png', label: 'Gambar 3: Form Diisi Tanpa Berkas Thumbnail (Rule 2 / ER2 - C1=Y, C2=Y, C3=N)' },
  { file: 'rule3_filled.png', label: 'Gambar 4: Form Diisi Tanpa Deskripsi (Rule 3 / ER3 - C1=Y, C2=N, C3=Y)' },
  { file: 'rule5_filled.png', label: 'Gambar 5: Form Diisi Tanpa Judul (Rule 5 / ER4 - C1=N, C2=Y, C3=Y)' },
];

const screenshotElements = [
  p("", { spaceAfter: 100 }),
  p("Dokumentasi Tangkapan Layar Eksekusi Uji:", { bold: true, size: 24 }),
];

for (const sc of screenshotFiles) {
  const fullPath = path.join(decisionTableDir, sc.file);
  if (fs.existsSync(fullPath)) {
    try {
      const imgBuffer = fs.readFileSync(fullPath);
      screenshotElements.push(
        new Paragraph({
          alignment: AlignmentType.CENTER,
          spacing: { before: 120, after: 60 },
          children: [
            new ImageRun({
              data: imgBuffer,
              transformation: {
                width: 520,
                height: 280
              }
            })
          ]
        }),
        p(sc.label, {
          alignment: AlignmentType.CENTER,
          italics: true,
          size: 20,
          spaceAfter: 160
        })
      );
    } catch (e) {
      console.log(`Could not add image ${sc.file}:`, e.message);
    }
  }
}

section2Elements.push(...screenshotElements);

// Create the complete Document
const doc = new Document({
  sections: [
    {
      properties: {
        page: {
          margin: {
            top: 1440, // 1 inch
            bottom: 1440,
            left: 1440,
            right: 1440,
          }
        }
      },
      headers: {
        default: new Header({
          children: [
            new Paragraph({
              alignment: AlignmentType.RIGHT,
              children: [
                new TextRun({
                  text: "Praktikum Testing - Decision Table Testing | Kelompok E",
                  font: FONT_FAMILY,
                  size: 18,
                  italics: true,
                  color: "777777",
                })
              ]
            })
          ]
        })
      },
      footers: {
        default: new Footer({
          children: [
            new Paragraph({
              alignment: AlignmentType.CENTER,
              children: [
                new TextRun({
                  text: "Halaman ",
                  font: FONT_FAMILY,
                  size: 20,
                  color: "555555",
                }),
                new TextRun({
                  children: [PageNumber.CURRENT],
                  font: FONT_FAMILY,
                  size: 20,
                  color: "555555",
                }),
                new TextRun({
                  text: " dari ",
                  font: FONT_FAMILY,
                  size: 20,
                  color: "555555",
                }),
                new TextRun({
                  children: [PageNumber.TOTAL_PAGES],
                  font: FONT_FAMILY,
                  size: 20,
                  color: "555555",
                }),
              ]
            })
          ]
        })
      },
      children: [
        ...section1Elements,
        ...section2Elements,
      ]
    }
  ]
});

const outputPath = path.join(__dirname, 'TUGAS_PRAKTIKUM_DECISION_TABLE_KELOMPOK_E.docx');
console.log("Generating buffer and packing document to:", outputPath);

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(outputPath, buffer);
  console.log("SUCCESS! Document generated successfully:", outputPath);
  console.log("File size:", (buffer.length / 1024).toFixed(2), "KB");
}).catch(err => {
  console.error("Error generating document:", err);
});
