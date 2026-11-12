const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const OUT_DIR = path.resolve(__dirname, 'doc_assets');
if (!fs.existsSync(OUT_DIR)) {
  fs.mkdirSync(OUT_DIR, { recursive: true });
}

const WEB_BASE = 'https://web-admincampus-lapor-production-3cd2.up.railway.app';
const MOBILE_BASE = 'http://localhost:8085';

async function captureWeb() {
  console.log('=== Capturing Web (Desktop Viewport: 1440x900) ===');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1.5,
  });
  const page = await context.newPage();

  // 1. Web Login
  console.log('1. Navigating to Web Login...');
  await page.goto(`${WEB_BASE}/login`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_01_login.png') });

  // 2. Web Daftar Admin
  console.log('2. Navigating to Daftar Admin...');
  await page.goto(`${WEB_BASE}/daftar-admin`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_02_daftar_admin.png') });

  // 3. Login as Admin
  console.log('3. Logging in as Admin (admin1)...');
  await page.goto(`${WEB_BASE}/login`, { waitUntil: 'networkidle' });
  await page.fill('#username', 'admin1');
  await page.fill('#password', 'admin123');
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle' }).catch(() => {}),
    page.click('.login-submit'),
  ]);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_03_dashboard_admin.png') });

  // 4. Barang Hilang
  console.log('4. Navigating to Barang Hilang...');
  await page.goto(`${WEB_BASE}/barang-hilang`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_04_barang_hilang.png') });

  // 5. Fasilitas Rusak
  console.log('5. Navigating to Fasilitas Rusak...');
  await page.goto(`${WEB_BASE}/fasilitas-rusak`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_05_fasilitas_rusak.png') });

  // 6. Pesan / Chat
  console.log('6. Navigating to Pesan / Chat...');
  await page.goto(`${WEB_BASE}/pesan`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_06_pesan_chat.png') });

  // 7. Manajemen Kampus
  console.log('7. Navigating to Manajemen Kampus...');
  await page.goto(`${WEB_BASE}/manajemen-kampus`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_07_manajemen_kampus.png') });

  // Logout admin
  console.log('Logging out admin...');
  await page.goto(`${WEB_BASE}/login`, { waitUntil: 'networkidle' });

  // 8. Login as Superadmin
  console.log('8. Logging in as Superadmin (superadmin1)...');
  await page.fill('#username', 'superadmin1');
  await page.fill('#password', 'superadmin123');
  await Promise.all([
    page.waitForNavigation({ waitUntil: 'networkidle' }).catch(() => {}),
    page.click('.login-submit'),
  ]);
  await page.waitForTimeout(2000);
  await page.goto(`${WEB_BASE}/superadmin/seleksi-admin`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_08_superadmin_seleksi.png') });

  // 9. Superadmin Admin Aktif
  console.log('9. Navigating to Superadmin Admin Aktif...');
  await page.goto(`${WEB_BASE}/superadmin/admin-aktif`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_09_superadmin_admin_aktif.png') });

  await browser.close();
  console.log('Web screenshots captured successfully.');
}

async function captureMobile() {
  console.log('=== Capturing Mobile (Viewport: 390x844 - Smartphone Frame) ===');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true,
  });
  const page = await context.newPage();

  console.log('Opening Flutter Mobile App...');
  await page.goto(MOBILE_BASE, { waitUntil: 'networkidle' });
  console.log('Waiting for Flutter canvas...');
  await page.waitForTimeout(6000);

  // 1. Mobile Login
  console.log('1. Capturing Mobile Login...');
  await page.screenshot({ path: path.join(OUT_DIR, 'mobile_01_login.png') });

  // Attempt login as civitas1
  try {
    console.log('Attempting interaction in Flutter mobile...');
    const inputs = page.locator('input');
    const inputCount = await inputs.count();
    console.log('Inputs found in Flutter web:', inputCount);
    if (inputCount >= 2) {
      await inputs.nth(0).fill('civitas1');
      await inputs.nth(1).fill('civitas123');
    }
    const masukBtn = page.getByText('Masuk', { exact: true });
    if (await masukBtn.isVisible()) {
      await masukBtn.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: path.join(OUT_DIR, 'mobile_03_home.png') });

      const buatLaporTab = page.getByText('Buat Laporan');
      if (await buatLaporTab.isVisible()) {
        await buatLaporTab.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: path.join(OUT_DIR, 'mobile_04_buat_laporan.png') });
      }

      const riwayatTab = page.getByText('Riwayat');
      if (await riwayatTab.isVisible()) {
        await riwayatTab.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: path.join(OUT_DIR, 'mobile_05_riwayat.png') });
      }

      const chatTab = page.getByText('Pesan');
      if (await chatTab.isVisible()) {
        await chatTab.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: path.join(OUT_DIR, 'mobile_06_pesan.png') });
      }

      const profilTab = page.getByText('Profil');
      if (await profilTab.isVisible()) {
        await profilTab.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: path.join(OUT_DIR, 'mobile_07_profil.png') });
      }
    }
  } catch (err) {
    console.log('Error interacting with Flutter:', err.message);
  }

  await browser.close();
  console.log('Mobile screenshots captured successfully.');
}

async function main() {
  await captureWeb();
  await captureMobile();
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
