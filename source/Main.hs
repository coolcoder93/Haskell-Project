module Main (main) where

import Control.Monad
import Text.Printf (printf)
import Foreign
import Foreign.C

import qualified Yam.Foreign.GL as GL
import qualified Yam.Foreign.GLFW as GLFW

getVerticies :: IO (Ptr CFloat)
getVerticies = newArray [-0.5, -0.5, 0.0,
                          0.5, -0.5, 0.0,
                          0.0,  0.5, 0.0]

loop :: GLFW.Window -> GL.GLuint -> GL.GLuint -> IO ()
loop window vertexArray shaderProgram = do
  result <- GLFW.windowShouldClose window
  unless result $ do
    GL.clear GL.colorBufferBit

    GL.useProgram shaderProgram
    GL.bindVertexArray vertexArray
    GL.drawArrays GL.triangles 0 3

    GLFW.swapBuffers window
    GLFW.pollEvents
    loop window vertexArray shaderProgram

getShaderType :: GL.GLuint -> IO String
getShaderType shader =
  alloca $ \shaderType -> do
    GL.getShaderiv shader GL.shaderType shaderType
    shaderTypeValue <- peek shaderType
    return $! whichShader shaderTypeValue
  where
    whichShader x
      | x == fromIntegral GL.vertexShader = "Vertex"
      | x == fromIntegral GL.fragmentShader = "Fragment"
      | x == fromIntegral GL.geometryShader = "Geometry"
      | otherwise = "Unkown"

printShaderCompilationError :: GL.GLuint -> IO ()
printShaderCompilationError shader =
  allocaBytes 512 $ \infoLog -> do
    GL.getShaderInfoLog shader 512 nullPtr infoLog
    infoLogValue <- peekCString infoLog
    shaderType <- getShaderType shader
    printf "%s shader compilation failed: %s\n" shaderType infoLogValue

setupShader :: GL.GLenum -> String -> IO GL.GLuint
setupShader shaderType shaderSource = do
  shader <- GL.createShader shaderType
  withCString shaderSource $ \source -> -- TODO: Move all these with* into function
    with source $ \sourcePtr ->
      GL.shaderSource shader 1 sourcePtr nullPtr
  GL.compileShader shader
  -- TODO: How should we handle errors? return a Maybe?
  -- TODO: Same pattern is used for shader program, HOF could probably be used here
  alloca $ \success -> do
    GL.getShaderiv shader GL.compileStatus success
    successValue <- peek success
    when (successValue /= GL.true) $
      printShaderCompilationError shader
  return shader

main :: IO ()
main = do
  result <- GLFW.init
  unless result $
    return ()
  vertexShaderSource <- readFile "shader.vert"
  fragmentShaderSource <- readFile "shader.frag"
  GLFW.withWindow "Game" 1280 720 $ \window -> do
    -- Shader setup
    vertexShader <- setupShader GL.vertexShader vertexShaderSource
    fragmentShader <- setupShader GL.fragmentShader fragmentShaderSource
    shaderProgram <- GL.createProgram
    GL.attachShader shaderProgram vertexShader
    GL.attachShader shaderProgram fragmentShader
    GL.linkProgram shaderProgram
    alloca $ \success -> do
      GL.getProgramiv shaderProgram GL.linkStatus success
      successValue <- peek success
      when (successValue /= GL.true) $
        allocaBytes 512 $ \infoLog -> do
          GL.getProgramInfoLog shaderProgram 512 nullPtr infoLog
          infoLogValue <- peekCString infoLog
          printf "Shader program linking failed: %s\n" infoLogValue
    GL.deleteShader vertexShader
    GL.deleteShader fragmentShader

    alloca $ \vertexArrayPtr -> do
      GL.genVertexArrays 1 vertexArrayPtr
      vertexArray <- peek vertexArrayPtr
      GL.bindVertexArray vertexArray
      -- Buffer setup
      alloca $ \bufferPtr -> do
        GL.genBuffers 1 bufferPtr
        buffer <- peek bufferPtr
        GL.bindBuffer GL.arrayBuffer buffer
        verticies <- getVerticies
        GL.bufferData GL.arrayBuffer (9*4) verticies GL.staticDraw

        -- Vertex attributes
        GL.vertexAttribPointer 0 3 GL.float GL.false 12 nullPtr
        GL.enableVertexAttribArray 0

        GL.bindBuffer GL.arrayBuffer 0
        GL.bindVertexArray 0
      -- Entering main loop
      GL.clearColor 0.2 0.3 0.3 1.0
      loop window vertexArray shaderProgram
  GLFW.terminate
