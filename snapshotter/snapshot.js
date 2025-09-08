const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ 
    args: ['--no-sandbox', '--disable-gpu'],
    headless: true 
  });
  const page = await browser.newPage();
  
  await page.goto('http://localhost:3838', { waitUntil: 'networkidle0' });
  console.log('Page chargée.');

  await page.waitForSelector('#distPlot img');

  const configurations = [];
  const binsOptions = [5, 10, 15, 20, 25];
  const colorOptions = ['darkgray', 'steelblue', 'forestgreen'];

  // Créer un tableau de toutes les configurations
  for (const bins of binsOptions) {
    for (const color of colorOptions) {
      configurations.push({ bins, color });
    }
  }

  let count = 1;
  // Utiliser une boucle for...of pour un contrôle séquentiel
  for (const config of configurations) {
    console.log(`Configuration ${count}: Bins=${config.bins}, Color=${config.color}`);

    const initialImageSrc = await page.$eval('#distPlot img', img => img.src);

    await page.$eval('input[id="bins"]', (slider, value) => {
      slider.value = value;
      slider.dispatchEvent(new Event('input', { bubbles: true }));
      slider.dispatchEvent(new Event('change', { bubbles: true }));
    }, config.bins);

    await page.select('select[id="color"]', config.color);
    
    try {
      await page.waitForFunction(
        (selector, initialSrc) => {
          const newSrc = document.querySelector(selector)?.src;
          return newSrc && newSrc !== initialSrc;
        },
        { timeout: 15000 },
        '#distPlot img',
        initialImageSrc
      );
    } catch (e) {
      console.error(`Timeout pour la configuration ${count}. Le graphique ne s'est pas mis à jour.`);
      // On continue même si une configuration échoue
    }

    const filePath = `snapshot_${count}.pdf`;
    await page.pdf({ path: filePath, format: 'A4' });
    console.log(` -> Snapshot généré : ${filePath}`);
    
    count++;
  }

  console.log('Toutes les captures ont été réalisées.');
  await browser.close();
})();
