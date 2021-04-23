version ?= $(shell awk '/[Vv]ersion/ { print $$2; }' pandoc.cabal)

.PHONY: test
test:
	cabal new-configure . --ghc-options '$(GHCOPTS)' --disable-optimization --enable-tests $(ENABLE)
	cabal new-build . --disable-optimization
	cabal new-run test-pandoc --disable-optimization -- --hide-successes $(TESTARGS)


.PHONY: full
full: ENABLE = --enable-benchmarks
full: test

man/pandoc.1: MANUAL.txt man/pandoc.1.before man/pandoc.1.after
	pandoc $< -f markdown -t man -s \
		--lua-filter man/manfilter.lua \
		--include-before-body man/pandoc.1.before \
		--include-after-body man/pandoc.1.after \
		--metadata author="" \
		--variable footer="pandoc $(version)" \
		-o $@

README.md: README.template MANUAL.txt tools/update-readme.lua
	pandoc --lua-filter tools/update-readme.lua \
	      --reference-location=section -t gfm $< -o $@

