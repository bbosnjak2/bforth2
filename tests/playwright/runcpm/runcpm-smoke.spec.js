const { test, expect } = require("@playwright/test");
const { restartBridgeAndWaitForPrompt } = require("../bridge-test-helpers");

test.beforeEach(async ({ request }) => {
  await restartBridgeAndWaitForPrompt(request);
});

test("shows RunCPM startup and prompt", async ({ page }) => {
  await page.goto("/");

  await expect(page.locator("#output")).toContainText("RunCPM Version", {
    timeout: 20000,
  });
  await expect(page.locator("#output")).toContainText("A0>", {
    timeout: 20000,
  });
});

test("accepts a DIR command and returns to prompt", async ({ page }) => {
  await page.goto("/");

  const output = page.locator("#output");
  await expect(output).toContainText("A0>", { timeout: 20000 });

  await page.fill("#command", "DIR");
  await page.click("#send");

  await expect(output).toContainText("DIR", { timeout: 20000 });
  await expect(output).toContainText("A0>", { timeout: 20000 });
});
