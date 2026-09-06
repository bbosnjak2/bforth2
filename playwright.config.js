// @ts-check
const { defineConfig, devices } = require("@playwright/test");
const { BRIDGE_BASE_URL } = require("./tests/playwright/bridge-config");

module.exports = defineConfig({
  testDir: "./tests/playwright",
  testMatch: "**/*.spec.js",
  fullyParallel: false,
  workers: 1,
  reporter: "html",
  use: {
    baseURL: BRIDGE_BASE_URL,
    trace: "on-first-retry",
  },
  webServer: {
    command: "npm run start",
    url: BRIDGE_BASE_URL,
    reuseExistingServer: !process.env.CI,
    timeout: 60000,
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
});
