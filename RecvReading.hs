{-# LANGUAGE DeriveDataTypeable #-}

module RecvReading where
import Network;
import System.IO;
import Text.JSON.Generic                                                                                                                 
--TODO dont depend on exactlly this json
data Reading = Reading {
	outdoor :: [String],
	indoor :: [String]
} deriving (Eq, Show, Data, Typeable)

recvReading :: IO Reading
recvReading = do
	handle <- connectTo "localhost" (PortNumber 7011)
	json <- hGetContents handle
	let reading = decodeJSON json :: Reading
	return reading
