SRC=$(wildcard *.hs)

default:
	ghc -O --make logger.hs -o logger -Wall
run: default
	./logger

clean:
	\rm *.hi
	\rm *.o
