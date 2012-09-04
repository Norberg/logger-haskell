import System.Locale
import Data.Time.Calendar
import Data.Time.Format 
import Data.Time.LocalTime
import Data.Colour.Names
import Data.Colour
import Data.Accessor
import Data.Maybe
import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Gtk
import Prices

tempOrg = [("2012-08-25 00:25", 15.9),
	("2012-08-25 01:15",15.3),
	("2012-08-25 02:05",15.1),
	("2012-08-25 02:55",5.0),
	("2012-08-25 03:45",4.9),
	("2012-08-25 04:35",4.7),
	("2012-08-25 05:25",4.6),
	("2012-08-25 06:15",4.5),
	("2012-08-25 07:05",5.1),
	("2012-08-25 07:55",5.6),
	("2012-08-25 08:45",5.8),
	("2012-08-25 09:35",7.1),
	("2012-08-25 10:25",7.3),
	("2012-08-25 11:15",8.3),
	("2012-08-25 12:05",8.8),
	("2012-08-25 12:55", 20.5),
	("2012-08-25 13:45",20.1),
	("2012-08-25 14:35",9.7),
	("2012-08-25 15:25",9.5),
	("2012-08-25 16:15",9.0),
	("2012-08-25 17:05",8.5),
	("2012-08-25 17:55",8.1),
	("2012-08-25 18:45",7.5),
	("2012-08-25 19:35",7.3)
	]

temp :: [(LocalTime, Double)]
temp = map convertTemp tempOrg

tempIn :: [(LocalTime, Double)]
tempIn = map convertTempIn temp

convertTempIn :: (LocalTime, Double) -> (LocalTime, Double)
convertTempIn d = (fst d, (snd d) - 2)

convertTemp d = (fromJust(fromIso8061 (fst d)), snd d)

fromIso8061 :: String -> Maybe LocalTime
fromIso8061 str = parseTime defaultTimeLocale "%F %R" str

chart = layout 
  where

    price1 = plot_lines_style .> line_color ^= opaque blue
           $ plot_lines_values ^= [temp]
           $ plot_lines_title ^= "outside"
           $ defaultPlotLines

    price2 = plot_lines_style .> line_color ^= opaque green
           $ plot_lines_values ^= [tempIn]
           $ plot_lines_title ^= "inside"
           $ defaultPlotLines

    layout = layout1_title ^="Temperature"
           $ layout1_plots ^= [Right (toPlot price1),
                               Right (toPlot price2)]
           $ defaultLayout1

main = do
    renderableToWindow (toRenderable chart) 640 480
