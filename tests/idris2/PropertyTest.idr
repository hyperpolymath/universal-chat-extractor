-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/property_test.ts to Idris2, estate-rollout port 11/11.
-- 14 of 14 property cases ported.
--
-- TS walks .machine_readable recursively at runtime to collect .a2ml files.
-- Idris2 0.8.0 has no directory-walk in the base stdlib, so the per-file
-- properties enumerate the known .a2ml files directly. The SPDX_EXEMPT list
-- (ANCHOR.a2ml, 0-AI-MANIFEST.a2ml) is honoured by simply not iterating those.
--
-- The "all .idr files in src/abi/" and "hook scripts shebang" walks are
-- similarly unrolled over the known set; missing dirs become a single
-- skip-and-pass test, matching the TS try/catch fall-through.
--
-- The SPDX-extraction property mirrors the TS pure-regex test by inlining
-- the extractor and running it over a table of comment styles.

module PropertyTest

import Test.Spec
import Data.String
import Data.List
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

-- ---------------------------------------------------------------------------
-- Inline pure helpers (same as UnitTest, redeclared for module independence)
-- ---------------------------------------------------------------------------

prefixOfChars : List Char -> List Char -> Bool
prefixOfChars _        []        = True
prefixOfChars []       (_ :: _)  = False
prefixOfChars (x :: xs) (y :: ys) = x == y && prefixOfChars xs ys

dropN : Nat -> List a -> List a
dropN Z      xs        = xs
dropN _      []        = []
dropN (S k)  (_ :: xs) = dropN k xs

afterNeedleGo : List Char -> List Char -> Nat -> String
afterNeedleGo []        _  _  = ""
afterNeedleGo cs        ns nl =
  if prefixOfChars cs ns
    then pack (dropN nl cs)
    else case cs of
      []          => ""
      (_ :: rest) => afterNeedleGo rest ns nl

afterNeedle : String -> String -> String
afterNeedle s n =
  let nc = unpack n
      nl = length nc
  in afterNeedleGo (unpack s) nc nl

firstToken : String -> String
firstToken s = pack (takeTok (unpack s))
  where
    takeTok : List Char -> List Char
    takeTok [] = []
    takeTok (c :: cs) =
      if c == ' ' || c == '\t' || c == '\n' || c == '\r'
        then []
        else c :: takeTok cs

trimLeading : String -> String
trimLeading s = case unpack s of
  []        => s
  (c :: cs) => if c == ' ' || c == '\t'
                  then trimLeading (pack cs)
                  else s

extractSpdxId : String -> String
extractSpdxId content =
  let needle = "SPDX-License-Identifier:" in
  if isInfixOf needle content
    then firstToken (trimLeading (afterNeedle content needle))
    else ""

asciiLower : String -> String
asciiLower s = pack (map low (unpack s))
  where
    low : Char -> Char
    low c =
      if c >= 'A' && c <= 'Z'
        then chr (ord c + 32)
        else c

normalisePlatform : String -> String
normalisePlatform = asciiLower . trim

-- ---------------------------------------------------------------------------
-- Enumerated file lists (replace TS recursive directory walks)
-- ---------------------------------------------------------------------------

a2mlFiles : List String
a2mlFiles =
  [ ".machine_readable/6a2/STATE.a2ml"
  , ".machine_readable/6a2/META.a2ml"
  , ".machine_readable/6a2/ECOSYSTEM.a2ml"
  , ".machine_readable/6a2/AGENTIC.a2ml"
  , ".machine_readable/6a2/NEUROSYM.a2ml"
  , ".machine_readable/6a2/PLAYBOOK.a2ml"
  , ".machine_readable/CLADE.a2ml"
  ]

abiIdrFiles : List String
abiIdrFiles =
  [ "src/abi/Layout.idr"
  , "src/abi/Foreign.idr"
  ]

hookScripts : List String
hookScripts =
  [ "hooks/validate-codeql.sh"
  , "hooks/validate-permissions.sh"
  , "hooks/validate-sha-pins.sh"
  , "hooks/validate-spdx.sh"
  ]

||| All listed files (skipped if absent) carry an SPDX header.
allSpdxOk : List String -> IO Bool
allSpdxOk [] = pure True
allSpdxOk (f :: fs) = do
  exists <- fileExists f
  if not exists
    then allSpdxOk fs
    else do
      content <- readFileToString f
      if isInfixOf "SPDX-License-Identifier:" content
        then allSpdxOk fs
        else do
          putStrLn ""
          putStrLn ("  missing SPDX header in " ++ f)
          pure False

||| All listed files (skipped if absent) use exactly `PMPL-1.0-or-later`.
allPmplOk : List String -> IO Bool
allPmplOk [] = pure True
allPmplOk (f :: fs) = do
  exists <- fileExists f
  if not exists
    then allPmplOk fs
    else do
      content <- readFileToString f
      let id = extractSpdxId content
      if id == "" || id == "PMPL-1.0-or-later"
        then allPmplOk fs
        else do
          putStrLn ""
          putStrLn ("  expected PMPL-1.0-or-later in " ++ f ++ ", got " ++ id)
          pure False

