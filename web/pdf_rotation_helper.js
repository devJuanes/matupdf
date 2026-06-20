// Rota todas las páginas de un PDF usando pdf-lib (sin rasterizar).
window.matupdfRotatePdf = async function (blobUrl, degrees) {
  if (!degrees || degrees % 360 === 0) return blobUrl;

  const { PDFDocument, degrees: deg } = PDFLib;
  const response = await fetch(blobUrl);
  if (!response.ok) {
    throw new Error('No se pudo leer el PDF para rotar');
  }

  const pdfBytes = await response.arrayBuffer();
  const pdfDoc = await PDFDocument.load(pdfBytes);
  const rotation = deg(degrees);

  for (const page of pdfDoc.getPages()) {
    page.setRotation(rotation);
  }

  const rotatedBytes = await pdfDoc.save();
  const blob = new Blob([rotatedBytes], { type: 'application/pdf' });
  return URL.createObjectURL(blob);
};

window.matupdfRotationReady = function () {
  return typeof PDFLib !== 'undefined' && typeof window.matupdfRotatePdf === 'function';
};
