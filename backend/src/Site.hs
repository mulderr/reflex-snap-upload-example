{-# LANGUAGE OverloadedStrings #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
  ( app
  ) where

------------------------------------------------------------------------------
import           Control.Monad (forM)
import           Control.Monad.Trans (liftIO)
import           Data.ByteString (ByteString)
import qualified Data.Text as T
import           Data.Text.Encoding (decodeUtf8)
import           Snap.Core
import           Snap.Snaplet
import           Snap.Util.FileServe
import           Snap.Util.FileUploads
import           System.Directory
import           System.FilePath ((</>))
------------------------------------------------------------------------------

data App = App

------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes = [ ("/upload",   handleUpload)
         , ("",          serveDirectory "static")
         ]

handleUpload :: Handler App App ()
handleUpload = handleFileUploads "tmp" defaultUploadPolicy (const $ allowWithMaximumSize $ 10*miB) handler
  where
    miB = 2^(20 :: Int)

    handler :: [(PartInfo, Either PolicyViolationException FilePath)] -> Handler App App ()
    handler parts = do
      forM parts $ \(pinfo, epf) -> do
        case epf of
          Left pve -> do
            modifyResponse $ setResponseCode 404
            writeBS "Error saving file"
            liftIO $ putStrLn $ show pve
            r <- getResponse
            finishWith r
          Right fp -> liftIO $ do
            case partFileName pinfo of
              Nothing -> error "Missing filename"
              Just fname -> do
                renameFile fp $ "upload" </> T.unpack (decodeUtf8 fname)
      return ()

------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
    addRoutes routes
    return App

