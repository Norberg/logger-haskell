{-# LANGUAGE OverloadedStrings, ExtendedDefaultRules #-}
import System.Locale
import Database.MongoDB
import Data.Time.Clock
import Data.Time.Format 
import Data.Time.LocalTime
import Data.Maybe
import Graph

--main :: IO ()
main = do
	pipe <- runIOE $ connect $ host "atom"
	generateGraph pipe lte gte filename where 
		lte = fromIso8061 "2012-07-07 00:00"
		gte = fromIso8061 "2012-07-06 00:00"
		filename = "test.png"
	--close pipe

generateGraph pipe lte gte filename = do
	e <- access pipe master "sensors" (getRange lte gte)
	let h = getRight e
	let indoor = concat $ map (fromMongo "indoor") h
	let outdoor = concat $ map (fromMongo "outdoor") h
	renderGraph indoor outdoor "test.png"

run :: Action IO [Document]
run = do
	getRange lte gte where 
		lte = fromIso8061 "2012-07-07 00:00"
		gte = fromIso8061 "2012-07-06 00:00"

-- Access label/value from Field
-- label field
-- value field

fromMongo :: Label -> Document -> [(LocalTime, Double)]
fromMongo sensor doc = [(datetime, reading)] where
	datetime = utcToLocalTime utc (at "datetime" doc)
	reading = at sensor readings where
		readings = at "readings" doc


getRight ::  Either Failure [Document] -> [Document]	
fromValue doc = typed $ valueAt "datetime" doc
getRight e = case e of
	Left e -> error "Error reading documents: "
	Right e -> e

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
