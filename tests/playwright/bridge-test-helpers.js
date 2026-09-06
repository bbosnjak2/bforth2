const { expect } = require("@playwright/test");

async function sendBridgeCommand(request, command) {
  for (let attempt = 0; attempt < 2; attempt += 1) {
    const response = await request.post("/api/command", {
      data: { command },
    });
    expect(response.ok()).toBeTruthy();

    const payload = await response.json();
    if (!payload.error) {
      return String(payload.output || "");
    }

    if (payload.error.includes("already in progress") && attempt === 0) {
      // Allow the bridge idle window to settle before retrying.
      await new Promise((resolve) => setTimeout(resolve, 250));
      continue;
    }

    throw new Error(`Bridge command failed: ${payload.error}`);
  }

  throw new Error("Bridge command failed after retry");
}

async function restartBridgeAndWaitForPrompt(request) {
  const restartResponse = await request.post("/api/restart");
  expect(restartResponse.ok()).toBeTruthy();

  for (let attempt = 0; attempt < 40; attempt += 1) {
    const stateResponse = await request.get("/api/state");
    expect(stateResponse.ok()).toBeTruthy();

    const state = await stateResponse.json();
    const transcript = String(state.transcript || "");
    if (!state.closed && transcript.includes("A0>")) {
      return;
    }

    await new Promise((resolve) => setTimeout(resolve, 100));
  }

  throw new Error("RunCPM did not reach A0> prompt after restart");
}

module.exports = {
  sendBridgeCommand,
  restartBridgeAndWaitForPrompt,
};