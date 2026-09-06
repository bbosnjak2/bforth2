const http = require("http");
const path = require("path");
const fs = require("fs");
const pty = require("node-pty");
const { BRIDGE_BASE_URL, BRIDGE_HOST, BRIDGE_PORT } = require("./tests/playwright/bridge-config");

const XTERM_JS_PATH = path.join(__dirname, "node_modules", "@xterm", "xterm", "lib", "xterm.js");
const XTERM_CSS_PATH = path.join(__dirname, "node_modules", "@xterm", "xterm", "css", "xterm.css");

const COMMAND_TIMEOUT_MS = Number.parseInt(process.env.RUNCPM_COMMAND_TIMEOUT_MS || "10000", 10);
const COMMAND_IDLE_MS = Number.parseInt(process.env.RUNCPM_COMMAND_IDLE_MS || "150", 10);

function resolveRunCpmExecutable() {
  const root = __dirname;
  const override = process.env.RUNCPM_EXE;

  if (override) {
    if (fs.existsSync(override)) {
      return path.resolve(override);
    }
    throw new Error(`RUNCPM_EXE points to missing file: ${override}`);
  }

  const candidates = [
    path.join(root, "RunCPMRuntime", "RunCPM.exe"),
    path.join(root, "tools", "RunCPM", "RunCPM", "RunCPM.exe"),
  ];

  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) {
      return candidate;
    }
  }

  throw new Error(
    "RunCPM executable not found. Build RunCPM first and copy it to RunCPMRuntime/RunCPM.exe.\n" +
      `Searched:\n${candidates.join("\n")}`
  );
}

class RunCpmBridge {
  constructor(exePath) {
    this.exePath = exePath;
    this.cwd = path.dirname(exePath);
    this.process = null;
    this.exitWait = null;
    this.resolveExitWait = null;
    this.closed = false;
    this.transcript = "";
    this.rawTranscript = "";
    this.waiting = null;

    this.startProcess();
  }

  startProcess() {
    const proc = pty.spawn(this.exePath, [], {
      cwd: this.cwd,
      name: "xterm-color",
      cols: 120,
      rows: 40,
      env: process.env,
    });

    this.process = proc;
    this.exitWait = new Promise((resolve) => {
      this.resolveExitWait = resolve;
    });
    this.closed = false;
    this.transcript = "";
    this.rawTranscript = "";

    proc.onData((chunk) => {
      this.appendOutput(chunk);
    });

    proc.onExit(({ exitCode }) => {
      if (this.process !== proc) {
        return;
      }

      this.closed = true;
      this.appendOutput(`\n[RunCPM exited with code ${exitCode}]\n`);
      this.process = null;
      if (this.resolveExitWait) {
        this.resolveExitWait();
        this.resolveExitWait = null;
      }

      if (this.waiting) {
        const waiting = this.waiting;
        this.waiting = null;
        clearTimeout(waiting.timeoutTimer);
        clearTimeout(waiting.idleTimer);
        waiting.reject(new Error(`RunCPM exited with code ${exitCode}`));
      }
    });
  }

  appendOutput(text) {
    if (!text) {
      return;
    }

    this.rawTranscript += text;
    this.transcript += normalizeTerminalText(text);

    if (this.waiting) {
      const waiting = this.waiting;
      clearTimeout(waiting.idleTimer);
      waiting.idleTimer = setTimeout(() => this.resolveCurrentCommand(), COMMAND_IDLE_MS);
    }
  }

  getState() {
    return {
      closed: this.closed,
      transcript: this.transcript,
      rawTranscript: this.rawTranscript,
    };
  }

  async sendCommand(command) {
    if (this.closed || !this.process) {
      throw new Error("RunCPM is not running");
    }
    if (this.waiting) {
      throw new Error("A command is already in progress");
    }

    const commandText = String(command ?? "").trim();

    const start = this.transcript.length;

    return new Promise((resolve, reject) => {
      const waiting = {
        start,
        resolve,
        reject,
        timeoutTimer: null,
        idleTimer: null,
      };

      waiting.timeoutTimer = setTimeout(() => {
        if (this.waiting !== waiting) {
          return;
        }
        this.waiting = null;
        clearTimeout(waiting.idleTimer);
        reject(new Error(`Timed out waiting for output after ${COMMAND_TIMEOUT_MS}ms`));
      }, COMMAND_TIMEOUT_MS);

      waiting.idleTimer = setTimeout(() => this.resolveCurrentCommand(), COMMAND_IDLE_MS);
      this.waiting = waiting;

      try {
        // RunCPM command handling expects carriage return as Enter.
        this.process.write(`${commandText}\r`);
      } catch (err) {
        if (this.waiting === waiting) {
          this.waiting = null;
          clearTimeout(waiting.timeoutTimer);
          clearTimeout(waiting.idleTimer);
        }
        reject(err);
      }
    });
  }

