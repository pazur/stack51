all: AsmParser.hs main

AsmParser.hs: AsmParser.ly
	happy AsmParser.ly

main: AsmParser.hs GraphAlg.hs Graph.hs main.hs
	ghc main.hs

clean:
	rm -f AsmParser.hs main
	rm -f *.hi *.o
