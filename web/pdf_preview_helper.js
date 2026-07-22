// Vista previa ligera: solo la primera página + conteo total.
window.matupdfGeneratePreview = async function (blobUrl) {
  const pdfjsLib = window['pdfjs-dist/build/pdf'];
  if (!pdfjsLib) {
    throw new Error('PDF.js no está cargado');
  }

  pdfjsLib.GlobalWorkerOptions.workerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.worker.min.js';

  const pdf = await pdfjsLib.getDocument(blobUrl).promise;
  const pageCount = pdf.numPages;
  const page = await pdf.getPage(1);
  const viewport = page.getViewport({ scale: 1.25 });

  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');
  canvas.width = viewport.width;
  canvas.height = viewport.height;

  await page.render({ canvasContext: context, viewport }).promise;

  const blob = await new Promise((resolve) =>
    canvas.toBlob(resolve, 'image/jpeg', 0.82),
  );
  const thumbnailUrl = URL.createObjectURL(blob);

  return { thumbnailUrl, pageCount };
};

window.matupdfPreviewReady = function () {
  return !!(
    (window['pdfjs-dist/build/pdf'] || window.pdfjsLib) &&
    typeof window.matupdfGeneratePreview === 'function'
  );
};

/** Extrae texto de una página (1-based) con cajas normalizadas 0–1. */
window.matupdfExtractPageText = async function (blobUrl, pageNumber) {
  const pdfjsLib = window['pdfjs-dist/build/pdf'] || window.pdfjsLib;
  if (!pdfjsLib) throw new Error('PDF.js no está cargado');

  pdfjsLib.GlobalWorkerOptions.workerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.worker.min.js';

  const pdf = await pdfjsLib.getDocument(blobUrl).promise;
  const page = await pdf.getPage(pageNumber);
  const viewport = page.getViewport({ scale: 1 });
  const content = await page.getTextContent();
  const items = [];

  for (let i = 0; i < content.items.length; i++) {
    const item = content.items[i];
    if (!item || typeof item.str !== 'string') continue;
    const str = item.str;
    if (!str.trim()) continue;

    const tx = pdfjsLib.Util.transform(viewport.transform, item.transform);
    const fontHeight = Math.sqrt(tx[2] * tx[2] + tx[3] * tx[3]) || 10;
    const widthPx =
      (item.width || 0) * Math.sqrt(tx[0] * tx[0] + tx[1] * tx[1]) ||
      fontHeight * str.length * 0.5;
    const x = tx[4];
    const y = tx[5] - fontHeight;

    items.push({
      id: 'p' + pageNumber + '-t' + i,
      text: str,
      x: x / viewport.width,
      y: y / viewport.height,
      width: Math.max(widthPx / viewport.width, 0.008),
      height: Math.max(fontHeight / viewport.height, 0.01),
      fontSize: fontHeight,
    });
  }

  return {
    items,
    pageWidth: viewport.width,
    pageHeight: viewport.height,
  };
};

/** Renderiza una página concreta (1-based) y devuelve data URL + tamaño. */
window.matupdfRenderPage = async function (blobUrl, pageNumber, scale) {
  const pdfjsLib = window['pdfjs-dist/build/pdf'] || window.pdfjsLib;
  if (!pdfjsLib) throw new Error('PDF.js no está cargado');

  pdfjsLib.GlobalWorkerOptions.workerSrc =
    'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.worker.min.js';

  const pdf = await pdfjsLib.getDocument(blobUrl).promise;
  const page = await pdf.getPage(pageNumber);
  const viewport = page.getViewport({ scale: scale || 1.5 });

  const canvas = document.createElement('canvas');
  const context = canvas.getContext('2d');
  canvas.width = viewport.width;
  canvas.height = viewport.height;

  await page.render({ canvasContext: context, viewport }).promise;

  return {
    dataUrl: canvas.toDataURL('image/jpeg', 0.88),
    width: viewport.width,
    height: viewport.height,
    pageCount: pdf.numPages,
  };
};
