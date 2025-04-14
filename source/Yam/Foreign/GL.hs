{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Yam.Foreign.GL
  ( colorBufferBit
  , clear
  , clearColor
  , enable
  , genTextures
  , viewport
#ifdef GL_DEBUG
  , DebugProc
  , debugOutput
  , debugMessageCallback
#endif
  ) where

import Foreign
import Foreign.C

type GLboolean = CUChar
type GLbyte = Int8
type GLubyte = Word8
type GLshort = Int16
type GLushort = Word16
type GLint = Int32
type GLuint = Word32
type GLsizei = Int32
type GLenum = Word32
type GLbitfield = Word32
type GLfloat = CFloat
type GLdouble = CDouble

colorBufferBit :: GLbitfield
colorBufferBit = 0x00004000

foreign import ccall "glClear" clear :: GLbitfield -> IO ()
foreign import ccall "glClearColor" clearColor :: GLfloat -> GLfloat -> GLfloat -> GLfloat -> IO ()
foreign import ccall "glEnable" enable :: GLenum -> IO ()
foreign import ccall "glGenTextures" genTextures :: GLsizei -> Ptr GLuint -> IO GLuint
foreign import ccall "glViewport" viewport :: GLint -> GLint -> GLsizei -> GLsizei -> IO ()

#ifdef GL_DEBUG
type DebugProc = GLenum -> GLenum -> GLuint -> GLenum -> GLsizei -> CString -> Ptr () -> IO ()

debugOutput :: GLenum
debugOutput = 0x92e0

foreign import ccall "glDebugMessageCallback" debugMessageCallback :: FunPtr DebugProc -> Ptr () -> IO ()
#endif
