// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Unit tests for universal-chat-extractor.
//
// These tests verify individual logical units: SPDX header detection,
// repo metadata parsing, required-file enumeration, and placeholder detection.
// Run with: deno test tests/unit_test.ts

import { assertEquals, assertMatch, assertNotEquals } from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

// ---------------------------------------------------------------------------
// Helper utilities
// ---------------------------------------------------------------------------

/** Read a file relative to the repo root. Returns null if absent. */
async function readFile(relPath: string): Promise<string | null> {
  try {
    return await Deno.readTextFile(REPO_ROOT + relPath);
  } catch {
    return null;
  }
}

/** Check whether a path exists (file or directory). */
async function pathExists(relPath: string): Promise<boolean> {
  try {
    await Deno.stat(REPO_ROOT + relPath);
    return true;
  } catch {
    return false;
  }
}

/** Extract the SPDX identifier from file content. Returns null if not found. */
function extractSpdxId(content: string): string | null {
  const match = content.match(/SPDX-License-Identifier:\s*(\S+)/);
  return match ? match[1] : null;
}

// ---------------------------------------------------------------------------
// Unit: SPDX header parsing
// ---------------------------------------------------------------------------

Deno.test("unit: extractSpdxId parses valid SPDX line", () => {
  const content = "// SPDX-License-Identifier: PMPL-1.0-or-later\ncode";
  assertEquals(extractSpdxId(content), "PMPL-1.0-or-later");
});

Deno.test("unit: extractSpdxId handles TOML-style comment", () => {
  const content = "# SPDX-License-Identifier: PMPL-1.0-or-later\n[section]";
  assertEquals(extractSpdxId(content), "PMPL-1.0-or-later");
});

Deno.test("unit: extractSpdxId returns null when header absent", () => {
  assertEquals(extractSpdxId("no license here"), null);
});

Deno.test("unit: extractSpdxId handles leading whitespace", () => {
  const content = "   // SPDX-License-Identifier: MIT\n";
  assertEquals(extractSpdxId(content), "MIT");
});

// ---------------------------------------------------------------------------
// Unit: placeholder detection
// ---------------------------------------------------------------------------

/** Returns true if the string contains an unresolved Mustache-style placeholder. */
function containsUnresolvedPlaceholder(content: string): boolean {
  // Match {{WORD}} patterns (uppercase only — these are truly unresolved)
  return /\{\{[A-Z_]+\}\}/.test(content);
}

Deno.test("unit: containsUnresolvedPlaceholder detects {{PROJECT}}", () => {
  assertEquals(containsUnresolvedPlaceholder("name: {{PROJECT}}"), true);
});

Deno.test("unit: containsUnresolvedPlaceholder ignores lowercase placeholders", () => {
  // lowercase {{project}} is intentionally preserved in scaffold Zig templates
  assertEquals(containsUnresolvedPlaceholder("fn {{project}}_init()"), false);
});

Deno.test("unit: containsUnresolvedPlaceholder allows clean content", () => {
  assertEquals(containsUnresolvedPlaceholder("universal-chat-extractor"), false);
});

// ---------------------------------------------------------------------------
// Unit: chat extraction domain helpers
// ---------------------------------------------------------------------------

/** Validate that a string looks like a chat message timestamp (ISO-ish). */
function isValidTimestamp(ts: string): boolean {
  return /^\d{4}-\d{2}-\d{2}/.test(ts);
}

Deno.test("unit: isValidTimestamp accepts ISO date format", () => {
  assertEquals(isValidTimestamp("2026-04-04T12:00:00Z"), true);
});

Deno.test("unit: isValidTimestamp accepts date-only format", () => {
  assertEquals(isValidTimestamp("2026-01-01"), true);
});

Deno.test("unit: isValidTimestamp rejects garbage", () => {
  assertEquals(isValidTimestamp("not-a-date"), false);
});

/** Validate that a platform name is in the known set. */
function isKnownPlatform(platform: string): boolean {
  const known = ["slack", "discord", "teams", "matrix", "telegram", "signal", "whatsapp", "irc", "zulip"];
  return known.includes(platform.toLowerCase());
}

Deno.test("unit: isKnownPlatform accepts slack", () => {
  assertEquals(isKnownPlatform("slack"), true);
});

Deno.test("unit: isKnownPlatform accepts discord (case insensitive)", () => {
  assertEquals(isKnownPlatform("Discord"), true);
});

Deno.test("unit: isKnownPlatform rejects unknown platform", () => {
  assertEquals(isKnownPlatform("somenovelchat"), false);
});

// ---------------------------------------------------------------------------
// Unit: STATE.a2ml metadata parsing
// ---------------------------------------------------------------------------

Deno.test("unit: STATE.a2ml exists and has valid project name", async () => {
  const content = await readFile(".machine_readable/6a2/STATE.a2ml");
  assertNotEquals(content, null, "STATE.a2ml must exist");
  assertMatch(content!, /project\s*=\s*"universal-chat-extractor"/);
});

Deno.test("unit: STATE.a2ml has SPDX header", async () => {
  const content = await readFile(".machine_readable/6a2/STATE.a2ml");
  assertNotEquals(content, null);
  assertEquals(extractSpdxId(content!), "PMPL-1.0-or-later");
});

Deno.test("unit: STATE.a2ml has version field", async () => {
  const content = await readFile(".machine_readable/6a2/STATE.a2ml");
  assertNotEquals(content, null);
  assertMatch(content!, /version\s*=/);
});

// ---------------------------------------------------------------------------
// Unit: LICENSE content
// ---------------------------------------------------------------------------

Deno.test("unit: LICENSE file exists and is non-empty", async () => {
  const content = await readFile("LICENSE");
  assertNotEquals(content, null, "LICENSE must exist");
  assertNotEquals(content!.trim(), "", "LICENSE must not be empty");
});

Deno.test("unit: LICENSES directory contains PMPL text", async () => {
  const exists = await pathExists("LICENSES/PMPL-1.0-or-later.txt");
  assertEquals(exists, true, "LICENSES/PMPL-1.0-or-later.txt must exist");
});

// ---------------------------------------------------------------------------
// Unit: AI manifest
// ---------------------------------------------------------------------------

Deno.test("unit: 0-AI-MANIFEST.a2ml exists", async () => {
  const exists = await pathExists("0-AI-MANIFEST.a2ml");
  assertEquals(exists, true, "0-AI-MANIFEST.a2ml must exist");
});

Deno.test("unit: 0-AI-MANIFEST.a2ml is non-empty", async () => {
  const content = await readFile("0-AI-MANIFEST.a2ml");
  assertNotEquals(content, null);
  assertNotEquals(content!.trim(), "");
});
