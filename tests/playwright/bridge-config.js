const DEFAULT_BRIDGE_HOST = "127.0.0.1";
const DEFAULT_BRIDGE_PORT = 8080;

function resolveBridgeHost() {
  const host = process.env.RUNCPM_BRIDGE_HOST;
  return host && host.trim() ? host.trim() : DEFAULT_BRIDGE_HOST;
}

function resolveBridgePort() {
  const raw = process.env.RUNCPM_BRIDGE_PORT;
  if (!raw) {
    return DEFAULT_BRIDGE_PORT;
  }

  const parsed = Number.parseInt(raw, 10);
  if (!Number.isInteger(parsed) || parsed < 1 || parsed > 65535) {
    throw new Error(`Invalid RUNCPM_BRIDGE_PORT: ${raw}`);
  }

  return parsed;
}

const BRIDGE_HOST = resolveBridgeHost();
const BRIDGE_PORT = resolveBridgePort();
const BRIDGE_BASE_URL = `http://${BRIDGE_HOST}:${BRIDGE_PORT}`;

module.exports = {
  BRIDGE_BASE_URL,
  BRIDGE_HOST,
  BRIDGE_PORT,
  DEFAULT_BRIDGE_HOST,
  DEFAULT_BRIDGE_PORT,
};
