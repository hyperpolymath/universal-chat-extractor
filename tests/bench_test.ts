// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Benchmarks for universal-chat-extractor.
//
// Baselines performance of core operations so regressions can be detected.
// At scaffold stage these measure file I/O throughput, metadata parsing
// latency, and domain-specific operations (message parsing, platform routing).
//
// Run with: deno bench tests/bench_test.ts

const REPO_ROOT = new URL("../", import.meta.url).pathname;

// ---------------------------------------------------------------------------
// Bench: file reading throughput
// ---------------------------------------------------------------------------

Deno.bench({
  name: "bench: read LICENSE (file I/O baseline)",
  group: "file-io",
  baseline: true,
  async fn() {
    await Deno.readTextFile(REPO_ROOT + "LICENSE");
  },
});

Deno.bench({
  name: "bench: read README.adoc",
  group: "file-io",
  async fn() {
    await Deno.readTextFile(REPO_ROOT + "README.adoc");
  },
});

Deno.bench({
  name: "bench: read STATE.a2ml",
  group: "file-io",
  async fn() {
    await Deno.readTextFile(REPO_ROOT + ".machine_readable/6a2/STATE.a2ml");
  },
});

Deno.bench({
  name: "bench: read src/abi/Layout.idr",
  group: "file-io",
  async fn() {
    await Deno.readTextFile(REPO_ROOT + "src/abi/Layout.idr");
  },
});

// ---------------------------------------------------------------------------
// Bench: Chat message parsing (domain workload proxies)
// ---------------------------------------------------------------------------

// Simulate a chat log line format: "TIMESTAMP PLATFORM AUTHOR: MESSAGE"
const chatLinePattern = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\s+(\w+)\s+(\w+):\s+(.+)$/;

const sampleLine = "2026-04-04T12:00:00Z slack alice: hello world this is a test message";

Deno.bench({
  name: "bench: parse single chat log line (regex)",
  group: "parsing",
  baseline: true,
  fn() {
    chatLinePattern.exec(sampleLine);
  },
});

// Simulate parsing a batch of 100 chat lines
const chatBatch = Array.from(
  { length: 100 },
  (_, i) => `2026-04-04T12:${String(i % 60).padStart(2, "0")}:00Z slack user${i}: message ${i}`,
);

Deno.bench({
  name: "bench: parse 100 chat log lines (batch)",
  group: "parsing",
  fn() {
    for (const line of chatBatch) {
      chatLinePattern.exec(line);
    }
  },
});

// ---------------------------------------------------------------------------
// Bench: SPDX regex matching
// ---------------------------------------------------------------------------

const sampleContent = `# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell

[metadata]
project = "universal-chat-extractor"
version = "0.1.0"
`.repeat(20);

Deno.bench({
  name: "bench: SPDX regex match on 1KB content",
  group: "regex",
  baseline: true,
  fn() {
    sampleContent.match(/SPDX-License-Identifier:\s*(\S+)/);
  },
});

Deno.bench({
  name: "bench: placeholder detection on 1KB content",
  group: "regex",
  fn() {
    /\{\{[A-Z_]+\}\}/.test(sampleContent);
  },
});

// ---------------------------------------------------------------------------
// Bench: Platform routing (domain workload proxy)
// ---------------------------------------------------------------------------

const PLATFORMS = new Set(["slack", "discord", "teams", "matrix", "telegram", "signal", "whatsapp", "irc", "zulip"]);

Deno.bench({
  name: "bench: Set.has platform lookup (known)",
  group: "routing",
  baseline: true,
  fn() {
    PLATFORMS.has("slack");
  },
});

Deno.bench({
  name: "bench: Set.has platform lookup (unknown)",
  group: "routing",
  fn() {
    PLATFORMS.has("somenovelchat");
  },
});

// ---------------------------------------------------------------------------
// Bench: JSON parse / serialise (metadata workload)
// ---------------------------------------------------------------------------

const jsonSample = JSON.stringify({
  project: "universal-chat-extractor",
  version: "0.1.0",
  crg_grade: "C",
  platforms: ["slack", "discord", "teams", "matrix"],
  messages: Array.from({ length: 50 }, (_, i) => ({ id: i, text: `msg ${i}` })),
});

Deno.bench({
  name: "bench: JSON.parse of metadata with messages",
  group: "parse",
  baseline: true,
  fn() {
    JSON.parse(jsonSample);
  },
});

Deno.bench({
  name: "bench: JSON.stringify of chat message object",
  group: "parse",
  fn() {
    JSON.stringify({
      timestamp: "2026-04-04T12:00:00Z",
      platform: "slack",
      author: "alice",
      content: "hello world",
    });
  },
});
