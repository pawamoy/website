.PHONY: serve deploy format

setup:
	@bash scripts/setup.sh

serve:
	@bash scripts/serve.sh

deploy:
	@bash scripts/deploy.sh

format:
	@bash scripts/format.sh

linkcheck:
	@bash scripts/linkcheck.sh
