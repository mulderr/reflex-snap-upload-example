#!/usr/bin/env stack
-- stack --compiler ghc-7.10.3 --install-ghc runghc --package fsnotify

{-# LANGUAGE OverloadedStrings, RecordWildCards #-}

import           Control.Concurrent (threadDelay)
import           Control.Concurrent.MVar
import           Control.Monad (forever)
import           Data.Monoid ((<>))
import qualified Data.Text as T
import           Safe
import           System.Directory
import           System.FSNotify
import           System.Environment (getArgs, getProgName)
import           System.Exit
import           System.FilePath.Posix
import           System.Process


data Config
  = Config { exeName :: String
           , jsPath :: String
           , watchDir :: String
           , stackInstallRoot :: String
           }

main :: IO ()
main = do
  mconf <- parse =<< getArgs
  case mconf of
    Just cfg -> watchLoop cfg
    Nothing -> do
      prog <- getProgName
      die $ "Usage: " <> prog <> " <exeName> <dstPath> [<watchdir>]"

parse :: [String] -> IO (Maybe Config)
parse (exe : dst : opts) = do
  let wd = case opts of
             [] -> "src"
             wdir : _ -> wdir
  iroot <- readProcess "stack" ["path", "--local-install-root"] []
  return $ Just $ Config exe dst wd (strip iroot)
parse _ = return Nothing

watchLoop :: Config -> IO ()
watchLoop cfg@Config{..} =
  withManagerConf (defaultConfig { confDebounce = Debounce 0.1 }) $ \mgr -> do
    print $ "Watching `" <> watchDir <> "` for changes..."
    buildLock <- newMVar ()
    watchTree mgr watchDir eventPred $ \ev -> do
      print ev
      mbl <- tryTakeMVar buildLock
      case mbl of
        Just _ -> do
          build cfg
          putMVar buildLock ()
          putStrLn "Done.\n"
        Nothing -> do
          putStrLn "Warning: Ignoring event because another build is already running..."
    forever $ threadDelay 1000000
  where
    eventPred (Added fp _) = ignoreEmacs fp
    eventPred (Modified fp _) = ignoreEmacs fp
    eventPred (Removed fp _) = ignoreEmacs fp

    ignoreEmacs fp = 
      let fn = takeFileName fp 
      in not $ or [isTmp fn, isInterlock fn]

    isTmp fn = 
      let h = headDef '#' fn
          l = lastDef '#' fn
      in and $ map (=='#') [h, l]

    isInterlock ('.' : '#' : _) = True
    isInterlock _ = False

build :: Config -> IO ()
build cfg = do
  ec <- spawnProcess "stack" ["build"] >>= waitForProcess
  case ec of
    ExitSuccess -> installJs cfg
    _ -> return ()

installJs :: Config -> IO ()
installJs cfg@Config{..} = do
  let fname = "all.js"
      src = stackInstallRoot </> "bin" </> (exeName <.> "jsexe") </> fname
      dst = jsPath </> fname
  putStrLn $ "copy: " <> src <> " -> " <> dst
  copyFile src dst

strip :: String -> String
strip = T.unpack . T.strip . T.pack