||| All listed shell scripts (skipped if absent) start with a shebang.
allShebangOk : List String -> IO Bool
allShebangOk [] = pure True
allShebangOk (f :: fs) = do
  exists <- fileExists f
  if not exists
    then allShebangOk fs
    else do
      content <- readFileToString f
      if isPrefixOf "#!" content
        then allShebangOk fs
        else do
          putStrLn ""
          putStrLn ("  missing shebang in " ++ f)
          pure False

-- ---------------------------------------------------------------------------
-- Tests
-- ---------------------------------------------------------------------------

||| Heading-line predicate for AsciiDoc: a line consisting of one or more '='
||| followed by a space and a non-empty title.
hasHeadingBody : List Char -> Bool
hasHeadingBody ('=' :: rs) = hasHeadingBody rs
hasHeadingBody (' ' :: rs) = not (rs == [])
hasHeadingBody _           = False

isAdocHeading : String -> Bool
isAdocHeading line =
  case unpack line of
    ('=' :: rest) => hasHeadingBody rest
    _             => False

public export
allSuites : List TestCase
allSuites =
  [ test "property: every .a2ml file has SPDX-License-Identifier header" $
      allSpdxOk a2mlFiles

  , test "property: all .a2ml files use PMPL-1.0-or-later" $
      allPmplOk a2mlFiles

  , test "property: all .idr files in src/abi/ have SPDX headers" $
      allSpdxOk abiIdrFiles

  , test "property: all hook scripts have bash/sh shebang" $
      allShebangOk hookScripts

    -- SPDX-extract handles a table of comment styles (table-driven).

  , test "property: SPDX extraction handles comment style \"# SPDX...\"" $
      assertEq (extractSpdxId "# SPDX-License-Identifier: PMPL-1.0-or-later") "PMPL-1.0-or-later"

  , test "property: SPDX extraction handles comment style \"// SPDX...\"" $
      assertEq (extractSpdxId "// SPDX-License-Identifier: PMPL-1.0-or-later") "PMPL-1.0-or-later"

  , test "property: SPDX extraction handles comment style \"/* SPDX...\"" $
      assertEq (extractSpdxId "/* SPDX-License-Identifier: MIT */") "MIT"

  , test "property: SPDX extraction handles comment style \"; SPDX...\"" $
      assertEq (extractSpdxId "; SPDX-License-Identifier: Apache-2.0") "Apache-2.0"

  , test "property: SPDX extraction handles comment style \"-- SPDX...\"" $
      assertEq (extractSpdxId "-- SPDX-License-Identifier: GPL-3.0-only") "GPL-3.0-only"

    -- Platform-name canonicalisation (table-driven).

  , test "property: platform name normalises \"Slack\" -> \"slack\"" $
      assertEq (normalisePlatform "Slack") "slack"

  , test "property: platform name normalises \"  Discord  \" -> \"discord\"" $
      assertEq (normalisePlatform "  Discord  ") "discord"

  , test "property: platform name normalises \"TEAMS\" -> \"teams\"" $
      assertEq (normalisePlatform "TEAMS") "teams"

  , test "property: platform name normalises \"Matrix\" -> \"matrix\"" $
      assertEq (normalisePlatform "Matrix") "matrix"

    -- Contractile presence. TS iterates dust/Dustfile, must/Mustfile,
    -- lust/Intentfile. NOTE: contractiles/lust/Intentfile is not present in
    -- this repo; the TS test would currently fail on it too. We mirror the
    -- iteration faithfully so the Idris2 port preserves the TS semantics
    -- (one test per name, missing path -> failure). See the source-bug note
    -- in the port report.

  , test "property: contractile file exists and non-empty - contractiles/dust/Dustfile" $ do
      ok <- fileExists "contractiles/dust/Dustfile"
      content <- readFileToString "contractiles/dust/Dustfile"
      assertTrue "Dustfile present and non-empty" (ok && length content > 0)

  , test "property: contractile file exists and non-empty - contractiles/must/Mustfile" $ do
      ok <- fileExists "contractiles/must/Mustfile"
      content <- readFileToString "contractiles/must/Mustfile"
      assertTrue "Mustfile present and non-empty" (ok && length content > 0)

  , test "property: contractile file exists and non-empty - contractiles/lust/Intentfile" $ do
      -- SOURCE BUG: contractiles/lust/Intentfile is referenced by the TS
      -- iteration but the corresponding directory does not exist in this
      -- repo (contractiles/ only contains dust/ and must/). The TS test
      -- would also fail. Reported separately; this Idris2 port keeps the
      -- assertion so the bug remains visible.
      ok <- fileExists "contractiles/lust/Intentfile"
      content <- readFileToString "contractiles/lust/Intentfile"
      assertTrue "Intentfile present and non-empty (KNOWN SOURCE BUG)" (ok && length content > 0)

    -- README.adoc heading count: TS counts /^={1,6}\s+.+/gm matches and
    -- requires >= 3. Idris2 substitute counts lines that start with "= ",
    -- "== ", ..., "====== " (with a trailing non-empty rest).

  , test "property: README.adoc contains at least 3 AsciiDoc section headings" $ do
      content <- readFileToString "README.adoc"
      let headings = filter isAdocHeading (lines content)
      let n = length headings
      assertTrue ("README.adoc heading count = " ++ show n) (n >= 3)
  ]
