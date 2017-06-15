all: _build

_build: Makefile posts/*.rst conf.py images/*.png
	sphinx-build -b html . _build

clean:
	rm -R _build
