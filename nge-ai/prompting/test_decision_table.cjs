const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const RESULTS_DIR = path.join(__dirname, 'doc_assets', 'decision_table');

// 8 Rules dari Decision Table (3 kondisi = 2^3 = 8 kombinasi)
const rules = [
  { id: 1, title: true,  desc: true,  file: true,  expected: 'success' },
  { id: 2, title: true,  desc: true,  file: false, expected: 'error' },
  { id: 3, title: true,  desc: false, file: true,  expected: 'error' },
  { id: 4, title: true,  desc: false, file: false, expected: 'error' },
  { id: 5, title: false, desc: true,  file: true,  expected: 'error' },
  { id: 6, title: false, desc: true,  file: false, expected: 'error' },
  { id: 7, title: false, desc: false, file: true,  expected: 'error' },
  { id: 8, title: false, desc: false, file: false, expected: 'error' },
];

// Create a dummy test image for upload
function createTestImage(filePath) {
  // Minimal valid PNG (1x1 pixel, red)
  const pngData = Buffer.from(
    '89504e470d0a1a0a0000000d494844520000000100000001080200000090' +
    '77530e0000000c4944415408d763f8cfc000000002000160e72d450000' +
    '0000049454e44ae426082', 'hex'
  );
  fs.writeFileSync(filePath, pngData);
}

(async () => {
  if (!fs.existsSync(RESULTS_DIR)) fs.mkdirSync(RESULTS_DIR, { recursive: true });

  const testImagePath = path.join(RESULTS_DIR, 'test_image.png');
  createTestImage(testImagePath);

  const browser = await chromium.launch({ headless: true });
  const results = [];

  for (const rule of rules) {
    console.log(`\n=== Testing Rule ${rule.id}: Title=${rule.title}, Desc=${rule.desc}, File=${rule.file} ===`);
    const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
    const page = await context.newPage();

    try {
      // Login
      await page.goto('https://ptb-ipb.freedev.app/login.php?i=1', { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(1500);
      await page.fill('input[type="email"], input[name="email"]', 'undang@ptb.ac.id');
      await page.fill('input[type="password"]', 'UndangPass');
      const submitBtn = await page.$('button[type="submit"], input[type="submit"], button');
      if (submitBtn) {
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 15000 }).catch(() => {}),
          submitBtn.click(),
        ]);
      }
      await page.waitForTimeout(2000);

      // Go to Upload Konten (Artikel)
      await page.goto('https://ptb-ipb.freedev.app/upload.php?type=article', { waitUntil: 'domcontentloaded' });
      await page.waitForTimeout(2000);

      // Screenshot BEFORE filling
      await page.screenshot({ path: path.join(RESULTS_DIR, `rule${rule.id}_before.png`) });

      // Fill form based on rule conditions
      // C1: Title
      if (rule.title) {
        await page.fill('input[name="title"]', `Test Artikel Rule ${rule.id}`);
      }
      // else leave empty

      // C2: Description
      if (rule.desc) {
        await page.fill('textarea[name="description"]', `Deskripsi test untuk rule ${rule.id}. Ini adalah konten uji coba Decision Table Testing.`);
      }
      // else leave empty

      // C3: File thumbnail
      if (rule.file) {
        const fileInput = await page.$('input[type="file"]');
        if (fileInput) {
          await fileInput.setInputFiles(testImagePath);
          await page.waitForTimeout(500);
        }
      }
      // else leave empty

      // Screenshot AFTER filling (before submit)
      await page.screenshot({ path: path.join(RESULTS_DIR, `rule${rule.id}_filled.png`) });

      // Submit the form
      const kirimBtn = await page.$('button[type="submit"]');
      if (kirimBtn) {
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'domcontentloaded', timeout: 15000 }).catch(() => {}),
          kirimBtn.click(),
        ]);
      }
      await page.waitForTimeout(3000);

      // Screenshot AFTER submit
      await page.screenshot({ path: path.join(RESULTS_DIR, `rule${rule.id}_result.png`) });

      // Check result
      const currentUrl = page.url();
      const pageContent = await page.content();

      // Detect success or error
      const hasSuccess = pageContent.toLowerCase().includes('berhasil') ||
                         pageContent.toLowerCase().includes('success') ||
                         currentUrl.includes('artikel.php') ||
                         currentUrl.includes('kegiatan.php');

      const hasError = pageContent.toLowerCase().includes('error') ||
                       pageContent.toLowerCase().includes('gagal') ||
                       pageContent.toLowerCase().includes('wajib') ||
                       pageContent.toLowerCase().includes('harus') ||
                       pageContent.toLowerCase().includes('required') ||
                       currentUrl.includes('upload.php');

      // Check for HTML5 validation (form didn't submit)
      const stayedOnForm = currentUrl.includes('upload.php');

      let actualResult;
      if (hasSuccess && !stayedOnForm) {
        actualResult = 'success';
      } else if (stayedOnForm || hasError) {
        actualResult = 'error';
      } else {
        actualResult = 'unknown';
      }

      const pass = actualResult === rule.expected;

      results.push({
        rule: rule.id,
        titleFilled: rule.title,
        descFilled: rule.desc,
        fileFilled: rule.file,
        expected: rule.expected,
        actual: actualResult,
        currentUrl: currentUrl,
        pass: pass,
      });

      console.log(`  Result: ${actualResult} (expected: ${rule.expected}) => ${pass ? 'PASS' : 'FAIL'}`);
      console.log(`  URL after submit: ${currentUrl}`);

      // If success, clean up: delete the test article to avoid polluting
      if (actualResult === 'success') {
        console.log('  (Article was created, may need cleanup)');
      }

    } catch (err) {
      console.log(`  Error: ${err.message}`);
      results.push({
        rule: rule.id,
        titleFilled: rule.title,
        descFilled: rule.desc,
        fileFilled: rule.file,
        expected: rule.expected,
        actual: 'error-exception',
        currentUrl: '',
        pass: false,
        error: err.message,
      });
    }

    await context.close();
  }

  await browser.close();

  // Print summary table
  console.log('\n\n========== DECISION TABLE TEST RESULTS ==========');
  console.log('Rule | Title | Desc  | File  | Expected | Actual   | Status');
  console.log('-----|-------|-------|-------|----------|----------|-------');
  for (const r of results) {
    console.log(
      `  ${r.rule}  | ${r.titleFilled ? '  T  ' : '  F  '} | ${r.descFilled ? '  T  ' : '  F  '} | ${r.fileFilled ? '  T  ' : '  F  '} | ${r.expected.padEnd(8)} | ${r.actual.padEnd(8)} | ${r.pass ? 'PASS' : 'FAIL'}`
    );
  }

  // Save results to JSON
  fs.writeFileSync(path.join(RESULTS_DIR, 'test_results.json'), JSON.stringify(results, null, 2));
  console.log('\nResults saved to doc_assets/decision_table/test_results.json');
  console.log('Screenshots saved to doc_assets/decision_table/');
})();
