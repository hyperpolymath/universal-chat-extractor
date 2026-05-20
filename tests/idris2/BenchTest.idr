-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/bench_test.ts to Idris2, estate-rollout port 11/11.
-- 10 of 10 bench tests ported as functional assertions (timing skipped per
-- the rollout's bucket-1 rules; this Idris2 build is not a perf harness).
--
-- For each Deno.bench fn we extract the assertion it implicitly makes
-- (the operation completes without throwing) and turn it into an
-- explicit content check: read the file is non-empty, parse the chat line
-- yields the expected fields, SPDX regex finds PMPL, platform routing
-- recognises the expected platform.

module BenchTest

import Test.Spec
import Data.String
import Data.List
import Data.Maybe
import System.File

%default covering

readFileToString : String -> IO String
readFileToString path = do
  Right contents <- readFile path
    | Left _ => pure ""
  pure contents

-- ---------------------------------------------------------------------------
-- Pure helpers redeclared (module independence)
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

||| ASCII-only chat-log line parser.
||| Expected form: "YYYY-MM-DDThh:mm:ssZ <platform> <author>: <message>".
||| Returns Nothing if the prefix is not a 20-char ISO-like timestamp followed
||| by a single space; otherwise returns (ts, platform, author, message).
parseChatLine : String -> Maybe (String, String, String, String)
parseChatLine line =
  let cs = unpack line
      tsChars = take 20 cs
      restAfterTs = drop 20 cs
  in case restAfterTs of
       (' ' :: rest) =>
         case break (== ' ') rest of
           (platChars, ' ' :: rest2) =>
             case break (== ':') rest2 of
               (authChars, ':' :: ' ' :: msgChars) =>
                 Just (pack tsChars, pack platChars, pack authChars, pack msgChars)
               _ => Nothing
           _ => Nothing
       _ => Nothing

knownPlatforms : List String
knownPlatforms =
  [ "slack", "discord", "teams", "matrix", "telegram"
  , "signal", "whatsapp", "irc", "zulip" ]

isKnownPlatform : String -> Bool
isKnownPlatform p = elem p knownPlatforms

sampleLine : String
sampleLine = "2026-04-04T12:00:00Z slack alice: hello world this is a test message"

||| Zero-padded show for Nat values up to 59 (minutes).
pad2 : Nat -> String
pad2 k = if k < 10 then "0" ++ show k else show k

||| Modulo for Nat without relying on the Integral instance.
modNat60 : Nat -> Nat
modNat60 n = if n < 60 then n else modNat60 (n `minus` 60)

||| Generate the same batch line shape the TS bench loops over.
benchLineFor : Nat -> String
benchLineFor n =
  "2026-04-04T12:" ++ pad2 (modNat60 n) ++ ":00Z slack user" ++
  show n ++ ": message " ++ show n

||| Fixed-content sample mirroring the TS `sampleContent` (used to verify the
||| SPDX extractor reliably finds the identifier in scaffold-shaped content).
sampleContent : String
sampleContent =
  "# SPDX-License-Identifier: PMPL-1.0-or-later\n" ++
  "# Copyright (c) 2026 Jonathan D.A. Jewell\n\n" ++
  "[metadata]\n" ++
  "project = \"universal-chat-extractor\"\n" ++
  "version = \"0.1.0\"\n"

||| Mirrors TS placeholder-detection regex `\{\{[A-Z_]+\}\}`. True iff a
||| `{{XXX}}` placeholder (XXX in `[A-Z_]`) is present.
containsPlaceholder : String -> Bool
containsPlaceholder content = scan (unpack content)
  where
    upper : Char -> Bool
    upper c = c == '_' || (c >= 'A' && c <= 'Z')
    inside : List Char -> Bool -> Bool
    inside [] _ = False
    inside ('}' :: '}' :: _) seen = seen
    inside (c :: cs) seen =
      if upper c then inside cs True else False
    scan : List Char -> Bool
    scan [] = False
    scan ('{' :: '{' :: rest) = if inside rest False then True else scan rest
    scan (_ :: rest) = scan rest

-- ---------------------------------------------------------------------------
-- Test cases (each bench becomes a correctness assertion)
-- ---------------------------------------------------------------------------

public export
allSuites : List TestCase
allSuites =
  [ test "bench-assert: read LICENSE - file I/O baseline" $ do
      content <- readFileToString "LICENSE"
      assertTrue "LICENSE readable and non-empty" (length content > 0)

  , test "bench-assert: read README.adoc" $ do
      content <- readFileToString "README.adoc"
      assertTrue "README.adoc readable and non-empty" (length content > 0)

  , test "bench-assert: read STATE.a2ml" $ do
      content <- readFileToString ".machine_readable/6a2/STATE.a2ml"
      assertTrue "STATE.a2ml readable and non-empty" (length content > 0)

  , test "bench-assert: read src/abi/Layout.idr" $ do
      content <- readFileToString "src/abi/Layout.idr"
      assertTrue "Layout.idr readable and non-empty" (length content > 0)

  , test "bench-assert: parse single chat log line" $ do
      case parseChatLine sampleLine of
        Nothing => assertTrue "chat line parses" False
        Just (ts, plat, auth, msg) =>
          allPass
            [ assertEq ts "2026-04-04T12:00:00Z"
            , assertEq plat "slack"
            , assertEq auth "alice"
            , assertTrue "message body non-empty" (length msg > 0)
            ]

  , test "bench-assert: parse 100 chat log lines (batch)" $ do
      -- The TS bench loops 100 lines through `chatLinePattern.exec`. The
      -- correctness assertion is that every generated line parses cleanly.
      let batch = map benchLineFor [0 .. 99]
      let parsed = map parseChatLine batch
      assertTrue "all 100 lines parsed" (all isJust parsed)

  , test "bench-assert: SPDX regex match on sample content" $
      assertEq (extractSpdxId sampleContent) "PMPL-1.0-or-later"

  , test "bench-assert: placeholder detection on sample content" $
      -- sampleContent has no `{{XXX}}` placeholder, so detection must return False.
      assertEq (containsPlaceholder sampleContent) False

  , test "bench-assert: platform lookup recognises slack" $
      assertEq (isKnownPlatform "slack") True

  , test "bench-assert: platform lookup rejects unknown" $
      assertEq (isKnownPlatform "somenovelchat") False
  ]