  resolveCurrentCommand() {
    if (!this.waiting) {
      return;
    }

    const waiting = this.waiting;
    this.waiting = null;
    clearTimeout(waiting.timeoutTimer);
    clearTimeout(waiting.idleTimer);
    waiting.resolve(this.transcript.slice(waiting.start));
  }

  async close() {
    if (!this.process) {
      return;
    }

    const proc = this.process;

    try {
      await this.sendCommand("EXIT");
    } catch {
      // Best effort shutdown.
    }

    let exited = false;
    try {
      await Promise.race([
        this.exitWait,
        new Promise((resolve) => setTimeout(resolve, 1200)),
      ]);
      exited = this.process !== proc;
    } catch {
      exited = false;
    }

    if (!exited) {
      try {
        proc.kill();
      } catch {
        // Process may already be gone.
      }
    }

    if (this.process === proc) {
      this.process = null;
      this.closed = true;
    }
  }

  async restart() {
    await this.close();
    this.startProcess();
  }
}

function normalizeTerminalText(text) {
  if (!text) {
    return "";
  }

  // Strip ANSI control sequences and keep only readable transcript content.
  const withoutAnsi = text.replace(/\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1B\\))/g, "");

  return withoutAnsi
    .replace(/\u0007/g, "")
    .replace(/\f/g, "")
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n");
}

const HTML_PAGE = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>RunCPM Bridge</title>
  <link rel="stylesheet" href="/vendor/xterm.css" />
  <style>
    :root {
      --bg: #091114;
      --panel: #081b22;
      --text: #ccffdd;
      --accent: #63f2a6;
      --border: #1f4f5c;
    }

    body {
      margin: 0;
      min-height: 100vh;
      background: radial-gradient(circle at 20% 10%, #11313b 0%, var(--bg) 60%);
      color: var(--text);
      font-family: "Consolas", "Courier New", monospace;
      display: grid;
      place-items: center;
      padding: 16px;
      box-sizing: border-box;
    }

    .terminal {
      width: min(980px, 100%);
      border: 1px solid var(--border);
      border-radius: 10px;
      background: linear-gradient(180deg, #08202a 0%, var(--panel) 100%);
      box-shadow: 0 18px 45px rgba(0, 0, 0, 0.45);
      overflow: hidden;
    }

    .header {
      padding: 10px 14px;
      border-bottom: 1px solid var(--border);
      font-weight: 600;
      letter-spacing: 0.03em;
      color: #9cf8c3;
    }

    #terminal-output {
      margin: 0;
      min-height: 420px;
      max-height: 65vh;
      overflow: auto;
      padding: 14px;
      background: rgba(0, 0, 0, 0.35);
    }

    #output {
      position: absolute;
      left: -99999px;
      width: 1px;
      height: 1px;
      overflow: hidden;
      white-space: pre-wrap;
    }

    .xterm-viewport {
      overflow-y: auto !important;
    }

    form {
      display: flex;
      gap: 8px;
      padding: 12px;
      border-top: 1px solid var(--border);
    }

    #command {
      flex: 1;
      font: inherit;
      color: var(--text);
      background: #031017;
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 10px;
      outline: none;
    }

    #command:focus {
      border-color: var(--accent);
      box-shadow: 0 0 0 1px rgba(99, 242, 166, 0.5);
    }

    #send {
      font: inherit;
      background: #0d2a2f;
      color: var(--text);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 10px 16px;
      cursor: pointer;
    }

    #status {
      font-size: 0.9rem;
      color: #9eb9c0;
      padding: 0 12px 12px;
    }
  </style>
