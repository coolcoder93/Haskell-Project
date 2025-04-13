{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Yam.Foreign.GLFW
  ( Window
  , WindowSize (..)
  , Yam.Foreign.GLFW.init
  , terminate
  , withWindow
  , windowShouldClose
  , swapBuffers
  , pollEvents
  ) where

import Foreign
import Foreign.C
import Control.Monad
import Text.Printf (printf)

import qualified Yam.Foreign.GL as GL

foreign import ccall "GLFW/glfw3.h glfwSetErrorCallback" glfwSetErrorCallback :: GLFWErrorFun -> GLFWErrorFun
--foreign import ccall "GLFW/glfw3.h glfwGetError" glfwGetError ::

foreign import ccall "GLFW/glfw3.h glfwInit" glfwInit :: IO CInt
foreign import ccall "GLFW/glfw3.h glfwTerminate" terminate :: IO ()

foreign import ccall "GLFW/glfw3.h glfwWindowHint" glfwWindowHint :: CInt -> CInt -> IO ()

foreign import ccall "GLFW/glfw3.h glfwCreateWindow"
  glfwCreateWindow :: CInt -> CInt -> CString -> GLFWMonitor -> GLFWWindow -> IO GLFWWindow
foreign import ccall "GLFW/glfw3.h glfwDestroyWindow" glfwDestroyWindow :: GLFWWindow -> IO ()

foreign import ccall "GLFW/glfw3.h glfwMakeContextCurrent" glfwMakeContextCurrent :: GLFWWindow -> IO ()
foreign import ccall "GLFW/glfw3.h glfwWindowShouldClose" glfwWindowShouldClose :: GLFWWindow -> IO CInt
foreign import ccall "GLFW/glfw3.h glfwSwapBuffers" glfwSwapBuffers :: GLFWWindow -> IO ()
foreign import ccall "GLFW/glfw3.h glfwPollEvents" pollEvents :: IO ()

type GLFWWindow = Ptr ()
type GLFWMonitor = Ptr ()
type GLFWErrorFun = FunPtr (CInt -> CString -> IO ())

newtype Window = Window GLFWWindow

data WindowSize = WindowSize
  { width :: Int
  , height :: Int
  }

glfwTrue :: CInt
glfwTrue = 1

glfwFalse :: CInt
glfwFalse = 0

glfwOpenGLProfile :: CInt
glfwOpenGLProfile = 0x00022008

glfwOpenGLCoreProfile :: CInt
glfwOpenGLCoreProfile = 0x00032001

glfwContextVersionMajor :: CInt
glfwContextVersionMajor = 0x00022002

glfwContextVersionMinor :: CInt
glfwContextVersionMinor = 0x00022003

glfwOpenGLForwardCompat :: CInt
glfwOpenGLForwardCompat = 0x00022006

init :: IO Bool
init = do
  -- TODO: Implement error callback
  --glfwSetErrorCallback (\x y -> do return ())
  result <- glfwInit
  return (result == glfwTrue)

withWindow :: String -> WindowSize -> (Window -> IO a) -> IO a
withWindow title windowSize body =
  withCString title $ \cTitle -> do
    glfwWindowHint glfwOpenGLProfile glfwOpenGLCoreProfile
    glfwWindowHint glfwContextVersionMajor 3
    glfwWindowHint glfwContextVersionMinor 3
#ifdef __APPLE__
    glfwWindowHint glfwOpenGLForwardCompat glfwTrue
#error SUCCESS!
#endif
    window <-
      glfwCreateWindow
        (fromIntegral (width windowSize))
        (fromIntegral (height windowSize))
        cTitle
        nullPtr
        nullPtr
    when (window == nullPtr) $ do
      error "GLFW: Failed to create window"
    glfwMakeContextCurrent window
#ifdef GL_DEBUG
    glDebugSetup
#endif
    result <- body (Window window)
    glfwDestroyWindow window
    return result

windowShouldClose :: Window -> IO Bool
windowShouldClose (Window handle) = do
  result <- glfwWindowShouldClose handle
  return (result == glfwTrue)

swapBuffers :: Window -> IO ()
swapBuffers (Window handle) = glfwSwapBuffers handle

#ifdef GL_DEBUG
foreign import ccall "wrapper" wrapDebug :: GL.DebugProc -> IO (FunPtr GL.DebugProc)

glDebugSetup = do
  debugProc <-
    wrapDebug $
    \_ debugType _ _  _ cMessage _ -> do
      message <- peekCString cMessage
      printf "OpenGL: %s message: \"%s\"\n"
        (if debugType == debugTypeError then "*OpenGL Error*" else "")
        message
  GL.enable GL.debugOutput
  GL.debugMessageCallback debugProc nullPtr
  where
    debugTypeError = 0x824c
#endif
