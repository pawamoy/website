.PHONY: serve deploy format

setup:
	@bash scripts/setup.sh

serve:
	@bash scripts/serve.sh

deploy:
	@bash scripts/deploy.sh

format:
	@mdformat docs/posts --ignore-missing-references