</head>
<body>
  <section class="terminal">
    <div class="header">RunCPM Browser Bridge</div>
    <div id="terminal-output" aria-label="terminal output"></div>
    <pre id="output"></pre>
    <form id="terminal-form">
      <input id="command" autocomplete="off" spellcheck="false" aria-label="command" />
      <button id="send" type="submit">Send</button>
    </form>
    <div id="status"></div>
  </section>

  <script src="/vendor/xterm.js"></script>
  <script>
    const output = document.getElementById("output");
    const terminalOutput = document.getElementById("terminal-output");
    const form = document.getElementById("terminal-form");
    const input = document.getElementById("command");
    const status = document.getElementById("status");

    const terminal = new Terminal({
      cols: 120,
      rows: 40,
      cursorBlink: false,
      disableStdin: true,
      convertEol: false,
      theme: {
        background: "#00000000",
        foreground: "#ccffdd",
      },
    });
    terminal.open(terminalOutput);

    let closed = false;
    let lastRawLength = 0;

    function renderState(state) {
      output.textContent = state.transcript || "";

      const rawTranscript = state.rawTranscript || "";
      if (rawTranscript.length < lastRawLength) {
        terminal.reset();
        lastRawLength = 0;
      }

      if (rawTranscript.length > lastRawLength) {
        const delta = rawTranscript.slice(lastRawLength);
        terminal.write(delta);
        lastRawLength = rawTranscript.length;
      }

      closed = !!state.closed;
      input.disabled = closed;
      document.getElementById("send").disabled = closed;
      status.textContent = closed ? "RunCPM exited" : "Connected";
    }

    async function refreshState() {
      const response = await fetch("/api/state");
      const state = await response.json();
      renderState(state);
    }

    form.addEventListener("submit", async (event) => {
      event.preventDefault();
      const command = input.value;
      if (closed) {
        return;
      }

      input.value = "";

      const response = await fetch("/api/command", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ command }),
      });

      const payload = await response.json();
      if (payload.error) {
        status.textContent = payload.error;
      }

      await refreshState();
      input.focus();
    });

    refreshState().catch((err) => {
      status.textContent = err.message;
    });

    setInterval(() => {
      refreshState().catch(() => {
        // Keep polling; temporary failures should self-heal.
      });
    }, 250);
  </script>
</body>
</html>`;

function sendJson(res, statusCode, payload) {
  const body = Buffer.from(JSON.stringify(payload), "utf8");
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": body.length,
  });
  res.end(body);
}

function sendFile(res, filePath, contentType) {
  if (!fs.existsSync(filePath)) {
    sendJson(res, 404, { error: "Not found" });
    return;
  }

  const body = fs.readFileSync(filePath);
  res.writeHead(200, {
    "Content-Type": contentType,
    "Content-Length": body.length,
  });
  res.end(body);
}

async function readRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.setEncoding("utf8");

    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1024 * 1024) {
        reject(new Error("Request body too large"));
      }
    });

    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

async function main() {
  const exePath = resolveRunCpmExecutable();
  const bridge = new RunCpmBridge(exePath);

  const server = http.createServer(async (req, res) => {
    try {
      if (req.method === "GET" && req.url === "/") {
        const body = Buffer.from(HTML_PAGE, "utf8");
        res.writeHead(200, {
          "Content-Type": "text/html; charset=utf-8",
          "Content-Length": body.length,
        });
        res.end(body);
        return;
      }

      if (req.method === "GET" && req.url === "/vendor/xterm.js") {
        sendFile(res, XTERM_JS_PATH, "application/javascript; charset=utf-8");
        return;
      }

      if (req.method === "GET" && req.url === "/vendor/xterm.css") {
        sendFile(res, XTERM_CSS_PATH, "text/css; charset=utf-8");
        return;
      }

      if (req.method === "GET" && req.url === "/api/state") {
        sendJson(res, 200, bridge.getState());
        return;
      }

      if (req.method === "POST" && req.url === "/api/command") {
        const raw = await readRequestBody(req);

        let payload = null;
        try {
          payload = JSON.parse(raw);
        } catch (err) {
          sendJson(res, 400, { error: `Invalid JSON: ${err.message}` });
          return;
        }

        const command = String(payload.command ?? "");

        const output = await bridge.sendCommand(command);
        sendJson(res, 200, { output });
        return;
      }

      if (req.method === "POST" && req.url === "/api/restart") {
        await bridge.restart();
        sendJson(res, 200, bridge.getState());
        return;
      }

      sendJson(res, 404, { error: "Not found" });
    } catch (err) {
      sendJson(res, 500, { error: err.message });
    }
  });

  server.listen(BRIDGE_PORT, BRIDGE_HOST, () => {
    console.log(`RunCPM bridge listening at ${BRIDGE_BASE_URL}`);
    console.log(`Executable: ${exePath}`);
    console.log(`Runtime cwd: ${path.dirname(exePath)}`);
  });

  const shutdown = async () => {
    server.close();
    await bridge.close();
  };

  process.on("SIGINT", shutdown);
  process.on("SIGTERM", shutdown);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
