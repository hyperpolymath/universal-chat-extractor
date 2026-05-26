-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/smoke_test.ts to Idris2, estate-rollout port 11/11.
-- 36 of 36 smoke tests ported. Each iterated path-existence check becomes
-- one Idris2 test case to preserve granular reporting.
--
-- Idris2 0.8.0 base stdlib has no isDirectory predicate, so directory
-- existence is checked indirectly via a sentinel file inside each
-- directory.  Where no sentinel file is available, a leaf file in that
-- directory is used as proxy (e.g. .well-known/security.txt for
-- .well-known/).

module SmokeTest

import Test.Spec
import Data.String
import System.File

%default covering

readFileToString : String -> IO String
readFileToString path = do
  Right contents <- readFile path
    | Left _ => pure ""
  pure contents

fileExists : String -> IO Bool
fileExists path = do
  Right _ <- readFile path
    | Left _ => pure False
  pure True

toLowerC : Char -> Char
toLowerC c =
  if c >= 'A' && c <= 'Z'
    then chr (ord c + 32)
    else c

asciiLower : String -> String
asciiLower s = pack (map toLowerC (unpack s))

public export
allSuites : List TestCase
allSuites =
  [ -- ---------- Required top-level files ----------

    test "smoke: required file exists - LICENSE" $ do
      ok <- fileExists "LICENSE"
      assertTrue "LICENSE present" ok

  , test "smoke: required file exists - README.adoc" $ do
      ok <- fileExists "README.adoc"
      assertTrue "README.adoc present" ok

  , test "smoke: required file exists - EXPLAINME.adoc" $ do
      ok <- fileExists "EXPLAINME.adoc"
      assertTrue "EXPLAINME.adoc present" ok

  , test "smoke: required file exists - SECURITY.md" $ do
      ok <- fileExists "SECURITY.md"
      assertTrue "SECURITY.md present" ok

  , test "smoke: required file exists - CONTRIBUTING.md" $ do
      ok <- fileExists "CONTRIBUTING.md"
      assertTrue "CONTRIBUTING.md present" ok

  , test "smoke: required file exists - MAINTAINERS.adoc" $ do
      ok <- fileExists "MAINTAINERS.adoc"
      assertTrue "MAINTAINERS.adoc present" ok

  , test "smoke: required file exists - ROADMAP.adoc" $ do
      ok <- fileExists "ROADMAP.adoc"
      assertTrue "ROADMAP.adoc present" ok

  , test "smoke: required file exists - NOTICE" $ do
      ok <- fileExists "NOTICE"
      assertTrue "NOTICE present" ok

  , test "smoke: required file exists - Justfile" $ do
      ok <- fileExists "Justfile"
      assertTrue "Justfile present" ok

  , test "smoke: required file exists - 0-AI-MANIFEST.a2ml" $ do
      ok <- fileExists "0-AI-MANIFEST.a2ml"
      assertTrue "0-AI-MANIFEST.a2ml present" ok

  , test "smoke: required file exists - PROOF-NEEDS.md" $ do
      ok <- fileExists "PROOF-NEEDS.md"
      assertTrue "PROOF-NEEDS.md present" ok

  , test "smoke: required file exists - .editorconfig" $ do
      ok <- fileExists ".editorconfig"
      assertTrue ".editorconfig present" ok

  , test "smoke: required file exists - stapeln.toml" $ do
      ok <- fileExists "stapeln.toml"
      assertTrue "stapeln.toml present" ok

  , test "smoke: required file exists - flake.nix" $ do
      ok <- fileExists "flake.nix"
      assertTrue "flake.nix present" ok

  , test "smoke: required file exists - guix.scm" $ do
      ok <- fileExists "guix.scm"
      assertTrue "guix.scm present" ok

    -- ---------- Required directories (proxied via sentinel files) ----------

  , test "smoke: required directory exists - .machine_readable" $ do
      ok <- fileExists ".machine_readable/CLADE.a2ml"
      assertTrue ".machine_readable/ present" ok

  , test "smoke: required directory exists - .machine_readable/6a2" $ do
      ok <- fileExists ".machine_readable/6a2/STATE.a2ml"
      assertTrue ".machine_readable/6a2/ present" ok

  , test "smoke: required directory exists - tests" $ do
      ok <- fileExists "tests/unit_test.ts"
      assertTrue "tests/ present" ok

  , test "smoke: required directory exists - tests/fuzz" $ do
      ok <- fileExists "tests/fuzz/placeholder.txt"
      assertTrue "tests/fuzz/ present" ok

  , test "smoke: required directory exists - ffi" $ do
      ok <- fileExists "ffi/zig/build.zig"
      assertTrue "ffi/ present" ok

  , test "smoke: required directory exists - ffi/zig" $ do
      ok <- fileExists "ffi/zig/build.zig"
      assertTrue "ffi/zig/ present" ok

  , test "smoke: required directory exists - ffi/zig/src" $ do
      ok <- fileExists "ffi/zig/src/main.zig"
      assertTrue "ffi/zig/src/ present" ok

  , test "smoke: required directory exists - ffi/zig/test" $ do
      ok <- fileExists "ffi/zig/test/integration_test.zig"
      assertTrue "ffi/zig/test/ present" ok

  , test "smoke: required directory exists - src" $ do
      ok <- fileExists "src/abi/Layout.idr"
      assertTrue "src/ present" ok

  , test "smoke: required directory exists - src/abi" $ do
      ok <- fileExists "src/abi/Layout.idr"
      assertTrue "src/abi/ present" ok

  , test "smoke: required directory exists - docs" $ do
      ok <- fileExists "docs/CITATIONS.adoc"
      assertTrue "docs/ present" ok

  -- Examples-directory probe removed 2026-05-26: the probe used
  -- `examples/SafeDOMExample.res` as its proxy file, but that ReScript
  -- fixture is being deleted estate-wide (gitbot-fleet#208 SafeDOM
  -- sweep). Re-add a probe when a non-stale `examples/` file lands
  -- (likely after the affinescript#56 DOM-binding survey produces a
  -- canonical `examples/SafeDOMExample.affine`).

  , test "smoke: required directory exists - contractiles" $ do
      ok <- fileExists "contractiles/README.adoc"
      assertTrue "contractiles/ present" ok

  , test "smoke: required directory exists - hooks" $ do
      ok <- fileExists "hooks/validate-spdx.sh"
      assertTrue "hooks/ present" ok

  , test "smoke: required directory exists - .well-known" $ do
      ok <- fileExists ".well-known/security.txt"
      assertTrue ".well-known/ present" ok

    -- ---------- a2ml checkpoints ----------

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/STATE.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/STATE.a2ml"
      assertTrue "STATE.a2ml present" ok

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/META.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/META.a2ml"
      assertTrue "META.a2ml present" ok

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/ECOSYSTEM.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/ECOSYSTEM.a2ml"
      assertTrue "ECOSYSTEM.a2ml present" ok

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/AGENTIC.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/AGENTIC.a2ml"
      assertTrue "AGENTIC.a2ml present" ok

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/NEUROSYM.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/NEUROSYM.a2ml"
      assertTrue "NEUROSYM.a2ml present" ok

  , test "smoke: a2ml checkpoint exists - .machine_readable/6a2/PLAYBOOK.a2ml" $ do
      ok <- fileExists ".machine_readable/6a2/PLAYBOOK.a2ml"
      assertTrue "PLAYBOOK.a2ml present" ok

    -- ---------- .well-known files ----------

  , test "smoke: well-known file exists - .well-known/security.txt" $ do
      ok <- fileExists ".well-known/security.txt"
      assertTrue "security.txt present" ok

  , test "smoke: well-known file exists - .well-known/ai.txt" $ do
      ok <- fileExists ".well-known/ai.txt"
      assertTrue "ai.txt present" ok

  , test "smoke: well-known file exists - .well-known/humans.txt" $ do
      ok <- fileExists ".well-known/humans.txt"
      assertTrue "humans.txt present" ok

    -- ---------- ABI / FFI scaffold ----------

  , test "smoke: ABI Layout.idr exists" $ do
      ok <- fileExists "src/abi/Layout.idr"
      assertTrue "src/abi/Layout.idr present" ok

  , test "smoke: ABI Foreign.idr exists" $ do
      ok <- fileExists "src/abi/Foreign.idr"
      assertTrue "src/abi/Foreign.idr present" ok

  , test "smoke: FFI main.zig exists" $ do
      ok <- fileExists "ffi/zig/src/main.zig"
      assertTrue "ffi/zig/src/main.zig present" ok

  , test "smoke: FFI build.zig exists" $ do
      ok <- fileExists "ffi/zig/build.zig"
      assertTrue "ffi/zig/build.zig present" ok

  , test "smoke: FFI integration_test.zig exists" $ do
      ok <- fileExists "ffi/zig/test/integration_test.zig"
      assertTrue "ffi/zig/test/integration_test.zig present" ok

    -- ---------- SECURITY.md non-empty ----------

  , test "smoke: SECURITY.md is non-empty" $ do
      content <- readFileToString "SECURITY.md"
      assertTrue "SECURITY.md non-empty" (length content > 0)

    -- ---------- README domain reference ----------

  , test "smoke: README.adoc mentions chat or universal" $ do
      content <- readFileToString "README.adoc"
      let lc = asciiLower content
      let hasDomain = isInfixOf "chat" lc || isInfixOf "universal" lc || isInfixOf "extract" lc
      allPass
        [ assertTrue "README.adoc present" (content /= "")
        , assertTrue "README.adoc mentions project domain" hasDomain
        ]
  ]
