// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Contract tests for universal-chat-extractor.
//
// Contract tests verify the repo fulfils its stated obligations to consumers
// and integrators: RSR compliance, Hypatia CI contract, ABI/FFI architecture
// standard, and the gitbot-fleet interface contract.
// Run with: deno test tests/contract_test.ts

import {
  assertEquals,
  assertNotEquals,
  assertMatch,
  assertStringIncludes,
} from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

async function readFile(relPath: string): Promise<string | null> {
  return Deno.readTextFile(REPO_ROOT + relPath).catch(() => null);
}

async function pathExists(relPath: string): Promise<boolean> {
  return Deno.stat(REPO_ROOT + relPath).then(() => true).catch(() => false);
}

// ---------------------------------------------------------------------------
// Contract: RSR (Rhodium Standard Repository) obligations
// ---------------------------------------------------------------------------

Deno.test("contract/RSR: STATE.a2ml exists in .machine_readable/6a2/", async () => {
  assertEquals(await pathExists(".machine_readable/6a2/STATE.a2ml"), true);
});

Deno.test("contract/RSR: META.a2ml exists in .machine_readable/6a2/", async () => {
  assertEquals(await pathExists(".machine_readable/6a2/META.a2ml"), true);
});

Deno.test("contract/RSR: ECOSYSTEM.a2ml exists in .machine_readable/6a2/", async () => {
  assertEquals(await pathExists(".machine_readable/6a2/ECOSYSTEM.a2ml"), true);
});

Deno.test("contract/RSR: AGENTIC.a2ml exists in .machine_readable/6a2/", async () => {
  assertEquals(await pathExists(".machine_readable/6a2/AGENTIC.a2ml"), true);
});

Deno.test("contract/RSR: no SCM checkpoint files in repo root", async () => {
  const bannedRootFiles = ["STATE.scm", "META.scm", "ECOSYSTEM.scm", "AGENTIC.scm"];
  for (const f of bannedRootFiles) {
    const exists = await pathExists(f);
    assertEquals(exists, false, `SCM checkpoint file must NOT be in repo root: ${f}`);
  }
});

Deno.test("contract/RSR: no SCM checkpoint files in .machine_readable/", async () => {
  const bannedNames = ["STATE.scm", "META.scm", "ECOSYSTEM.scm", "AGENTIC.scm"];
  for (const f of bannedNames) {
    const exists = await pathExists(`.machine_readable/${f}`);
    assertEquals(exists, false, `SCM file must not exist in .machine_readable/: ${f}`);
  }
});

Deno.test("contract/RSR: EXPLAINME.adoc is present", async () => {
  assertEquals(await pathExists("EXPLAINME.adoc"), true);
});

Deno.test("contract/RSR: ABI-FFI-README.md is present", async () => {
  assertEquals(await pathExists("ABI-FFI-README.md"), true);
});

// ---------------------------------------------------------------------------
// Contract: ABI/FFI architecture standard (Idris2 + Zig)
// ---------------------------------------------------------------------------

Deno.test("contract/ABI: src/abi/ directory follows Idris2 ABI standard", async () => {
  assertEquals(await pathExists("src/abi"), true);
});

Deno.test("contract/ABI: Layout.idr defines ABI layout", async () => {
  const content = await readFile("src/abi/Layout.idr");
  assertNotEquals(content, null, "Layout.idr must exist");
});

Deno.test("contract/ABI: Foreign.idr declares FFI interface", async () => {
  const content = await readFile("src/abi/Foreign.idr");
  assertNotEquals(content, null, "Foreign.idr must exist");
});

Deno.test("contract/FFI: ffi/zig/ implements C-compatible FFI", async () => {
  assertEquals(await pathExists("ffi/zig/src/main.zig"), true);
});

// ---------------------------------------------------------------------------
// Contract: License policy obligations
// ---------------------------------------------------------------------------

Deno.test("contract/license: LICENSE file uses PMPL", async () => {
  const content = await readFile("LICENSE");
  assertNotEquals(content, null, "LICENSE must exist");
  assertStringIncludes(
    content!.toLowerCase(),
    "palimpsest",
    "LICENSE must contain PMPL (Palimpsest) text",
  );
});

Deno.test("contract/license: LICENSES/PMPL-1.0-or-later.txt present", async () => {
  assertEquals(await pathExists("LICENSES/PMPL-1.0-or-later.txt"), true);
});

Deno.test("contract/license: README.adoc has SPDX header", async () => {
  const content = await readFile("README.adoc");
  assertNotEquals(content, null);
  assertMatch(content!, /SPDX-License-Identifier:/);
});

// ---------------------------------------------------------------------------
// Contract: Hypatia CI integration
// ---------------------------------------------------------------------------

Deno.test("contract/hypatia: .hypatia/ directory exists", async () => {
  assertEquals(await pathExists(".hypatia"), true);
});

Deno.test("contract/hypatia: .hypatia/last-visit.json exists", async () => {
  assertEquals(await pathExists(".hypatia/last-visit.json"), true);
});

// ---------------------------------------------------------------------------
// Contract: Author attribution
// ---------------------------------------------------------------------------

Deno.test("contract/author: MAINTAINERS.adoc references hyperpolymath or Jonathan", async () => {
  const content = await readFile("MAINTAINERS.adoc");
  assertNotEquals(content, null, "MAINTAINERS.adoc must exist");
  const hasAuthor = content!.includes("Jonathan") || content!.includes("hyperpolymath");
  assertEquals(hasAuthor, true, "MAINTAINERS.adoc should reference the author");
});

// ---------------------------------------------------------------------------
// Contract: Stapeln container definition
// ---------------------------------------------------------------------------

Deno.test("contract/stapeln: stapeln.toml exists and is non-empty", async () => {
  const content = await readFile("stapeln.toml");
  assertNotEquals(content, null);
  assertNotEquals(content!.trim(), "");
});

// ---------------------------------------------------------------------------
// Contract: Contractiles interface
// ---------------------------------------------------------------------------

Deno.test("contract/contractiles: TRUST.contractile exists in .machine_readable/", async () => {
  assertEquals(await pathExists(".machine_readable/TRUST.contractile"), true);
});

Deno.test("contract/contractiles: MUST.contractile exists in .machine_readable/", async () => {
  assertEquals(await pathExists(".machine_readable/MUST.contractile"), true);
});
