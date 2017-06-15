all: build

build: Makefile posts/*.rst conf.py images/*.png
	sphinx-build -b html . blog

clean:
	rm -R blog
