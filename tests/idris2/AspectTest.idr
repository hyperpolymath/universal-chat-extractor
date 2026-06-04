-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/aspect_test.ts to Idris2, estate-rollout port 11/11.
-- 21 of 21 cross-cutting aspect tests ported. Each iterated check (BANNED_FILES,
-- DOCS, the tests/ directory walk) becomes one Idris2 test case to preserve
-- granular per-name reporting.
--
-- The TS regex for secret-leak detection in README is replaced by literal
-- substring checks against `api_key=`, `password=`, `secret=`, `token=`
-- (case-insensitive); the equivalence is exact within ASCII.

module AspectTest

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

||| True iff `content` (case-insensitively) contains any of the listed
||| secret-leak patterns of the form `<name>=`.
hasSecretLeak : String -> Bool
hasSecretLeak content =
  let lc = asciiLower content in
  isInfixOf "api_key=" lc || isInfixOf "api_key =" lc ||
  isInfixOf "password=" lc || isInfixOf "password =" lc ||
  isInfixOf "secret=" lc || isInfixOf "secret =" lc ||
  isInfixOf "token=" lc || isInfixOf "token =" lc

public export
allSuites : List TestCase
allSuites =
  [ -- ---------- Security policy ----------

    test "aspect/security: SECURITY.md exists" $ do
      ok <- fileExists "SECURITY.md"
      assertTrue "SECURITY.md present" ok

  , test "aspect/security: SECURITY.md mentions vulnerability reporting" $ do
      content <- readFileToString "SECURITY.md"
      let lc = asciiLower content
      let hasDisclosure =
            isInfixOf "vulnerabilit" lc || isInfixOf "disclosure" lc ||
            isInfixOf "report" lc       || isInfixOf "security" lc
      allPass
        [ assertTrue "SECURITY.md present" (content /= "")
        , assertTrue "SECURITY.md mentions security reporting" hasDisclosure
        ]

  , test "aspect/security: .well-known/security.txt exists" $ do
      ok <- fileExists ".well-known/security.txt"
      assertTrue ".well-known/security.txt present" ok

  , test "aspect/security: no .env files in repo" $ do
      ok <- fileExists ".env"
      assertTrue ".env must not be committed" (not ok)

  , test "aspect/security: no hardcoded secret patterns in README" $ do
      content <- readFileToString "README.adoc"
      allPass
        [ assertTrue "README.adoc present" (content /= "")
        , assertTrue "README.adoc has no hardcoded secrets"
            (not (hasSecretLeak content))
        ]

    -- ---------- Code of conduct ----------

  , test "aspect/community: CODE_OF_CONDUCT.md exists" $ do
      ok <- fileExists "CODE_OF_CONDUCT.md"
      assertTrue "CODE_OF_CONDUCT.md present" ok

  , test "aspect/community: CODE_OF_CONDUCT.md has meaningful content" $ do
      content <- readFileToString "CODE_OF_CONDUCT.md"
      assertTrue "CODE_OF_CONDUCT.md > 100 chars" (length content > 100)

    -- ---------- EditorConfig consistency ----------

  , test "aspect/formatting: .editorconfig exists" $ do
      ok <- fileExists ".editorconfig"
      assertTrue ".editorconfig present" ok

  , test "aspect/formatting: .editorconfig has root = true" $ do
      content <- readFileToString ".editorconfig"
      let lc = asciiLower content
      allPass
        [ assertTrue ".editorconfig present" (content /= "")
        , assertTrue ".editorconfig declares root = true"
            (isInfixOf "root = true" lc || isInfixOf "root=true" lc)
        ]

  , test "aspect/formatting: .editorconfig defines indent_style" $ do
      content <- readFileToString ".editorconfig"
      assertTrue "indent_style present" (isInfixOf "indent_style" content)

    -- ---------- No banned file patterns ----------
    -- TS iterates over a list; we expand to one test per name for clearer reports.

  , test "aspect/policy: banned file must not exist - package.json" $ do
      ok <- fileExists "package.json"
      assertTrue "package.json must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - package-lock.json" $ do
      ok <- fileExists "package-lock.json"
      assertTrue "package-lock.json must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - yarn.lock" $ do
      ok <- fileExists "yarn.lock"
      assertTrue "yarn.lock must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - bun.lockb" $ do
      ok <- fileExists "bun.lockb"
      assertTrue "bun.lockb must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - node_modules" $ do
      ok <- fileExists "node_modules"
      assertTrue "node_modules must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - .npmrc" $ do
      ok <- fileExists ".npmrc"
      assertTrue ".npmrc must not exist" (not ok)

  , test "aspect/policy: banned file must not exist - Dockerfile" $ do
      ok <- fileExists "Dockerfile"
      assertTrue "Dockerfile must not exist (use Containerfile)" (not ok)

    -- ---------- No tsconfig.json ----------

  , test "aspect/language: no tsconfig.json (TS only via Deno, not tsc)" $ do
      ok <- fileExists "tsconfig.json"
      assertTrue "tsconfig.json must not exist" (not ok)

    -- ---------- Documentation completeness ----------

  , test "aspect/docs: documentation file is non-empty - README.adoc" $ do
      content <- readFileToString "README.adoc"
      assertTrue "README.adoc > 50 chars" (length content > 50)

  , test "aspect/docs: documentation file is non-empty - EXPLAINME.adoc" $ do
      content <- readFileToString "EXPLAINME.adoc"
      assertTrue "EXPLAINME.adoc > 50 chars" (length content > 50)

  , test "aspect/docs: documentation file is non-empty - CONTRIBUTING.md" $ do
      content <- readFileToString "CONTRIBUTING.md"
      assertTrue "CONTRIBUTING.md > 50 chars" (length content > 50)

  , test "aspect/docs: documentation file is non-empty - ROADMAP.adoc" $ do
      content <- readFileToString "ROADMAP.adoc"
      assertTrue "ROADMAP.adoc > 50 chars" (length content > 50)

    -- ---------- All non-bench test files use Deno.test ----------
    -- The TS walks the tests/ dir; we enumerate explicitly. bench_test.ts is
    -- excluded per the TS predicate.

  , test "aspect/tests: tests/unit_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/unit_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)

  , test "aspect/tests: tests/contract_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/contract_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)

  , test "aspect/tests: tests/aspect_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/aspect_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)

  , test "aspect/tests: tests/property_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/property_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)

  , test "aspect/tests: tests/smoke_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/smoke_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)

  , test "aspect/tests: tests/e2e_test.ts uses Deno.test" $ do
      content <- readFileToString "tests/e2e_test.ts"
      assertTrue "Deno.test( present" (isInfixOf "Deno.test(" content)
  ]
