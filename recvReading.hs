import Network;
import System.IO;
import Text.JSON


main = do
	handle <- connectTo "sheeva" (PortNumber 7011)
	reading <- hGetContents handle 
	putStrLn reading
