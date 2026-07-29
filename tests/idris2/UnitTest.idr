-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/unit_test.ts to Idris2, estate-rollout port 11/11.
-- 20 of 20 tests ported. SPDX-extract, placeholder, timestamp, and platform
-- helpers are reimplemented inline; metadata file lookups use file-read +
-- substring matching, which is structurally identical to the Deno original.

module UnitTest

import Test.Spec
import Data.String
import Data.List
import System.File

%default covering

-- ---------------------------------------------------------------------------
-- Inline pure helpers (mirrors of the TS regex-driven ones)
-- ---------------------------------------------------------------------------

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

||| True if first chars of xs match ys (prefix on List Char).
prefixOfChars : List Char -> List Char -> Bool
prefixOfChars _        []        = True
prefixOfChars []       (_ :: _)  = False
prefixOfChars (x :: xs) (y :: ys) = x == y && prefixOfChars xs ys

||| Drop the first n elements from a list.
dropN : Nat -> List a -> List a
dropN Z      xs        = xs
dropN _      []        = []
dropN (S k)  (_ :: xs) = dropN k xs

||| Take the substring of `s` after the first occurrence of `needle`.
||| Returns "" if `needle` not found.
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

||| The first whitespace/newline-terminated token of the given string.
firstToken : String -> String
firstToken s = pack (takeTok (unpack s))
  where
    takeTok : List Char -> List Char
    takeTok [] = []
    takeTok (c :: cs) =
      if c == ' ' || c == '\t' || c == '\n' || c == '\r'
        then []
        else c :: takeTok cs

||| Strip leading whitespace.
trimLeading : String -> String
trimLeading s = case unpack s of
  []        => s
  (c :: cs) => if c == ' ' || c == '\t'
                  then trimLeading (pack cs)
                  else s

||| Find the substring after the literal "SPDX-License-Identifier:" then return
||| the first whitespace-delimited token. Returns "" if absent.
extractSpdxId : String -> String
extractSpdxId content =
  let needle = "SPDX-License-Identifier:" in
  if isInfixOf needle content
    then firstToken (trimLeading (afterNeedle content needle))
    else ""

||| True when `c` is an uppercase ASCII letter or underscore (the placeholder
||| alphabet matched by the TS `[A-Z_]+` regex).
isUpperOrUnderscore : Char -> Bool
isUpperOrUnderscore c =
  c == '_' || (c >= 'A' && c <= 'Z')

||| Try to match `{{[A-Z_]+}}` starting at the head of the list.
matchPlaceholder : List Char -> Bool
matchPlaceholder ('{' :: '{' :: rest) = consumeBody rest False
  where
    consumeBody : List Char -> Bool -> Bool
    consumeBody [] _ = False
    consumeBody ('}' :: '}' :: _) seenOne = seenOne
    consumeBody (c :: cs) seenOne =
      if isUpperOrUnderscore c
        then consumeBody cs True
        else False
matchPlaceholder _ = False

||| Mirrors TS `/\{\{[A-Z_]+\}\}/.test(content)`. True iff `content` contains
||| `{{XXX}}` where XXX is one-or-more chars from `[A-Z_]`.
containsUnresolvedPlaceholder : String -> Bool
containsUnresolvedPlaceholder content = scan (unpack content)
  where
    scan : List Char -> Bool
    scan [] = False
    scan all@(_ :: rest) =
      if matchPlaceholder all
        then True
        else scan rest

||| True iff `c` is an ASCII digit.
isAsciiDigit : Char -> Bool
isAsciiDigit c = c >= '0' && c <= '9'

||| True iff string starts with `YYYY-MM-DD` (the TS regex `^\d{4}-\d{2}-\d{2}`).
isValidTimestamp : String -> Bool
isValidTimestamp ts = case unpack ts of
  (a :: b :: c :: d :: '-' :: e :: f :: '-' :: g :: h :: _) =>
    isAsciiDigit a && isAsciiDigit b && isAsciiDigit c && isAsciiDigit d &&
    isAsciiDigit e && isAsciiDigit f && isAsciiDigit g && isAsciiDigit h
  _ => False

||| ASCII lowercasing (avoids any locale awkwardness; sufficient for the
||| platform-name set used here).
asciiLower : String -> String
asciiLower s = pack (map low (unpack s))
  where
    low : Char -> Char
    low c =
      if c >= 'A' && c <= 'Z'
        then chr (ord c + 32)
        else c

