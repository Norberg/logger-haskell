module Graph(renderGraph) where
import Data.Colour
import Data.Colour.Names
import Data.Accessor
import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Gtk

chart temp tempIn = layout 
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

renderGraph temp tempIn filename  = do
    renderableToPNGFile (toRenderable (chart temp tempIn)) 640 480 filename
