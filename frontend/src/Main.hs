{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad.Trans (MonadIO(..))
import           Data.Maybe (listToMaybe)
import           Data.Text (Text)
import qualified GHCJS.DOM.FormData as FD
import           GHCJS.DOM.Types (File)
import           Reflex.Dom


main :: IO ()
main = mainWidget $ do
  fi <- fileInput def
  submitE <- button "Upload"
  let ef = fmapMaybe listToMaybe $ tag (current $ value fi) submitE
  efd <- performEvent $ fmap (wrapFile "file") ef
  r <- performRequestAsync $ ffor efd $ \fd ->
         xhrRequest "POST" "/upload" def { _xhrRequestConfig_sendData = fd }
  st <- holdDyn "" $ fmap _xhrResponse_statusText r
  el "p" $ do
    text "Upload status: "
    dynText st

wrapFile :: (MonadIO m) => Text -> File -> m FD.FormData
wrapFile fname f = liftIO $ do
  fd <- FD.newFormData Nothing
  FD.appendBlob fd fname f (Nothing :: Maybe String)
  return fd
