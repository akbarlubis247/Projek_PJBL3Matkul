const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  // Login first
  console.log('=== Logging in... ===');
  await page.goto('https://ptb-ipb.freedev.app/login.php?i=1', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(2000);
  await page.fill('input[type="email"], input[name="email"]', 'undang@ptb.ac.id');
  await page.fill('input[type="password"]', 'UndangPass');
  const submitBtn = await page.$('button[type="submit"], input[type="submit"], button');
  if (submitBtn) {
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 15000 }).catch(() => {}),
      submitBtn.click(),
    ]);
  }
  await page.waitForTimeout(3000);
  console.log('Logged in. Current URL:', page.url());

  // === Explore Artikel ===
  console.log('\n=== 1. Exploring ARTIKEL ===');
  try {
    const artikelLink = await page.$('a:has-text("Artikel")');
    if (artikelLink) {
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
        artikelLink.click(),
      ]);
      await page.waitForTimeout(2000);
      console.log('Artikel URL:', page.url());
      await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_artikel_page.png') });

      // Check for buttons (add, edit, delete)
      const buttons = await page.$$eval('button, a.btn, input[type="submit"], .btn', els =>
        els.map(e => ({ text: e.innerText?.trim(), href: e.href || '', class: e.className })).filter(e => e.text)
      );
      console.log('Buttons on Artikel page:', JSON.stringify(buttons, null, 2));

      // Check for forms
      const forms = await page.$$eval('form', forms => forms.map(f => ({
        id: f.id, action: f.action, method: f.method,
        inputs: Array.from(f.querySelectorAll('input, select, textarea')).map(i => ({
          name: i.name, type: i.type, placeholder: i.placeholder, id: i.id, tagName: i.tagName
        }))
      })));
      console.log('Forms on Artikel:', JSON.stringify(forms, null, 2));

      // Look for "Tambah" or "Add" button
      const tambahBtn = await page.$('a:has-text("Tambah"), button:has-text("Tambah"), a:has-text("Add"), button:has-text("Add")');
      if (tambahBtn) {
        console.log('Found Tambah/Add button, clicking...');
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
          tambahBtn.click(),
        ]);
        await page.waitForTimeout(2000);
        console.log('Add Artikel URL:', page.url());
        await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_artikel_add.png') });

        const addForms = await page.$$eval('form', forms => forms.map(f => ({
          id: f.id, action: f.action, method: f.method,
          inputs: Array.from(f.querySelectorAll('input, select, textarea, [contenteditable]')).map(i => ({
            name: i.name, type: i.type, placeholder: i.placeholder, id: i.id, tagName: i.tagName,
            required: i.required
          }))
        })));
        console.log('Add Artikel Form:', JSON.stringify(addForms, null, 2));
      }
    }
  } catch (e) {
    console.log('Error exploring Artikel:', e.message);
  }

  // === Explore Upload Konten ===
  console.log('\n=== 2. Exploring UPLOAD KONTEN ===');
  try {
    await page.goto('https://ptb-ipb.freedev.app/admin.php', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(2000);

    const uploadLink = await page.$('a:has-text("Upload Konten"), a:has-text("Upload")');
    if (uploadLink) {
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
        uploadLink.click(),
      ]);
      await page.waitForTimeout(2000);
      console.log('Upload Konten URL:', page.url());
      await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_upload_page.png') });

      const forms = await page.$$eval('form', forms => forms.map(f => ({
        id: f.id, action: f.action, method: f.method,
        inputs: Array.from(f.querySelectorAll('input, select, textarea')).map(i => ({
          name: i.name, type: i.type, placeholder: i.placeholder, id: i.id, tagName: i.tagName,
          required: i.required, accept: i.accept || ''
        }))
      })));
      console.log('Upload Konten Forms:', JSON.stringify(forms, null, 2));

      const buttons = await page.$$eval('button, a.btn, input[type="submit"], .btn', els =>
        els.map(e => ({ text: e.innerText?.trim(), type: e.type })).filter(e => e.text)
      );
      console.log('Upload Konten Buttons:', JSON.stringify(buttons, null, 2));
    } else {
      console.log('Upload Konten link not found');
    }
  } catch (e) {
    console.log('Error exploring Upload Konten:', e.message);
  }

  // === Explore Kegiatan ===
  console.log('\n=== 3. Exploring KEGIATAN ===');
  try {
    await page.goto('https://ptb-ipb.freedev.app/admin.php', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(2000);

    const kegiatanLink = await page.$('a:has-text("Kegiatan")');
    if (kegiatanLink) {
      await Promise.all([
        page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
        kegiatanLink.click(),
      ]);
      await page.waitForTimeout(2000);
      console.log('Kegiatan URL:', page.url());
      await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_kegiatan_page.png') });

      const forms = await page.$$eval('form', forms => forms.map(f => ({
        id: f.id, action: f.action, method: f.method,
        inputs: Array.from(f.querySelectorAll('input, select, textarea')).map(i => ({
          name: i.name, type: i.type, placeholder: i.placeholder, id: i.id, tagName: i.tagName,
          required: i.required
        }))
      })));
      console.log('Kegiatan Forms:', JSON.stringify(forms, null, 2));

      const buttons = await page.$$eval('button, a.btn, input[type="submit"], .btn', els =>
        els.map(e => ({ text: e.innerText?.trim(), href: e.href || '' })).filter(e => e.text)
      );
      console.log('Kegiatan Buttons:', JSON.stringify(buttons, null, 2));

      // Look for tambah
      const tambahBtn = await page.$('a:has-text("Tambah"), button:has-text("Tambah"), a:has-text("Add")');
      if (tambahBtn) {
        console.log('Found Tambah Kegiatan button, clicking...');
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 10000 }).catch(() => {}),
          tambahBtn.click(),
        ]);
        await page.waitForTimeout(2000);
        console.log('Add Kegiatan URL:', page.url());
        await page.screenshot({ path: path.join(__dirname, 'doc_assets', 'ptb_kegiatan_add.png') });

        const addForms = await page.$$eval('form', forms => forms.map(f => ({
          id: f.id, action: f.action, method: f.method,
          inputs: Array.from(f.querySelectorAll('input, select, textarea')).map(i => ({
            name: i.name, type: i.type, placeholder: i.placeholder, id: i.id, tagName: i.tagName,
            required: i.required
          }))
        })));
        console.log('Add Kegiatan Form:', JSON.stringify(addForms, null, 2));
      }
    }
  } catch (e) {
    console.log('Error exploring Kegiatan:', e.message);
  }

  await browser.close();
  console.log('\n=== DONE ===');
})();
