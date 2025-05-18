{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Yam.Foreign.GL
  ( GLboolean
  , GLbyte
  , GLubyte
  , GLshort
  , GLushort
  , GLint
  , GLuint
  , GLsizei
  , GLsizeiptr
  , GLenum
  , GLbitfield
  , GLfloat
  -- Constants
  , true
  , false
  , colorBufferBit
  , arrayBuffer
  , staticDraw
  , vertexShader
  , geometryShader
  , fragmentShader
  , compileStatus
  , shaderType
  , float
  , triangles
  --  Functions
  , clear
  , clearColor
  , enable
  , genTextures
  , viewport
  , genBuffers
  , bindBuffer
  , bufferData
  , createShader
  , shaderSource
  , compileShader
  , deleteShader
  , getShaderiv
  , getShaderInfoLog
  , createProgram
  , attachShader
  , linkProgram
  , useProgram
  , vertexAttribPointer
  , enableVertexAttribArray
  , genVertexArrays
  , bindVertexArray
  , drawArrays
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
type GLsizeiptr = CPtrdiff
type GLenum = Word32
type GLbitfield = Word32
type GLfloat = CFloat
type GLclampf = CFloat

true :: Num a => a
true = 1

false :: Num a => a
false = 0

colorBufferBit :: GLbitfield
colorBufferBit = 0x4000

arrayBuffer :: GLenum
arrayBuffer = 0x8892

staticDraw :: GLenum
staticDraw = 0x88e4

vertexShader :: GLenum
vertexShader = 0x8b31

geometryShader :: GLenum
geometryShader = 0x8dd9

fragmentShader :: GLenum
fragmentShader = 0x8b30

compileStatus :: GLenum
compileStatus = 0x8b81

shaderType :: GLenum
shaderType = 0x8b4f

float :: GLenum
float = 0x1406

triangles :: GLenum
triangles = 0x4

foreign import ccall "glClear" clear :: GLbitfield -> IO ()
foreign import ccall "glClearColor" clearColor :: GLclampf -> GLclampf -> GLclampf -> GLclampf -> IO ()
foreign import ccall "glEnable" enable :: GLenum -> IO ()
foreign import ccall "glGenTextures" genTextures :: GLsizei -> Ptr GLuint -> IO GLuint
foreign import ccall "glViewport" viewport :: GLint -> GLint -> GLsizei -> GLsizei -> IO ()
foreign import ccall "glGenBuffers" genBuffers :: GLsizei -> Ptr GLuint -> IO ()
foreign import ccall "glBindBuffer" bindBuffer :: GLenum -> GLuint -> IO ()
foreign import ccall "glBufferData" bufferData :: GLenum -> GLsizeiptr -> Ptr a -> GLenum -> IO ()
foreign import ccall "glCreateShader" createShader :: GLenum -> IO GLuint
foreign import ccall "glShaderSource" shaderSource :: GLuint -> GLsizei -> Ptr CString -> Ptr GLint -> IO ()
foreign import ccall "glCompileShader" compileShader :: GLuint -> IO ()
foreign import ccall "glDeleteShader" deleteShader :: GLuint -> IO ()
foreign import ccall "glGetShaderiv" getShaderiv :: GLuint -> GLenum -> Ptr GLint -> IO ()
foreign import ccall "glGetShaderInfoLog" getShaderInfoLog :: GLuint -> GLsizei -> Ptr GLsizei -> CString -> IO ()
foreign import ccall "glCreateProgram" createProgram :: IO GLuint
foreign import ccall "glAttachShader" attachShader :: GLuint -> GLuint -> IO ()
foreign import ccall "glLinkProgram" linkProgram :: GLuint -> IO ()
foreign import ccall "glUseProgram" useProgram :: GLuint -> IO ()
foreign import ccall "glVertexAttribPointer" vertexAttribPointer :: GLuint -> GLint -> GLenum -> GLboolean -> GLsizei -> Ptr () -> IO ()
foreign import ccall "glEnableVertexAttribArray" enableVertexAttribArray :: GLuint -> IO ()
foreign import ccall "glGenVertexArrays" genVertexArrays :: GLsizei -> Ptr GLuint -> IO ()
foreign import ccall "glBindVertexArray" bindVertexArray :: GLuint -> IO ()
foreign import ccall "glDrawArrays" drawArrays :: GLenum -> GLint -> GLsizei -> IO ()

#ifdef GL_DEBUG
type DebugProc = GLenum -> GLenum -> GLuint -> GLenum -> GLsizei -> CString -> Ptr () -> IO ()

debugOutput :: GLenum
debugOutput = 0x92e0

foreign import ccall "glDebugMessageCallback" debugMessageCallback :: FunPtr DebugProc -> Ptr () -> IO ()
#endif
