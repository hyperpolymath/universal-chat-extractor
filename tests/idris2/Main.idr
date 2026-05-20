-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

module Main

import Test.Spec
import UnitTest
import ContractTest
import AspectTest
import PropertyTest
import SmokeTest
import E2ETest
import BenchTest
import System

%default covering

main : IO ()
main = do
  (p1, f1) <- runTestSuite "UnitTest"     UnitTest.allSuites
  (p2, f2) <- runTestSuite "ContractTest" ContractTest.allSuites
  (p3, f3) <- runTestSuite "AspectTest"   AspectTest.allSuites
  (p4, f4) <- runTestSuite "PropertyTest" PropertyTest.allSuites
  (p5, f5) <- runTestSuite "SmokeTest"    SmokeTest.allSuites
  (p6, f6) <- runTestSuite "E2ETest"      E2ETest.allSuites
  (p7, f7) <- runTestSuite "BenchTest"    BenchTest.allSuites
  let totalPassed = p1 + p2 + p3 + p4 + p5 + p6 + p7
  let totalFailed = f1 + f2 + f3 + f4 + f5 + f6 + f7
  putStrLn ""
  putStrLn $ "=== Total: " ++ show totalPassed ++ " passed, " ++ show totalFailed ++ " failed ==="
  if totalFailed > 0
    then exitWith (ExitFailure 1)
    else pure ()
