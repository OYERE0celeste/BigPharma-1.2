require("dotenv").config();

const config = {
  mongodb: {
    url: process.env.MONGODB_URI || "mongodb://localhost:27017/bigpharma",
    databaseName: process.env.DB_NAME || "bigpharma",
    options: {
      // connectTimeoutMS: 3600000,
    }
  },
  migrationsDir: "migrations",
  changelogCollectionName: "changelog",
  lockCollectionName: "changelog_lock",
  lockTtl: 0,
  migrationFileExtension: ".js",
  useFileHash: false,
  moduleSystem: 'commonjs',
};

module.exports = config;
