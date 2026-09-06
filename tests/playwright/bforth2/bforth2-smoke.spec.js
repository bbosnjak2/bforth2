const { test, expect } = require("@playwright/test");
const {
  sendBridgeCommand,
  restartBridgeAndWaitForPrompt,
} = require("../bridge-test-helpers");

test.beforeEach(async ({ request }) => {
  await restartBridgeAndWaitForPrompt(request);
});

test("launches bforth2 and shows banner, help, and input prompt", async ({ page }) => {
  await page.goto("/");

  const output = page.locator("#output");
  await expect(output).toContainText("A0>", { timeout: 20000 });

  await page.fill("#command", "bforth2");
  await page.click("#send");

  await expect(output).toContainText("Welcome to bforth2", { timeout: 20000 });
  await expect(output).toContainText("Type 'help' for A list of commands.", { timeout: 20000 });
  await expect(output).toContainText(">", { timeout: 20000 });
});

test("bforth2 echoes test, prints OK, reprompts, and exits on CR", async ({ page, request }) => {
  await page.goto("/");

  const lines = (text) =>
    String(text)
      .split(/\r?\n/)
      .map((line) => line.trimEnd())
      .filter((line) => line.length > 0);

  const launchOutput = await sendBridgeCommand(request, "bforth2");
  expect(launchOutput).toContain("Welcome to bforth2");
  expect(launchOutput).toContain("Type 'help' for A list of commands.");
  expect(launchOutput).toContain(">");

  const testOutput = await sendBridgeCommand(request, "test");
  const testLines = lines(testOutput);
  expect(testLines).toEqual(["test", "TEST?", ">"]);

  const helpOutput = await sendBridgeCommand(request, "help");
  const helpLines = lines(helpOutput);
  expect(helpLines).toEqual(["help", "OK", ">"]);

  const quitOutput = await sendBridgeCommand(request, "quit");
  const quitLines = lines(quitOutput);
  expect(quitLines).toEqual(["quit", "OK", ">"]);

  // Send CR at bforth2 prompt (empty command) to exit back to CP/M.
  const exitOutput = await sendBridgeCommand(request, "");
  expect(exitOutput).toContain("A0>");
});
