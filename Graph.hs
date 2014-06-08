module Graph(renderGraph) where
import Data.Colour
import Data.Colour.Names
import Data.Accessor
import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Backend.Cairo
import Data.Default.Class
import Control.Lens


chart temp tempIn = layout 
  where
    price1 = plot_lines_style . line_color .~ opaque blue
           $ plot_lines_values .~ [temp]
           $ plot_lines_title .~ "Outdoor"
           $ def

    price2 = plot_lines_style . line_color .~ opaque green
           $ plot_lines_values .~ [tempIn]
           $ plot_lines_title .~ "Indoor"
           $ def

    layout = layout_title .~ "Temperature"
           $ layout_plots .~ [toPlot price1,
                              toPlot price2]
           $ def

renderGraph temp tempIn filename  = do
    renderableToPNGFile (toRenderable (chart temp tempIn)) 1200 800 filename
