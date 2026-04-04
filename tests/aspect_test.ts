// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Aspect tests for universal-chat-extractor.
//
// Aspect tests verify cross-cutting concerns that span all modules:
// security policy, accessibility of public documentation, EditorConfig
// consistency, no banned file patterns, and test infrastructure health.
// Run with: deno test tests/aspect_test.ts

import {
  assertEquals,
  assertNotEquals,
  assertMatch,
} from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

async function readFile(relPath: string): Promise<string | null> {
  return Deno.readTextFile(REPO_ROOT + relPath).catch(() => null);
}

async function pathExists(relPath: string): Promise<boolean> {
  return Deno.stat(REPO_ROOT + relPath).then(() => true).catch(() => false);
}

// ---------------------------------------------------------------------------
// Aspect: Security policy
// ---------------------------------------------------------------------------

Deno.test("aspect/security: SECURITY.md exists", async () => {
  assertEquals(await pathExists("SECURITY.md"), true);
});

Deno.test("aspect/security: SECURITY.md mentions vulnerability reporting", async () => {
  const content = await readFile("SECURITY.md");
  assertNotEquals(content, null);
  const lc = content!.toLowerCase();
  const hasDisclosure =
    lc.includes("vulnerabilit") ||
    lc.includes("disclosure") ||
    lc.includes("report") ||
    lc.includes("security");
  assertEquals(hasDisclosure, true, "SECURITY.md should mention security reporting");
});

Deno.test("aspect/security: .well-known/security.txt exists", async () => {
  assertEquals(await pathExists(".well-known/security.txt"), true);
});

Deno.test("aspect/security: no .env files in repo", async () => {
  assertEquals(await pathExists(".env"), false, ".env must not be committed");
});

Deno.test("aspect/security: no hardcoded secret patterns in README", async () => {
  const content = await readFile("README.adoc");
  assertNotEquals(content, null);
  const hasSecretLeak = /(?:api_key|password|secret|token)\s*=/i.test(content!);
  assertEquals(hasSecretLeak, false, "README.adoc must not contain hardcoded secrets");
});

// ---------------------------------------------------------------------------
// Aspect: Code of conduct
// ---------------------------------------------------------------------------

Deno.test("aspect/community: CODE_OF_CONDUCT.md exists", async () => {
  assertEquals(await pathExists("CODE_OF_CONDUCT.md"), true);
});

Deno.test("aspect/community: CODE_OF_CONDUCT.md has meaningful content", async () => {
  const content = await readFile("CODE_OF_CONDUCT.md");
  assertNotEquals(content, null);
  assertEquals(content!.length > 100, true, "CODE_OF_CONDUCT.md should have meaningful content");
});

// ---------------------------------------------------------------------------
// Aspect: EditorConfig consistency
// ---------------------------------------------------------------------------

Deno.test("aspect/formatting: .editorconfig exists", async () => {
  assertEquals(await pathExists(".editorconfig"), true);
});

Deno.test("aspect/formatting: .editorconfig has root = true", async () => {
  const content = await readFile(".editorconfig");
  assertNotEquals(content, null);
  assertMatch(content!, /root\s*=\s*true/i);
});

Deno.test("aspect/formatting: .editorconfig defines indent_style", async () => {
  const content = await readFile(".editorconfig");
  assertNotEquals(content, null);
  assertMatch(content!, /indent_style\s*=/);
});

// ---------------------------------------------------------------------------
// Aspect: No banned file patterns
// ---------------------------------------------------------------------------

const BANNED_FILES = [
  "package.json",
  "package-lock.json",
  "yarn.lock",
  "bun.lockb",
  "node_modules",
  ".npmrc",
  "Dockerfile",       // Must use Containerfile (Podman)
];

for (const f of BANNED_FILES) {
  Deno.test(`aspect/policy: banned file must not exist — ${f}`, async () => {
    assertEquals(await pathExists(f), false, `Banned file/directory present: ${f}`);
  });
}

// ---------------------------------------------------------------------------
// Aspect: No TypeScript without Deno (no tsconfig.json)
// ---------------------------------------------------------------------------

Deno.test("aspect/language: no tsconfig.json (TS only via Deno, not tsc)", async () => {
  assertEquals(await pathExists("tsconfig.json"), false);
});

// ---------------------------------------------------------------------------
// Aspect: Documentation completeness
// ---------------------------------------------------------------------------

const DOCS = [
  "README.adoc",
  "EXPLAINME.adoc",
  "CONTRIBUTING.md",
  "ROADMAP.adoc",
];

for (const doc of DOCS) {
  Deno.test(`aspect/docs: documentation file is non-empty — ${doc}`, async () => {
    const content = await readFile(doc);
    assertNotEquals(content, null, `Doc missing: ${doc}`);
    assertEquals(content!.trim().length > 50, true, `Doc is too short: ${doc}`);
  });
}

// ---------------------------------------------------------------------------
// Aspect: All non-bench test files use Deno.test
// ---------------------------------------------------------------------------

Deno.test("aspect/tests: all non-bench .ts files in tests/ use Deno.test", async () => {
  const testsDir = REPO_ROOT + "tests";
  for await (const entry of Deno.readDir(testsDir)) {
    if (entry.isFile && entry.name.endsWith(".ts") && !entry.name.includes("bench")) {
      const content = await Deno.readTextFile(`${testsDir}/${entry.name}`);
      assertMatch(
        content,
        /Deno\.test\s*\(/,
        `Test file ${entry.name} must contain Deno.test(`,
      );
    }
  }
});
