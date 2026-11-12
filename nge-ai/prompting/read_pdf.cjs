const fs = require('fs');
const path = require('path');

const pdfPath = path.join(__dirname, '..', 'referensi', 'tugas-testing', 'Tugas Praktikum Decision Table.pdf');

(async () => {
  // Dynamic import for ESM module
  const pdfjsLib = await import('pdfjs-dist/legacy/build/pdf.mjs');
  
  const data = new Uint8Array(fs.readFileSync(pdfPath));
  const doc = await pdfjsLib.getDocument({ data }).promise;
  
  console.log('=== PDF INFO ===');
  console.log('Total Pages:', doc.numPages);
  
  for (let i = 1; i <= doc.numPages; i++) {
    console.log(`\n========== PAGE ${i} ==========`);
    const page = await doc.getPage(i);
    const textContent = await page.getTextContent();
    
    // Group text items by their y-position to reconstruct lines
    const items = textContent.items.filter(item => item.str && item.str.trim());
    
    // Sort by y (descending, since PDF y goes bottom-up) then x
    items.sort((a, b) => {
      const yDiff = b.transform[5] - a.transform[5];
      if (Math.abs(yDiff) > 3) return yDiff;
      return a.transform[4] - b.transform[4];
    });
    
    // Group into lines (items within 3 units of y are same line)
    let currentY = null;
    let currentLine = '';
    const lines = [];
    
    for (const item of items) {
      const y = Math.round(item.transform[5]);
      if (currentY === null || Math.abs(y - currentY) > 3) {
        if (currentLine.trim()) lines.push(currentLine.trim());
        currentLine = item.str;
        currentY = y;
      } else {
        currentLine += ' ' + item.str;
      }
    }
    if (currentLine.trim()) lines.push(currentLine.trim());
    
    for (const line of lines) {
      console.log(line);
    }
  }
})();
