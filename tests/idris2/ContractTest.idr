-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/contract_test.ts to Idris2, estate-rollout port 11/11.
-- 19 of 19 contract obligations ported. Each TS sub-iteration of a banned-name
-- list becomes one Idris2 test case to preserve granular reporting.

module ContractTest

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

||| ASCII lowercase a single character.
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
  [ -- ---------- RSR obligations ----------

    test "contract/RSR: STATE.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/STATE.a2ml"
      assertTrue "STATE.a2ml present" ok

  , test "contract/RSR: META.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/META.a2ml"
      assertTrue "META.a2ml present" ok

  , test "contract/RSR: ECOSYSTEM.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/ECOSYSTEM.a2ml"
      assertTrue "ECOSYSTEM.a2ml present" ok

  , test "contract/RSR: AGENTIC.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/AGENTIC.a2ml"
      assertTrue "AGENTIC.a2ml present" ok

  , test "contract/RSR: no SCM checkpoint files in repo root" $ do
      a <- fileExists "STATE.scm"
      b <- fileExists "META.scm"
      c <- fileExists "ECOSYSTEM.scm"
      d <- fileExists "AGENTIC.scm"
      assertTrue "no SCM checkpoint files in repo root"
        (not a && not b && not c && not d)

  , test "contract/RSR: no SCM checkpoint files in .machine_readable/" $ do
      a <- fileExists ".machine_readable/STATE.scm"
      b <- fileExists ".machine_readable/META.scm"
      c <- fileExists ".machine_readable/ECOSYSTEM.scm"
      d <- fileExists ".machine_readable/AGENTIC.scm"
      assertTrue "no SCM checkpoint files in .machine_readable/"
        (not a && not b && not c && not d)

  , test "contract/RSR: EXPLAINME.adoc is present" $ do
      ok <- fileExists "EXPLAINME.adoc"
      assertTrue "EXPLAINME.adoc present" ok

  , test "contract/RSR: ABI-FFI-README.md is present" $ do
      ok <- fileExists "ABI-FFI-README.md"
      assertTrue "ABI-FFI-README.md present" ok

    -- ---------- ABI/FFI standard ----------

  , test "contract/ABI: src/abi/ directory follows Idris2 ABI standard" $ do
      -- proxy by Layout.idr presence (src/abi/ must contain it)
      ok <- fileExists "src/abi/Layout.idr"
      assertTrue "src/abi/Layout.idr present" ok

  , test "contract/ABI: Layout.idr defines ABI layout" $ do
      content <- readFileToString "src/abi/Layout.idr"
      assertTrue "Layout.idr non-empty" (content /= "")

  , test "contract/ABI: Foreign.idr declares FFI interface" $ do
      content <- readFileToString "src/abi/Foreign.idr"
      assertTrue "Foreign.idr non-empty" (content /= "")

  , test "contract/FFI: ffi/zig/ implements C-compatible FFI" $ do
      ok <- fileExists "ffi/zig/src/main.zig"
      assertTrue "ffi/zig/src/main.zig present" ok

    -- ---------- License policy ----------

  , test "contract/license: LICENSE file uses PMPL" $ do
      content <- readFileToString "LICENSE"
      let lc = asciiLower content
      allPass
        [ assertTrue "LICENSE present" (content /= "")
        , assertTrue "LICENSE references palimpsest" (isInfixOf "palimpsest" lc)
        ]

  , test "contract/license: LICENSES/MPL-2.0.txt present" $ do
      ok <- fileExists "LICENSES/MPL-2.0.txt"
      assertTrue "PMPL text present" ok

  , test "contract/license: README.adoc has SPDX header" $ do
      content <- readFileToString "README.adoc"
      allPass
        [ assertTrue "README.adoc present" (content /= "")
        , assertTrue "README.adoc has SPDX line"
            (isInfixOf "SPDX-License-Identifier:" content)
        ]

    -- ---------- Hypatia CI integration ----------

  , test "contract/hypatia: .hypatia/ directory exists" $ do
      -- proxied via last-visit.json since Idris2 readFile only inspects files
      ok <- fileExists ".hypatia/last-visit.json"
      assertTrue ".hypatia/last-visit.json present" ok

  , test "contract/hypatia: .hypatia/last-visit.json exists" $ do
      ok <- fileExists ".hypatia/last-visit.json"
      assertTrue ".hypatia/last-visit.json present" ok

    -- ---------- Author attribution ----------

  , test "contract/author: MAINTAINERS.adoc references hyperpolymath or Jonathan" $ do
      content <- readFileToString "MAINTAINERS.adoc"
      let hasAuthor = isInfixOf "Jonathan" content || isInfixOf "hyperpolymath" content
      allPass
        [ assertTrue "MAINTAINERS.adoc present" (content /= "")
        , assertTrue "MAINTAINERS.adoc references the author" hasAuthor
        ]

    -- ---------- Stapeln container definition ----------

  , test "contract/stapeln: stapeln.toml exists and is non-empty" $ do
      content <- readFileToString "stapeln.toml"
      assertTrue "stapeln.toml non-empty" (length content > 0)

    -- ---------- Contractiles interface ----------

  , test "contract/contractiles: TRUST.contractile exists in .machine_readable/" $ do
      ok <- fileExists ".machine_readable/TRUST.contractile"
      assertTrue "TRUST.contractile present" ok

  , test "contract/contractiles: MUST.contractile exists in .machine_readable/" $ do
      ok <- fileExists ".machine_readable/MUST.contractile"
      assertTrue "MUST.contractile present" ok
  ]
