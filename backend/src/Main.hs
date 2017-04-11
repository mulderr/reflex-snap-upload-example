{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad (void)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import           Snap.Core
import           Snap.Http.Server
import           Snap.Util.FileServe
import           Snap.Util.FileUploads
import           System.Directory
import           System.FilePath ((</>))


main :: IO ()
main = quickHttpServe site


site :: Snap ()
site = route [ ("upload", handleUpload)
             , ("", serveDirectory "static")
             ]


-- | Handles the upload form saving file to upload directory.
handleUpload :: MonadSnap m => m ()
handleUpload = void $ handleFileUploads "tmp"
                                        defaultUploadPolicy
                                        (const $ allowWithMaximumSize $ 10*miB)
                                        handler
  where
    miB = 2^(20 :: Int)

    handler pinfo = either (putStrLn . show) (saveFile pinfo)

    saveFile pinfo fp = case partFileName pinfo of
      Just fn -> renameFile fp $ "upload" </> T.unpack (T.decodeUtf8 fn)
      Nothing -> error "Missing filename"
