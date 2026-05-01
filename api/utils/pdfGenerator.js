const PDFDocument = require("pdfkit");

/**
 * Generate a basic PDF report for a list of items
 */
exports.generateReport = (title, headers, rows) => {
  return new Promise((resolve) => {
    const doc = new PDFDocument();
    const buffers = [];

    doc.on("data", buffers.push.bind(buffers));
    doc.on("end", () => {
      resolve(Buffer.concat(buffers));
    });

    // Title
    doc.fontSize(20).text(title, { align: "center" });
    doc.moveDown();
    doc.fontSize(10).text(`Generated on: ${new Date().toLocaleString()}`, { align: "right" });
    doc.moveDown();

    // Simple Table-like structure
    doc.fontSize(12);
    const startY = doc.y;
    const colWidth = 500 / headers.length;

    headers.forEach((header, i) => {
      doc.text(header, 50 + i * colWidth, startY, { bold: true });
    });

    doc.moveDown();
    doc.lineWidth(1);
    doc.moveTo(50, doc.y).lineTo(550, doc.y).stroke();
    doc.moveDown(0.5);

    rows.forEach((row) => {
      const currentY = doc.y;
      row.forEach((cell, i) => {
        doc.text(cell.toString(), 50 + i * colWidth, currentY);
      });
      doc.moveDown();
      if (doc.y > 700) doc.addPage();
    });

    doc.end();
  });
};
