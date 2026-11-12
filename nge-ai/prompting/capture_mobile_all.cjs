const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const OUT_DIR = path.resolve(__dirname, 'doc_assets');
if (!fs.existsSync(OUT_DIR)) {
  fs.mkdirSync(OUT_DIR, { recursive: true });
}

const pagesToCapture = [
  { name: 'mobile_01_login.png', view: 'login', label: '1. Login Civitas' },
  { name: 'mobile_02_daftar.png', view: 'daftar', label: '2. Registrasi Akun Civitas' },
  { name: 'mobile_03_beranda.png', view: 'beranda', label: '3. Beranda / Feed Barang Hilang' },
  { name: 'mobile_04_notifikasi.png', view: 'notifikasi', label: '4. Pusat Notifikasi' },
  { name: 'mobile_05_buat_laporan.png', view: 'buat_laporan', label: '5. Formulir Buat Laporan' },
  { name: 'mobile_06_pesan_chat.png', view: 'chat', label: '6. Pesan / Chat Masuk' },
  { name: 'mobile_07_profil.png', view: 'profil', label: '7. Profil Pengguna & Riwayat Laporan' },
];

async function captureAll() {
  console.log('Starting Playwright Mobile Capture...');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });
  const page = await context.newPage();

  for (const item of pagesToCapture) {
    console.log(`Capturing ${item.label}...`);
    const url = `http://localhost:8085/?view=${item.view}`;
    await page.goto(url, { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(4500);
    const dest = path.join(OUT_DIR, item.name);
    await page.screenshot({ path: dest });
    console.log(`Saved: ${item.name} (${fs.statSync(dest).size} bytes)`);
  }

  await browser.close();
  console.log('All mobile screenshots captured successfully!');
}

captureAll().catch(err => {
  console.error('Error capturing mobile screenshots:', err);
  process.exit(1);
});
