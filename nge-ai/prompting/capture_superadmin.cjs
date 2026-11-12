const { chromium } = require('playwright');
const path = require('path');

const OUT_DIR = path.resolve(__dirname, 'doc_assets');
const WEB_BASE = 'https://web-admincampus-lapor-production-3cd2.up.railway.app';

(async () => {
  console.log('Capturing Superadmin pages...');
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1.5,
  });
  const page = await context.newPage();

  console.log('Navigating to login...');
  await page.goto(`${WEB_BASE}/login`, { waitUntil: 'networkidle' });
  await page.fill('#username', 'superadmin1');
  await page.fill('#password', 'superadmin123');
  await page.click('.login-submit');
  await page.waitForTimeout(3000);

  console.log('Navigating to seleksi admin...');
  await page.goto(`${WEB_BASE}/superadmin/seleksi-admin`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_08_superadmin_seleksi.png') });

  console.log('Navigating to admin aktif...');
  await page.goto(`${WEB_BASE}/superadmin/admin-aktif`, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(OUT_DIR, 'web_09_superadmin_admin_aktif.png') });

  await browser.close();
  console.log('Superadmin captured successfully.');
})().catch(err => {
  console.error('Superadmin error:', err);
  process.exit(1);
});
