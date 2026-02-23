||| UNIVERSAL-CHAT-EXTRACTOR — FFI Bridge Declarations
|||
||| This module defines the formal bridge to the native chat-extraction 
||| kernel. It provides the low-level signatures required to process 
||| heterogeneous chat logs (Slack, Discord, Teams) via a unified API.

module UNIVERSAL_CHAT_EXTRACTOR.ABI.Foreign

import UNIVERSAL_CHAT_EXTRACTOR.ABI.Types
import UNIVERSAL_CHAT_EXTRACTOR.ABI.Layout

%default total

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

||| Initializes the extraction engine.
export
%foreign "C:chat_extractor_init, libextractor"
prim__init : PrimIO Bits64

||| Safe initialization wrapper.
export
init : IO (Maybe Handle)
init = do
  ptr <- primIO prim__init
  pure (createHandle ptr)

||| Shuts down the engine and releases native buffers.
export
%foreign "C:chat_extractor_free, libextractor"
prim__free : Bits64 -> PrimIO ()

||| Safe cleanup wrapper.
export
free : Handle -> IO ()
free h = primIO (prim__free (handlePtr h))
