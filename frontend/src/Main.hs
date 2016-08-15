{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad.Trans (MonadIO(..))
import           Data.Maybe (listToMaybe)
import           Data.Text (Text)
import           GHCJS.Types (JSString, JSVal)
import qualified GHCJS.DOM.FormData as FD
import           GHCJS.DOM.Types (File(..), toJSString)
import           Reflex
import           Reflex.Dom


main :: IO ()
main = mainWidget $ do
  fi <- fileInput def
  submitE <- button "Upload"
  let ef = fmapMaybe id $ fmap listToMaybe $ tag (current $ value fi) submitE
  efd <- performEvent $ fmap (wrapFile "file") ef
  r <- performRequestAsync $ ffor efd $ \fd ->
         xhrRequest "POST" "/upload" def { _xhrRequestConfig_sendData = fd }
  st <- holdDyn "" $ fmap _xhrResponse_statusText r
  el "p" $ do
    text "Upload status: "
    dynText st

-- `FD.newFormData Nothing` causes an error in Firefox:
-- uncaught exception in Haskell thread: TypeError: Argument 1 of FormData.constructor is not an object.
-- But its fixed in master: https://github.com/ghcjs/ghcjs-dom/pull/47
foreign import javascript unsafe "new window[\"FormData\"]()"
        js_newFormData0 :: IO FD.FormData

-- Only needed for ghcjs-dom 0.2, for 0.3 use FD.appendBlob
foreign import javascript unsafe "$1[\"append\"]($2, $3)"
        js_append :: FD.FormData -> JSString -> JSVal -> IO ()

wrapFile :: (MonadIO m) => Text -> File -> m FD.FormData
wrapFile fname f = do
  fd <- liftIO js_newFormData0
  liftIO $ js_append fd (toJSString fname) (unFile f)
  return fd
