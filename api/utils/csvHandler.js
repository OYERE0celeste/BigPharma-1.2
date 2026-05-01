const { Parser } = require("json2csv");
const csv = require("csv-parser");
const stream = require("stream");

/**
 * Export JSON data to CSV string
 */
exports.jsonToCsv = (data, fields) => {
  const json2csvParser = new Parser({ fields });
  return json2csvParser.parse(data);
};

/**
 * Parse CSV buffer/string to JSON
 */
exports.csvToJson = (csvBuffer) => {
  return new Promise((resolve, reject) => {
    const results = [];
    const bufferStream = new stream.PassThrough();
    bufferStream.end(csvBuffer);

    bufferStream
      .pipe(csv())
      .on("data", (data) => results.push(data))
      .on("end", () => resolve(results))
      .on("error", (err) => reject(err));
  });
};
