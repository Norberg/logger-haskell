SRC=$(wildcard *.hs)

default:
	ghc -O --make logger.hs -o logger -Wall
	ghc -O --make thermometer.hs -o thermometer -Wall
run: default
	./logger

clean:
	\rm *.hi
	\rm *.o
