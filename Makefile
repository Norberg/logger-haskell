SRC=$(wildcard *.hs)

default:
	ghc Graph.hs -Wall
	ghc database.hs -o database -Wall
run: default
	./database

clean:
	\rm *.hi
	\rm *.o
