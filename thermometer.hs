{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
import Control.Concurrent
import System.Locale
import Database.MongoDB
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.Format 
import Data.Time.LocalTime
import Data.Maybe
import Graph
import Graphics.GD
import RecvReading
import System.IO
import Database
import Text.Printf

--main :: IO ()
main = do		
	pipe <- runIOE $ connect $ host "localhost"
	reading <- recvReading
	let readingOutdoor = read $ last $ outdoor reading :: Float
	let readingIndoor = read $ last $ indoor reading :: Float
	a <- getMaxToday pipe "readings.indoor" "indoor"
	let maxIn = printMaxMin (head a)
	b <- getMinToday pipe "readings.indoor" "indoor"
	let minIn = printMaxMin (head b)
	c <- getMaxToday pipe "readings.outdoor" "outdoor"
	let maxOut = printMaxMin (head c)
	d <- getMinToday pipe "readings.outdoor" "outdoor"
	let minOut = printMaxMin (head d)
	writeThermometer readingIndoor readingOutdoor maxIn maxOut minIn minOut
	close pipe

printMaxMin :: (LocalTime , Double) -> String
printMaxMin (datetime, value) = printf "%.1f&deg;C %s" value time where
	time = formatTime defaultTimeLocale "%H:%M" datetime 

writeThermometer curIn curOut maxIn maxOut minIn minOut = do
	file <- openFile "www/thermometer.html" WriteMode
	hPutStrLn file $ h4 ("Indoor: " ++ show(curIn) ++"&deg;C")
	hPutStrLn file $ h5 ("Min: " ++ minIn)
	hPutStrLn file $ h5 ("Max: " ++ maxIn)
	hPutStrLn file $ h4 ("Outdoor: " ++ show(curOut) ++"&deg;C")
	hPutStrLn file $ h5 ("Min: " ++ minOut)
	hPutStrLn file $ h5 ("Max: " ++ maxOut)
	hClose file

h4 str = "<h4>" ++ str ++ "</h4>"
h5 str = "<h5>" ++ str ++ "</h5>"

