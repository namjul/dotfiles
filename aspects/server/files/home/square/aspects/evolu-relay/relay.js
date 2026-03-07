#!/usr/bin/env node
/**
 * Evolu Relay Server
 *
 * Self-hosted WebSocket relay for multi-device sync.
 * Stores relay database in the configured data directory.
 *
 * Usage:
 *   node relay.js                # directly
 *   mise exec -- node relay.js   # via mise
 *
 * Configuration:
 *   RELAY_PORT        Port to run on (default: 4000)
 *   RELAY_QUOTA_MB    Quota per owner in MB (default: 10)
 *   RELAY_LOGGING     Enable verbose logging (set to "true")
 *   RELAY_DATA        Data directory (required)
 *
 * Example:
 *   RELAY_PORT=8080 RELAY_QUOTA_MB=100 node relay.js
 */

import { createConsole } from "@evolu/common";
import { createNodeJsRelay } from "@evolu/nodejs";

const relayDataDir = process.env["RELAY_DATA"];
if (!relayDataDir) {
  console.error("Error: RELAY_DATA environment variable is required");
  process.exit(1);
}

const port = Number(process.env["RELAY_PORT"]) || 4000;
const quotaMB = Number(process.env["RELAY_QUOTA_MB"]) || 10;
const maxBytes = quotaMB * 1024 * 1024;
const enableLogging = process.env["RELAY_LOGGING"] === "true";

console.log("Starting Evolu relay server...");
console.log(`  Port: ${port}`);
console.log(`  Data directory: ${relayDataDir}`);
console.log(`  Quota per owner: ${quotaMB}MB`);
console.log(`  Logging: ${enableLogging ? "enabled" : "disabled"}`);
console.log();

const relay = await createNodeJsRelay({
  console: createConsole(),
})({
  port,
  enableLogging,
  isOwnerWithinQuota: (_ownerId, requiredBytes) => {
    return requiredBytes <= maxBytes;
  },
});

if (relay.ok) {
  console.log(`Relay server running at ws://localhost:${port}/<ownerId>`);
  console.log("Press Ctrl+C to stop");
  console.log();

  process.once("SIGINT", () => {
    console.log("\nShutting down relay server...");
    relay.value[Symbol.dispose]();
  });
  process.once("SIGTERM", () => {
    console.log("\nShutting down relay server...");
    relay.value[Symbol.dispose]();
  });
} else {
  console.error("Failed to start relay server:");
  console.error(relay.error);
  process.exit(1);
}
