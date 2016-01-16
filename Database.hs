{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
module Database where
import Control.Concurrent
import System.Locale
import Database.MongoDB
import Data.Bson
import Data.Time.Calendar
import Data.Time.Clock
import Data.Time.Format 
import Data.Time.LocalTime
import Data.Maybe

insertReading pipe outdoor indoor = do
	currentTime <- getCurrentTimeNoTZ
	let reading = ["readings" =: 
			  ["outdoor" =: outdoor,
			   "indoor" =: indoor],
	              "datetime" =: currentTime]
	e <- access pipe master "sensors" (insert "temperature" reading)
	return e
		

fromMongo :: Label -> Document -> [(LocalTime, Double)]
fromMongo sensor doc = [(datetime, reading)] where
	datetime = utcToLocalTime utc (at "datetime" doc)
	reading = at sensor readings where
		readings = at "readings" doc

getRight ::  Either Failure [Document] -> [Document]	
getRight e = case e of
	Left _ -> error "Error reading documents: "
	Right d -> d

fromIso8061 :: String -> UTCTime
fromIso8061 str = fromJust(parseTime defaultTimeLocale "%F %R" str)

getRange :: UTCTime -> UTCTime -> Action IO [Document]
getRange lte gte= rest =<< find (select 
	["datetime" =: 
		["$lte" =: lte,
		 "$gte" =: gte]
	] "temperature")
	{sort = ["datetime" =: 1]}
	{limit = 100000}

getMaxToday pipe sortField field = getMaxMinToday' pipe sortField field (-1) 
getMinToday pipe sortField field = getMaxMinToday' pipe sortField field 1 

--getMaxMinToday' ::  Pipe -> Label -> Integer -> IO [(LocalTime, Double)]
getMaxMinToday' pipe sortField field order = do
	currentTime <- getCurrentTimeNoTZ
	let midnight = UTCTime (utctDay currentTime) 0 
	e <- access pipe master "sensors" (getMaxMin' currentTime midnight sortField order)
	let h = getRight e
	let doc = concat $ map (fromMongo field) h
	return doc

--getMaxMin' :: UTCTime -> UTCTime -> Label -> Integer ->  Action IO [Document]
getMaxMin' lte gte field order = rest =<< find (select
	["datetime" =: 
		["$lte" =: lte,
		 "$gte" =: gte]
	] "temperature")
	{sort = [field =: order]}
	{limit = 1}

getCurrentTimeNoTZ = do
	currentTimeUTC <- getCurrentTime
	localTZ <- getTimeZone currentTimeUTC
	let localTime = utcToLocalTime localTZ currentTimeUTC
	let currentTimeNoTZ = localTimeToUTC utc localTime
	return currentTimeNoTZ	
