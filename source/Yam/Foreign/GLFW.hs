{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Yam.Foreign.GLFW
  ( Window
  , WindowSize (..)
  , getError
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

foreign import ccall "GLFW/glfw3.h glfwSetErrorCallback" glfwSetErrorCallback :: FunPtr GLFWErrorFun -> IO (FunPtr GLFWErrorFun)
foreign import ccall "GLFW/glfw3.h glfwGetError" glfwGetError :: Ptr CString -> IO CInt
foreign import ccall "wrapper" mkGLFWErrorFun :: GLFWErrorFun -> IO (FunPtr GLFWErrorFun)

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
type GLFWErrorFun = CInt -> CString -> IO ()

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

getError :: IO (Maybe String)
getError = alloca $ \ptr -> do
  let noError = 0
  errorCode <- glfwGetError ptr
  if errorCode == noError
    then return Nothing
    else do
      cMessage <- peek ptr
      message <- peekCString cMessage
      return (Just message)

errorCallback :: Int -> String -> IO ()
errorCallback = printf "GLFW Error %d: %s\n"

init :: IO Bool
init = do
  let cErrorCallback errorCode cMessage = do
        message <- peekCString cMessage
        errorCallback (fromIntegral errorCode) message
  funPtr <- (mkGLFWErrorFun cErrorCallback)
  _ <- glfwSetErrorCallback funPtr
  result <- glfwInit
  return (result == glfwTrue)

withWindow :: String -> WindowSize -> (Window -> IO a) -> IO a
withWindow title windowSize body =
  withCString title $ \cTitle -> do
    glfwWindowHint glfwOpenGLProfile glfwOpenGLCoreProfile
    glfwWindowHint glfwContextVersionMajor 3
    glfwWindowHint glfwContextVersionMinor 3
#ifdef darwin_HOST_OS
    glfwWindowHint glfwOpenGLForwardCompat glfwTrue
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
foreign import ccall "wrapper" mkDebugProc :: GL.DebugProc -> IO (FunPtr GL.DebugProc)

debugProc _ debugType _ _  _ cMessage _ = do
  message <- peekCString cMessage
  printf "OpenGL: %s message: \"%s\"\n"
    (if debugType == debugTypeError then "*OpenGL Error*" else "")
    message

glDebugSetup = do
  funPtr <- mkDebugProc debugProc
  GL.enable GL.debugOutput
  GL.debugMessageCallback funPtr nullPtr
  where
    debugTypeError = 0x824c
#endif
