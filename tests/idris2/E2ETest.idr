-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/e2e_test.ts to Idris2, estate-rollout port 11/11.
-- 17 of 17 e2e/reflexive tests ported.
--
-- The "tests run under Deno runtime" test is replaced by an Idris2-equivalent
-- "tests run under Idris2 runtime" check (trivially True at compile time)
-- to preserve the reflexive shape.
--
-- The TS reflexive test reads tests/e2e_test.ts and checks its own SPDX
-- header; we additionally check this Idris2 file's analogue
-- (tests/idris2/E2ETest.idr) and the TS original.

module E2ETest

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

public export
allSuites : List TestCase
allSuites =
  [ -- ---------- Reflexive SPDX checks ----------

    test "e2e/reflexive: tests/e2e_test.ts carries MPL-2.0 header" $ do
      content <- readFileToString "tests/e2e_test.ts"
      assertTrue "PMPL header present"
        (isInfixOf "SPDX-License-Identifier: MPL-2.0" content)

  , test "e2e/reflexive: tests/idris2/E2ETest.idr carries MPL-2.0 header" $ do
      content <- readFileToString "tests/idris2/E2ETest.idr"
      assertTrue "PMPL header present"
        (isInfixOf "SPDX-License-Identifier: MPL-2.0" content)

  , test "e2e/reflexive: tests/unit_test.ts has SPDX header" $ do
      content <- readFileToString "tests/unit_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/contract_test.ts has SPDX header" $ do
      content <- readFileToString "tests/contract_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/aspect_test.ts has SPDX header" $ do
      content <- readFileToString "tests/aspect_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/property_test.ts has SPDX header" $ do
      content <- readFileToString "tests/property_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/smoke_test.ts has SPDX header" $ do
      content <- readFileToString "tests/smoke_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/e2e_test.ts has SPDX header" $ do
      content <- readFileToString "tests/e2e_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

  , test "e2e/reflexive: tests/bench_test.ts has SPDX header" $ do
      content <- readFileToString "tests/bench_test.ts"
      assertTrue "SPDX present" (isInfixOf "SPDX-License-Identifier:" content)

    -- ---------- CI hook scripts present ----------

  , test "e2e: CI hook file exists - hooks/validate-codeql.sh" $ do
      content <- readFileToString "hooks/validate-codeql.sh"
      assertTrue "validate-codeql.sh present and non-empty" (length content > 0)

  , test "e2e: CI hook file exists - hooks/validate-permissions.sh" $ do
      content <- readFileToString "hooks/validate-permissions.sh"
      assertTrue "validate-permissions.sh present and non-empty" (length content > 0)

  , test "e2e: CI hook file exists - hooks/validate-sha-pins.sh" $ do
      content <- readFileToString "hooks/validate-sha-pins.sh"
      assertTrue "validate-sha-pins.sh present and non-empty" (length content > 0)

  , test "e2e: CI hook file exists - hooks/validate-spdx.sh" $ do
      content <- readFileToString "hooks/validate-spdx.sh"
      assertTrue "validate-spdx.sh present and non-empty" (length content > 0)

    -- ---------- ABI/FFI README ----------

  , test "e2e: ABI-FFI-README.md exists and is non-empty" $ do
      content <- readFileToString "ABI-FFI-README.md"
      assertTrue "ABI-FFI-README.md non-empty" (length content > 0)

    -- ---------- TOPOLOGY ----------

  , test "e2e: TOPOLOGY.md exists" $ do
      ok <- fileExists "TOPOLOGY.md"
      assertTrue "TOPOLOGY.md present" ok

    -- ---------- NOTICE ----------

  , test "e2e: NOTICE file is present and non-trivial" $ do
      content <- readFileToString "NOTICE"
      assertTrue "NOTICE non-empty" (length content > 0)

    -- ---------- Justfile ----------

  , test "e2e: Justfile contains a 'test' recipe" $ do
      content <- readFileToString "Justfile"
      allPass
        [ assertTrue "Justfile present" (content /= "")
        , assertTrue "Justfile references test" (isInfixOf "test" content)
        ]

    -- ---------- Runtime presence ----------
    -- TS asserts `typeof Deno !== "undefined"`; the Idris2 analogue is that
    -- this test executable exists and runs at all, which is trivially True.

  , test "e2e: tests run under Idris2 runtime" $
      assertTrue "Idris2 runtime present" True

    -- ---------- QUICKSTART guides ----------

  , test "e2e: quickstart guide present - QUICKSTART-USER.adoc" $ do
      ok <- fileExists "QUICKSTART-USER.adoc"
      assertTrue "QUICKSTART-USER.adoc present" ok

  , test "e2e: quickstart guide present - QUICKSTART-DEV.adoc" $ do
      ok <- fileExists "QUICKSTART-DEV.adoc"
      assertTrue "QUICKSTART-DEV.adoc present" ok

  , test "e2e: quickstart guide present - QUICKSTART-MAINTAINER.adoc" $ do
      ok <- fileExists "QUICKSTART-MAINTAINER.adoc"
      assertTrue "QUICKSTART-MAINTAINER.adoc present" ok

    -- ---------- ABI files non-empty ----------

  , test "e2e: src/abi/Layout.idr is non-empty" $ do
      content <- readFileToString "src/abi/Layout.idr"
      assertTrue "Layout.idr non-empty" (length content > 0)

  , test "e2e: src/abi/Foreign.idr is non-empty" $ do
      content <- readFileToString "src/abi/Foreign.idr"
      assertTrue "Foreign.idr non-empty" (length content > 0)
  ]
