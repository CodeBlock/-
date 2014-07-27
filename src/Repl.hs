module Main where

import Control.Applicative
import Control.Monad
import Control.Monad.IO.Class
import Data.Maybe (listToMaybe)
import Data.Monoid
import Language.Dash.Parser
import Language.Dash.Evaluate
import Text.Trifecta
import System.Console.Haskeline
import System.Environment (getArgs)
import System.IO

main :: IO ()
main = do
  filename <- listToMaybe <$> getArgs
  case filename of
    Just name -> readFile name >>= evalString
    Nothing   -> repl

repl :: IO ()
repl = do
  hSetBuffering stdout NoBuffering
  putStrLn "λ Welcome to dash! λ"
  runInputT defaultSettings loop
  where
    loop :: InputT IO ()
    loop = forever $ do
      minput <- getInputLine "dash> "
      case minput of
        Nothing     -> return ()
        Just "quit" -> return ()
        Just "exit" -> return ()
        Just input  -> liftIO $ evalString input

evalString :: String -> IO ()
evalString s = print $ eval mempty <$> parseString (runParser expression) mempty s