all: build

build: Makefile sources/index.rst sources/extra.css sources/conf.py sources/posts/*.rst sources/images/*.png
	sphinx-build -b html sources .

clean:
	rm .buildinfo index.html genindex.html objects.inv search.html searchindex.js
	rm -rf .doctrees _sources _static posts
