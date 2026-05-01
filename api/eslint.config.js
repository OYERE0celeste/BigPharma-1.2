const js = require("@eslint/js");
const prettier = require("eslint-plugin-prettier");
const prettierConfig = require("eslint-config-prettier");
const security = require("eslint-plugin-security");
const sonarjs = require("eslint-plugin-sonarjs");
const globals = require("globals");

module.exports = [
  js.configs.recommended,
  security.configs.recommended,
  sonarjs.configs.recommended,
  {
    plugins: {
      prettier: prettier,
      security: security,
      sonarjs: sonarjs,
    },
    languageOptions: {
      ecmaVersion: 2021,
      sourceType: "commonjs",
      globals: {
        ...globals.node,
        ...globals.jest,
      },
    },
    rules: {
      ...prettierConfig.rules,
      "prettier/prettier": "error",
      "no-console": "off",
      "security/detect-object-injection": "off",
      "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    },
  },
];
