// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Smoke tests for universal-chat-extractor.
//
// Smoke tests verify the repo is in a runnable/functional state at a high level:
// required files exist, directory layout is correct, and no catastrophic
// mis-configuration is present.
// Run with: deno test tests/smoke_test.ts

import { assertEquals, assertNotEquals } from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

async function pathExists(relPath: string): Promise<boolean> {
  try {
    await Deno.stat(REPO_ROOT + relPath);
    return true;
  } catch {
    return false;
  }
}

async function isDirectory(relPath: string): Promise<boolean> {
  try {
    const info = await Deno.stat(REPO_ROOT + relPath);
    return info.isDirectory;
  } catch {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Smoke: top-level required files
// ---------------------------------------------------------------------------

const REQUIRED_FILES = [
  "LICENSE",
  "README.adoc",
  "EXPLAINME.adoc",
  "SECURITY.md",
  "CONTRIBUTING.md",
  "MAINTAINERS.adoc",
  "ROADMAP.adoc",
  "NOTICE",
  "Justfile",
  "0-AI-MANIFEST.a2ml",
  "PROOF-NEEDS.md",
  ".editorconfig",
  "stapeln.toml",
  "flake.nix",
  "guix.scm",
];

for (const file of REQUIRED_FILES) {
  Deno.test(`smoke: required file exists — ${file}`, async () => {
    const exists = await pathExists(file);
    assertEquals(exists, true, `Required file missing: ${file}`);
  });
}

// ---------------------------------------------------------------------------
// Smoke: required directories
// ---------------------------------------------------------------------------

const REQUIRED_DIRS = [
  ".machine_readable",
  ".machine_readable/6a2",
  "tests",
  "tests/fuzz",
  "ffi",
  "ffi/zig",
  "ffi/zig/src",
  "ffi/zig/test",
  "src",
  "src/abi",
  "docs",
  "examples",
  "contractiles",
  "hooks",
  ".well-known",
];

for (const dir of REQUIRED_DIRS) {
  Deno.test(`smoke: required directory exists — ${dir}`, async () => {
    const isDir = await isDirectory(dir);
    assertEquals(isDir, true, `Required directory missing: ${dir}`);
  });
}

// ---------------------------------------------------------------------------
// Smoke: machine-readable checkpoint files
// ---------------------------------------------------------------------------

const A2ML_FILES = [
  ".machine_readable/6a2/STATE.a2ml",
  ".machine_readable/6a2/META.a2ml",
  ".machine_readable/6a2/ECOSYSTEM.a2ml",
  ".machine_readable/6a2/AGENTIC.a2ml",
  ".machine_readable/6a2/NEUROSYM.a2ml",
  ".machine_readable/6a2/PLAYBOOK.a2ml",
];

for (const f of A2ML_FILES) {
  Deno.test(`smoke: a2ml checkpoint exists — ${f}`, async () => {
    const exists = await pathExists(f);
    assertEquals(exists, true, `A2ML file missing: ${f}`);
  });
}

// ---------------------------------------------------------------------------
// Smoke: .well-known files
// ---------------------------------------------------------------------------

const WELL_KNOWN = [
  ".well-known/security.txt",
  ".well-known/ai.txt",
  ".well-known/humans.txt",
];

for (const f of WELL_KNOWN) {
  Deno.test(`smoke: well-known file exists — ${f}`, async () => {
    const exists = await pathExists(f);
    assertEquals(exists, true, `Well-known file missing: ${f}`);
  });
}

// ---------------------------------------------------------------------------
// Smoke: ABI/FFI scaffold is present
// ---------------------------------------------------------------------------

Deno.test("smoke: ABI Layout.idr exists", async () => {
  assertEquals(await pathExists("src/abi/Layout.idr"), true);
});

Deno.test("smoke: ABI Foreign.idr exists", async () => {
  assertEquals(await pathExists("src/abi/Foreign.idr"), true);
});

Deno.test("smoke: FFI main.zig exists", async () => {
  assertEquals(await pathExists("ffi/zig/src/main.zig"), true);
});

Deno.test("smoke: FFI build.zig exists", async () => {
  assertEquals(await pathExists("ffi/zig/build.zig"), true);
});

Deno.test("smoke: FFI integration_test.zig exists", async () => {
  assertEquals(await pathExists("ffi/zig/test/integration_test.zig"), true);
});

// ---------------------------------------------------------------------------
// Smoke: SECURITY.md has content
// ---------------------------------------------------------------------------

Deno.test("smoke: SECURITY.md is non-empty", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "SECURITY.md");
  assertNotEquals(content.trim(), "");
});

// ---------------------------------------------------------------------------
// Smoke: README.adoc mentions project domain (chat extraction)
// ---------------------------------------------------------------------------

Deno.test("smoke: README.adoc mentions chat or universal", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "README.adoc");
  const lc = content.toLowerCase();
  const hasDomain = lc.includes("chat") || lc.includes("universal") || lc.includes("extract");
  assertEquals(hasDomain, true, "README.adoc should mention project domain");
});
