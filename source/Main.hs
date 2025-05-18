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
loop window vao shaderProgram = do
  result <- GLFW.windowShouldClose window
  unless result $ do
    GL.useProgram shaderProgram
    GL.bindVertexArray vao
    GL.drawArrays GL.triangles 0 3

    GL.clear GL.colorBufferBit
    GLFW.swapBuffers window
    GLFW.pollEvents
    loop window vao shaderProgram

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

setupShader :: String -> GL.GLenum -> IO GL.GLuint
setupShader shaderSource shaderType = do
  shader <- GL.createShader shaderType
  withCString shaderSource $ \source -> -- TODO: Move all these with* into function
    with source $ \sourcePtr ->
      GL.shaderSource shader 1 sourcePtr nullPtr
  GL.compileShader shader
  -- TODO: How should we handle errors? return a Maybe?
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
    alloca $ \vao -> do
      GL.genVertexArrays 1 vao
      vaoValue <- peek vao
      GL.bindVertexArray vaoValue
      -- Buffer setup
      alloca $ \bufferPtr -> do
        GL.genBuffers 1 bufferPtr
        buffer <- peek bufferPtr
        GL.bindBuffer GL.arrayBuffer buffer
        verticies <- getVerticies
        GL.bufferData GL.arrayBuffer (9*4) verticies GL.staticDraw
      -- Shader setup
      vertexShader <- setupShader vertexShaderSource GL.vertexShader
      fragmentShader <- setupShader fragmentShaderSource GL.fragmentShader
      shaderProgram <- GL.createProgram
      GL.attachShader shaderProgram vertexShader
      GL.attachShader shaderProgram fragmentShader
      GL.linkProgram shaderProgram -- TODO: Error handling/checking
      GL.useProgram shaderProgram
      GL.deleteShader vertexShader
      GL.deleteShader fragmentShader
      -- Vertex attributes
      GL.vertexAttribPointer 0 3 GL.float GL.false 12 nullPtr
      GL.enableVertexAttribArray 0
      -- Entering main loop
      GL.clearColor 1.0 0.0 0.0 1.0
      loop window vaoValue shaderProgram
  GLFW.terminate
