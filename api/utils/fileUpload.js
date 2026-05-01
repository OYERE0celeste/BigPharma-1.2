const multer = require("multer");
const path = require("path");
const { failure } = require("./response");

// Storage configuration
const storage = multer.memoryStorage();

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error("Only JPEG, PNG and PDF files are allowed!"));
  }
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter,
});

/**
 * Middleware wrapper for multer with error handling
 */
exports.uploadSingle = (fieldName) => {
  const singleUpload = upload.single(fieldName);
  
  return (req, res, next) => {
    singleUpload(req, res, (err) => {
      if (err instanceof multer.MulterError) {
        return failure(res, { status: 400, message: `Upload Error: ${err.message}`, code: "UPLOAD_ERROR" });
      } else if (err) {
        return failure(res, { status: 400, message: err.message, code: "UPLOAD_ERROR" });
      }
      next();
    });
  };
};
