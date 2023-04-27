# pawamoy's website

My personal blog and website, built with [MkDocs](https://mkdocs.org),
and the [Material for MkDocs theme](https://squidfunk.github.io/mkdocs-material/).

Served at https://pawamoy.github.io/.

## Setup

```bash
python3 -m venv venv
venv/bin/pip install -r requirements.txt
```

## Development

Serve locally with `./scripts/serve.sh`.

## Deployment

Deploy to GitHub pages with `./scripts/deploy.sh`.
The script will build and publish the site by pushing it
on https://github.com/pawamoy/pawamoy.github.io.
