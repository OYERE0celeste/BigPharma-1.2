const dotenv = require("dotenv");

const DOTENV_LOADED_KEY = Symbol.for("bigpharma.dotenv.loaded");

if (!globalThis[DOTENV_LOADED_KEY]) {
  dotenv.config();
  globalThis[DOTENV_LOADED_KEY] = true;
}
