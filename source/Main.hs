module Main (main) where

import Control.Monad

import qualified Yam.Foreign.GL as GL
import qualified Yam.Foreign.GLFW as GLFW

loop :: GLFW.Window -> IO ()
loop window = do
  result <- GLFW.windowShouldClose window
  unless result $ do
    GL.clearColor 1.0 0.0 0.0 1.0
    GL.clear GL.colorBufferBit
    GLFW.swapBuffers window
    GLFW.pollEvents
    loop window

main :: IO ()
main = do
  result <- GLFW.init
  unless result $
    return ()
  GLFW.withWindow "Game" 1280 720 $ \window ->
    loop window
  GLFW.terminate
