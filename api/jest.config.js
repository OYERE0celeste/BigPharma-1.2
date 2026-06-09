module.exports = {
  testEnvironment: 'node',
  testMatch: [
    '**/tests/**/*.test.js',
    '**/?(*.)+(spec|test).js'
  ],
  collectCoverageFrom: [
    'controllers/**/*.js',
    'services/**/*.js',
    'utils/**/*.js',
    'middleware/**/*.js',
    '!**/node_modules/**',
    '!**/vendor/**'
  ],
  coverageReporters: ['json-summary', 'text', 'lcov'],
  setupFilesAfterEnv: ['./tests/setup.js']
};
