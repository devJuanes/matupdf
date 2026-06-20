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
    window['pdfjs-dist/build/pdf'] &&
    typeof window.matupdfGeneratePreview === 'function'
  );
};
