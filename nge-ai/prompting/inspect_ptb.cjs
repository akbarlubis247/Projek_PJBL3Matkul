const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 1440, height: 900 }
  });

  console.log('=== 1. Checking Landing Page Mahasiswa ===');
  try {
    await page.goto('https://ptb-ipb.freedev.app/landingpage.php', { waitUntil: 'networkidle', timeout: 20000 });
  } catch (e) {
    console.log('Fallback to domcontentloaded for landing page');
    await page.goto('https://ptb-ipb.freedev.app/landingpage.php', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(3000);
  }

  console.log('Landing Page Title:', await page.title());
  await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_landing.png') });

  // Get all text, headings, buttons, and links
  const headings = await page.$$eval('h1, h2, h3, h4', els => els.map(e => e.innerText.trim()).filter(Boolean));
  console.log('Headings on landing page:', headings);

  const forms = await page.$$eval('form', forms => forms.map(f => ({
    id: f.id,
    action: f.action,
    inputs: Array.from(f.querySelectorAll('input, select, textarea')).map(i => ({
      name: i.name,
      type: i.type,
      placeholder: i.placeholder,
      id: i.id
    }))
  })));
  console.log('Forms found on landing page:', JSON.stringify(forms, null, 2));

  const allLinks = await page.$$eval('a', anchors => anchors.map(a => ({
    text: a.innerText.trim(),
    href: a.href
  })).filter(a => a.text && a.text.length < 50));
  console.log('Links on landing page:', allLinks);

  console.log('\n=== 2. Checking Admin Login ===');
  await page.goto('https://ptb-ipb.freedev.app/login.php?i=1', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_login.png') });

  const loginInputs = await page.$$eval('input', inputs => inputs.map(i => ({ name: i.name, type: i.type, id: i.id })));
  console.log('Login form inputs:', loginInputs);

  // Fill login
  if (loginInputs.some(i => i.name === 'email' || i.type === 'email')) {
    await page.fill('input[type="email"], input[name="email"]', 'undang@ptb.ac.id');
  } else if (loginInputs.length > 0) {
    await page.fill('input[type="text"], input:not([type="password"])', 'undang@ptb.ac.id');
  }
  await page.fill('input[type="password"]', 'UndangPass');

  await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_login_filled.png') });

  // Submit login
  const submitBtn = await page.$('button[type="submit"], input[type="submit"], button');
  if (submitBtn) {
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 15000 }).catch(() => {}),
      submitBtn.click(),
    ]);
  }
  await page.waitForTimeout(3000);
  console.log('Current URL after login:', page.url());
  console.log('Page title after login:', await page.title());
  await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_admin_dashboard.png') });

  // Inspect admin dashboard navigation and features
  const adminMenu = await page.$$eval('nav a, aside a, .sidebar a, ul a, table', els => {
    return els.map(e => e.innerText ? e.innerText.trim() : (e.tagName + ' found')).filter(Boolean);
  });
  console.log('Admin dashboard elements:', adminMenu.slice(0, 30));

  await browser.close();
})();
