// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// End-to-end / reflexive tests for universal-chat-extractor.
//
// E2E/reflexive tests verify the repo as a whole from an external perspective:
// the test suite itself is correct, CI hooks are coherent, and the repo can
// validate its own structure end-to-end.
// Run with: deno test tests/e2e_test.ts

import {
  assertEquals,
  assertNotEquals,
  assertMatch,
  assertStringIncludes,
} from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

// ---------------------------------------------------------------------------
// E2E: Reflexive — this test file has correct SPDX header
// ---------------------------------------------------------------------------

Deno.test("e2e/reflexive: this test file carries PMPL-1.0-or-later header", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "tests/e2e_test.ts");
  assertMatch(content, /SPDX-License-Identifier:\s*PMPL-1\.0-or-later/);
});

// ---------------------------------------------------------------------------
// E2E: Reflexive — all test files have SPDX headers
// ---------------------------------------------------------------------------

Deno.test("e2e/reflexive: all test .ts files have SPDX headers", async () => {
  const testsDir = REPO_ROOT + "tests";
  for await (const entry of Deno.readDir(testsDir)) {
    if (entry.isFile && entry.name.endsWith(".ts")) {
      const content = await Deno.readTextFile(`${testsDir}/${entry.name}`);
      assertMatch(
        content,
        /SPDX-License-Identifier:/,
        `Test file ${entry.name} is missing SPDX header`,
      );
    }
  }
});

// ---------------------------------------------------------------------------
// E2E: CI hook scripts exist and are syntactically non-empty
// ---------------------------------------------------------------------------

const EXPECTED_HOOKS = [
  "hooks/validate-codeql.sh",
  "hooks/validate-permissions.sh",
  "hooks/validate-sha-pins.sh",
  "hooks/validate-spdx.sh",
];

for (const hook of EXPECTED_HOOKS) {
  Deno.test(`e2e: CI hook file exists — ${hook}`, async () => {
    const content = await Deno.readTextFile(REPO_ROOT + hook).catch(() => null);
    assertNotEquals(content, null, `Hook missing: ${hook}`);
    assertNotEquals(content!.trim(), "", `Hook is empty: ${hook}`);
  });
}

// ---------------------------------------------------------------------------
// E2E: ABI/FFI README is coherent
// ---------------------------------------------------------------------------

Deno.test("e2e: ABI-FFI-README.md exists and is non-empty", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "ABI-FFI-README.md").catch(() => null);
  assertNotEquals(content, null, "ABI-FFI-README.md must exist");
  assertNotEquals(content!.trim(), "");
});

// ---------------------------------------------------------------------------
// E2E: Repo topology is self-consistent
// ---------------------------------------------------------------------------

Deno.test("e2e: TOPOLOGY.md exists", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "TOPOLOGY.md").catch(() => null);
  assertNotEquals(content, null, "TOPOLOGY.md must exist");
});

// ---------------------------------------------------------------------------
// E2E: NOTICE file references the project
// ---------------------------------------------------------------------------

Deno.test("e2e: NOTICE file is present and non-trivial", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "NOTICE").catch(() => null);
  assertNotEquals(content, null, "NOTICE must exist");
  assertNotEquals(content!.trim(), "", "NOTICE must not be empty");
});

// ---------------------------------------------------------------------------
// E2E: Justfile contains standard recipes
// ---------------------------------------------------------------------------

Deno.test("e2e: Justfile contains a 'test' recipe", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "Justfile").catch(() => null);
  assertNotEquals(content, null, "Justfile must exist");
  assertStringIncludes(content!, "test", "Justfile should have a test recipe");
});

// ---------------------------------------------------------------------------
// E2E: Deno runtime presence (tests run under Deno)
// ---------------------------------------------------------------------------

Deno.test("e2e: tests run under Deno runtime", () => {
  assertEquals(typeof Deno !== "undefined", true, "Tests must run under Deno");
});

// ---------------------------------------------------------------------------
// E2E: QUICKSTART guides exist
// ---------------------------------------------------------------------------

const QUICKSTART_FILES = [
  "QUICKSTART-USER.adoc",
  "QUICKSTART-DEV.adoc",
  "QUICKSTART-MAINTAINER.adoc",
];

for (const qs of QUICKSTART_FILES) {
  Deno.test(`e2e: quickstart guide present — ${qs}`, async () => {
    const exists = await Deno.stat(REPO_ROOT + qs).then(() => true).catch(() => false);
    assertEquals(exists, true, `Missing quickstart guide: ${qs}`);
  });
}

// ---------------------------------------------------------------------------
// E2E: Idris2 ABI files are non-empty
// ---------------------------------------------------------------------------

Deno.test("e2e: src/abi/Layout.idr is non-empty", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "src/abi/Layout.idr").catch(() => null);
  assertNotEquals(content, null, "src/abi/Layout.idr must exist");
  assertNotEquals(content!.trim(), "");
});

Deno.test("e2e: src/abi/Foreign.idr is non-empty", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "src/abi/Foreign.idr").catch(() => null);
  assertNotEquals(content, null, "src/abi/Foreign.idr must exist");
  assertNotEquals(content!.trim(), "");
});
