SRC=$(wildcard *.hs)

default:
	ghc graph.hs -o graph
run: default
	./graph

clean:
	\rm *.hi
	\rm *.o
