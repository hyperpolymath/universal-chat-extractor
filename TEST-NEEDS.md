# TEST-NEEDS.md — CRG Grade C Achievement Record

<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

## Status: CRG Grade C — ACHIEVED (2026-04-04)

This document records the test categories added to achieve CRG Grade C for
`universal-chat-extractor`.

---

## Context

`universal-chat-extractor` is a pre-implementation scaffold. No application
source code exists yet — only the ABI/FFI skeleton (`src/abi/*.idr`,
`ffi/zig/src/main.zig`) and RSR standard files. The ABI files still contain
`{{project}}` template placeholders requiring instantiation.

All tests validate structural and policy invariants rather than application
logic. This is the correct approach for a scaffold-stage repo.

Additionally, the unit tests include domain-specific helper functions for the
eventual chat extraction use case (timestamp validation, platform name
normalisation, known-platform lookup) to provide a meaningful unit-test
baseline that can grow alongside the implementation.

---

## CRG C Test Categories

### 1. Unit Tests — `tests/unit_test.ts`

Validates individual logical units in isolation:
- SPDX header extraction function (4 tests)
- Placeholder detection function (3 tests)
- Chat extraction domain helpers: timestamp validation (3 tests), platform lookup (3 tests)
- STATE.a2ml metadata structure (3 tests)
- LICENSE file content (2 tests)
- AI manifest presence (2 tests)

**Total: 20 tests**

### 2. Smoke Tests — `tests/smoke_test.ts`

Verifies the repo is in a functional, non-broken state:
- 15 required top-level files
- 15 required directories (including `src/abi/`)
- 6 A2ML checkpoint files
- 3 .well-known files
- ABI/FFI scaffold files (5 tests)
- SECURITY.md content
- README.adoc domain terminology

**Total: 47 tests**

### 3. Property-Based (P2P) Tests — `tests/property_test.ts`

Table-driven generative tests verifying invariants across file classes:
- All .a2ml files have SPDX headers (with documented exemptions for scaffold files)
- All .a2ml files use PMPL-1.0-or-later
- All .idr ABI files have SPDX headers
- All hook scripts have shebangs
- SPDX extraction is deterministic across 5 comment styles
- Platform name normalisation across 4 cases
- Contractile files exist and are non-empty
- README.adoc has minimum heading count

**Total: 17 tests**

### 4. E2E / Reflexive Tests — `tests/e2e_test.ts`

End-to-end validation from an external perspective:
- Self-hosting SPDX reflexive check
- All test .ts files carry SPDX headers
- 4 CI hook scripts exist and are non-empty
- ABI-FFI-README.md is coherent
- TOPOLOGY.md exists
- NOTICE is non-trivial
- Justfile has test recipe
- Deno runtime check
- 3 QUICKSTART guides
- 2 Idris2 ABI files are non-empty

**Total: 14 tests**

### 5. Contract Tests — `tests/contract_test.ts`

Verifies obligations to consumers, RSR standard, ABI/FFI architecture, and integrators:
- RSR checkpoint file locations and anti-patterns (6 tests)
- ABI/FFI architecture contract: Idris2 + Zig (4 tests)
- License policy compliance (3 tests)
- Hypatia CI integration (2 tests)
- Author attribution
- Stapeln container definition
- Contractile interface (2 tests)

**Total: 20 tests**

### 6. Aspect Tests — `tests/aspect_test.ts`

Cross-cutting concerns spanning all modules:
- Security policy (5 tests)
- Code of conduct (2 tests)
- EditorConfig consistency (3 tests)
- 7 banned file patterns
- No tsconfig.json
- 4 documentation files non-empty
- Test files use Deno.test

**Total: 23 tests**

### 7. Benchmarks — `tests/bench_test.ts`

Baselined performance of core operations (run with `deno bench`):
- File I/O: LICENSE, README.adoc, STATE.a2ml, Layout.idr (4 ops)
- Chat parsing: single line, 100-line batch (2 ops)
- Regex: SPDX match, placeholder detection (2 ops)
- Platform routing: Set.has known/unknown (2 ops)
- Parse: JSON.parse, JSON.stringify (2 ops)

**Baseline results captured 2026-04-04:**
- Single chat line parse: ~672 ns/op
- Platform Set.has (known): ~21 ns/op
- SPDX regex match: ~699 ns/op
- File read (LICENSE): ~200 µs/op

---

## Running Tests

```sh
# All test categories
deno test tests/ --allow-read

# Individual categories
deno test tests/unit_test.ts --allow-read
deno test tests/smoke_test.ts --allow-read
deno test tests/property_test.ts --allow-read
deno test tests/e2e_test.ts --allow-read
deno test tests/contract_test.ts --allow-read
deno test tests/aspect_test.ts --allow-read

# Benchmarks (separate runner)
deno bench tests/bench_test.ts --allow-read
```

---

## Notes

- Zig/Idris2 tests remain `{{project}}`-templated; run `zig build test` after instantiation.
- When application code is added, extend unit tests with actual extraction logic.
- Platform-specific extraction tests (Slack JSON, Discord exports, etc.) belong in future
  integration tests as real chat log fixtures.
- Benchmarks should be re-baselined after implementation is uploaded.
