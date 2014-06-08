{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
import Control.Concurrent
import System.Locale
import Database.MongoDB
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.Format 
import Data.Time.LocalTime
import Data.Maybe
import Database
import Graph
import Graphics.GD
import RecvReading

--main :: IO ()
main = do		
	pipe <- runIOE $ connect $ host "localhost"

	reading <- recvReading
	let readingOutdoor = read $ last $ outdoor reading :: Float
	let readingIndoor = read $ last $ indoor reading :: Float
	insertReading pipe readingOutdoor readingIndoor

	generateDaily pipe
	generateMonthly pipe
	generateWeekly pipe
	close pipe
	


generateDaily pipe = do
	currentTime <- getCurrentTimeNoTZ
	let midnight = UTCTime (utctDay currentTime) 0 
	generateGraph pipe currentTime midnight filename where 
		filename = "www/daily.png"

generateWeekly pipe = do
	currentTime <- getCurrentTimeNoTZ
	let oneWeekAgo' = addDays (-7) ( utctDay currentTime)
	let oneWeekAgo = UTCTime oneWeekAgo' 0 
	generateGraph pipe currentTime oneWeekAgo filename where 
		filename = "www/weekly.png"

generateMonthly pipe = do
	currentTime <- getCurrentTimeNoTZ
	let oneMonthAgo' = addGregorianMonthsClip (-1) ( utctDay currentTime)
	let oneMonthAgo = UTCTime oneMonthAgo' 0 
	generateGraph pipe currentTime oneMonthAgo filename where 
		filename = "www/monthly.png"

generateGraph pipe lte gte filename = do
	e <- access pipe master "sensors" (getRange lte gte)
	let h = getRight e
	let indoor = concat $ map (fromMongo "indoor") h
	let outdoor = concat $ map (fromMongo "outdoor") h
	renderGraph indoor outdoor filename


--BUG: Rezised images is bigger than original, know GD problem
createThumbnails = do
	createThumbnail "www/daily.png" 860 573 "www/daily.860x573.png"
	createThumbnail "www/daily.png" 560 373 "www/daily.560x373.png"
	createThumbnail "www/weekly.png" 560 373 "www/weekly.560x373.png"
	createThumbnail "www/monthly.png" 560 373 "www/monthly.560x373.png"

createThumbnail input x y output = do
	inputImage <- loadPngFile input
	resizedImage <- resizeImage x y inputImage
	savePngFile output resizedImage

