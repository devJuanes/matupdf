// Aplica anotaciones sobre un PDF con pdf-lib y descarga el resultado.
window.matupdfApplyEdits = async function (blobUrl, annotations) {
  if (typeof PDFLib === 'undefined') {
    throw new Error('pdf-lib no está cargado');
  }

  const { PDFDocument, rgb, StandardFonts, degrees } = PDFLib;
  const response = await fetch(blobUrl);
  if (!response.ok) throw new Error('No se pudo leer el PDF');

  const pdfBytes = await response.arrayBuffer();
  const pdfDoc = await PDFDocument.load(pdfBytes);
  const pages = pdfDoc.getPages();
  const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica);

  const hexToRgb = (hex) => {
    const h = (hex || '#E53935').replace('#', '');
    const full = h.length === 3 ? h.split('').map((c) => c + c).join('') : h;
    const n = parseInt(full, 16);
    return rgb(((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255);
  };

  for (const a of annotations || []) {
    const page = pages[a.pageIndex];
    if (!page) continue;
    const { width: pw, height: ph } = page.getSize();
    const x = (a.x || 0) * pw;
    const yFromTop = (a.y || 0) * ph;
    const w = Math.max(4, (a.width || 0.1) * pw);
    const h = Math.max(4, (a.height || 0.05) * ph);
    const y = ph - yFromTop - h;
    const color = hexToRgb(a.color);

    if (a.type === 'text' && a.text) {
      const size = a.fontSize || 16;
      page.drawText(String(a.text), {
        x: x,
        y: ph - yFromTop - size,
        size,
        font: helvetica,
        color,
        maxWidth: w,
      });
    } else if (a.type === 'replaceText' && a.text != null) {
      // Cubre el texto original y escribe el nuevo
      const pad = 1.5;
      page.drawRectangle({
        x: Math.max(0, x - pad),
        y: Math.max(0, y - pad),
        width: w + pad * 2,
        height: h + pad * 2,
        color: rgb(1, 1, 1),
        borderWidth: 0,
      });
      const size = Math.min(a.fontSize || h * 0.85, h * 0.95);
      page.drawText(String(a.text), {
        x: x,
        y: ph - yFromTop - size * 0.85,
        size: Math.max(6, size),
        font: helvetica,
        color: hexToRgb(a.color || '#111827'),
        maxWidth: w,
      });
    } else if (a.type === 'highlight') {
      page.drawRectangle({
        x,
        y,
        width: w,
        height: h,
        color: rgb(1, 0.92, 0.23),
        opacity: 0.4,
        borderWidth: 0,
      });
    } else if (a.type === 'ellipse') {
      page.drawEllipse({
        x: x + w / 2,
        y: y + h / 2,
        xScale: w / 2,
        yScale: h / 2,
        borderColor: color,
        borderWidth: a.strokeWidth || 2,
        color: undefined,
        opacity: 1,
      });
    } else if (a.type === 'signature' || a.type === 'image') {
      if (!a.imageDataUrl) continue;
      const base64 = a.imageDataUrl.split(',')[1];
      if (!base64) continue;
      const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
      const isPng = (a.imageDataUrl || '').includes('image/png');
      const img = isPng
        ? await pdfDoc.embedPng(bytes)
        : await pdfDoc.embedJpg(bytes);
      page.drawImage(img, { x, y, width: w, height: h });
    } else if (a.type === 'stampCross' || a.type === 'stampCheck') {
      const label = a.type === 'stampCross' ? '✗' : '✓';
      page.drawText(label, {
        x: x,
        y: y + h * 0.15,
        size: Math.min(w, h) * 0.9,
        font: helvetica,
        color,
      });
    } else if (a.type === 'pencil' && Array.isArray(a.points) && a.points.length > 1) {
      for (let i = 1; i < a.points.length; i++) {
        const p0 = a.points[i - 1];
        const p1 = a.points[i];
        page.drawLine({
          start: { x: p0.x * pw, y: ph - p0.y * ph },
          end: { x: p1.x * pw, y: ph - p1.y * ph },
          thickness: a.strokeWidth || 2,
          color,
        });
      }
    }
  }

  // silence unused
  void degrees;

  const out = await pdfDoc.save();
  const blob = new Blob([out], { type: 'application/pdf' });
  return URL.createObjectURL(blob);
};

window.matupdfEditReady = function () {
  return typeof PDFLib !== 'undefined' && typeof window.matupdfApplyEdits === 'function';
};

/** Dibuja una firma a partir de puntos {x,y|null} y devuelve PNG data URL. */
window.matupdfSignatureToPng = function (points, width, height) {
  const canvas = document.createElement('canvas');
  canvas.width = width || 420;
  canvas.height = height || 160;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = 'rgba(0,0,0,0)';
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.strokeStyle = '#111827';
  ctx.lineWidth = 2.4;
  ctx.lineCap = 'round';
  ctx.lineJoin = 'round';

  let started = false;
  for (const p of points || []) {
    if (!p || p.x == null || p.y == null) {
      started = false;
      continue;
    }
    if (!started) {
      ctx.beginPath();
      ctx.moveTo(p.x, p.y);
      started = true;
    } else {
      ctx.lineTo(p.x, p.y);
      ctx.stroke();
      ctx.beginPath();
      ctx.moveTo(p.x, p.y);
    }
  }
  return canvas.toDataURL('image/png');
};