||| True iff the (lowercased) `platform` is in the known-platform allowlist.
isKnownPlatform : String -> Bool
isKnownPlatform platform =
  let lc = asciiLower platform in
  lc == "slack" || lc == "discord" || lc == "teams" || lc == "matrix" ||
  lc == "telegram" || lc == "signal" || lc == "whatsapp" || lc == "irc" ||
  lc == "zulip"

-- ---------------------------------------------------------------------------
-- Test cases (Idris2 mirrors of Deno.test entries)
-- ---------------------------------------------------------------------------

public export
allSuites : List TestCase
allSuites =
  [ test "unit: extractSpdxId parses valid SPDX line" $ do
      let content = "// SPDX-License-Identifier: MPL-2.0\ncode"
      assertEq (extractSpdxId content) "MPL-2.0"

  , test "unit: extractSpdxId handles TOML-style comment" $ do
      let content = "# SPDX-License-Identifier: MPL-2.0\n[section]"
      assertEq (extractSpdxId content) "MPL-2.0"

  , test "unit: extractSpdxId returns empty when header absent" $ do
      assertEq (extractSpdxId "no license here") ""

  , test "unit: extractSpdxId handles leading whitespace" $ do
      let content = "   // SPDX-License-Identifier: MPL-2.0\n"
      assertEq (extractSpdxId content) "MIT"

  , test "unit: containsUnresolvedPlaceholder detects {{PROJECT}}" $ do
      assertEq (containsUnresolvedPlaceholder "name: {{PROJECT}}") True

  , test "unit: containsUnresolvedPlaceholder ignores lowercase placeholders" $ do
      assertEq (containsUnresolvedPlaceholder "fn {{project}}_init()") False

  , test "unit: containsUnresolvedPlaceholder allows clean content" $ do
      assertEq (containsUnresolvedPlaceholder "universal-chat-extractor") False

  , test "unit: isValidTimestamp accepts ISO date format" $ do
      assertEq (isValidTimestamp "2026-04-04T12:00:00Z") True

  , test "unit: isValidTimestamp accepts date-only format" $ do
      assertEq (isValidTimestamp "2026-01-01") True

  , test "unit: isValidTimestamp rejects garbage" $ do
      assertEq (isValidTimestamp "not-a-date") False

  , test "unit: isKnownPlatform accepts slack" $ do
      assertEq (isKnownPlatform "slack") True

  , test "unit: isKnownPlatform accepts discord (case insensitive)" $ do
      assertEq (isKnownPlatform "Discord") True

  , test "unit: isKnownPlatform rejects unknown platform" $ do
      assertEq (isKnownPlatform "somenovelchat") False

  , test "unit: STATE.a2ml exists and has valid project name" $ do
      content <- readFileToString ".machine_readable/6a2/STATE.a2ml"
      allPass
        [ assertTrue "STATE.a2ml non-empty" (content /= "")
        , assertTrue "project = universal-chat-extractor"
            (isInfixOf "project = \"universal-chat-extractor\"" content)
        ]

  , test "unit: STATE.a2ml has SPDX header" $ do
      content <- readFileToString ".machine_readable/6a2/STATE.a2ml"
      assertEq (extractSpdxId content) "MPL-2.0"

  , test "unit: STATE.a2ml has version field" $ do
      content <- readFileToString ".machine_readable/6a2/STATE.a2ml"
      assertTrue "version = present" (isInfixOf "version =" content)

  , test "unit: LICENSE file exists and is non-empty" $ do
      content <- readFileToString "LICENSE"
      allPass
        [ assertTrue "LICENSE present" (content /= "")
        , assertTrue "LICENSE not whitespace-only" (length content > 1)
        ]

  , test "unit: LICENSES directory contains PMPL text" $ do
      ok <- fileExists "LICENSES/MPL-2.0.txt"
      assertTrue "LICENSES/MPL-2.0.txt must exist" ok

  , test "unit: 0-AI-MANIFEST.a2ml exists" $ do
      ok <- fileExists "0-AI-MANIFEST.a2ml"
      assertTrue "0-AI-MANIFEST.a2ml must exist" ok

  , test "unit: 0-AI-MANIFEST.a2ml is non-empty" $ do
      content <- readFileToString "0-AI-MANIFEST.a2ml"
      assertTrue "0-AI-MANIFEST.a2ml non-empty" (length content > 0)
  ]
