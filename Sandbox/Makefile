MM_VERSIONS ?= 9.11.14 10.11.4 11.5.1

.PHONY: help start stop tests test-matrix test-matrix-report ps ls

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  start   - Start MatterMost stack"
	@echo "  stop    - Stop and remove all containers and volumes"
	@echo "  ps      - Show container status"
	@echo "  ls      - Alias for ps"
	@echo "  tests               - Run Pester integration tests"
	@echo "  test-matrix         - Run tests against multiple MM versions (MM_VERSIONS='x y z')"
	@echo "  test-matrix-report  - Same, but save only failures + summary to matrix-report.txt"
	@echo "  help                - Show this help"

start:
	docker compose up -d

stop:
	docker compose down -v

ps:
	docker compose ps

ls: ps

tests:
	docker compose run --rm tests

test-matrix:
	@failed=""; \
	for v in $(MM_VERSIONS); do \
		echo ""; \
		echo "======================================"; \
		echo "  Testing MatterMost $$v"; \
		echo "======================================"; \
		MM_VERSION=$$v docker compose down -v 2>/dev/null; \
		MM_VERSION=$$v docker compose up -d; \
		if MM_VERSION=$$v docker compose run --rm tests; then \
			echo "PASS: $$v"; \
		else \
			echo "FAIL: $$v"; \
			failed="$$failed $$v"; \
		fi; \
		MM_VERSION=$$v docker compose down -v; \
	done; \
	if [ -n "$$failed" ]; then \
		echo ""; \
		echo "FAILED:$$failed"; \
		exit 1; \
	fi

test-matrix-report:
	@report="matrix-report.txt"; \
	: > "$$report"; \
	failed=""; \
	for v in $(MM_VERSIONS); do \
		echo ""; \
		echo "======================================"; \
		echo "  Testing MatterMost $$v"; \
		echo "======================================"; \
		MM_VERSION=$$v docker compose down -v 2>/dev/null; \
		MM_VERSION=$$v docker compose up -d; \
		out=$$(MM_VERSION=$$v docker compose run --rm tests 2>&1); \
		status=$$?; \
		echo "$$out" | sed 's/\x1b\[[0-9;]*m//g' | awk \
			-v ver="$$v" \
			'BEGIN { print "\n======================================"; print "  MatterMost " ver; print "======================================" } \
			 /Tests Passed:/          { print $0 } \
			 /^ *\[-\]/               { print $0; fail=1; next } \
			 fail && /^[[:space:]][[:space:]]/ { print $0; next } \
			 fail                     { fail=0 }' \
			>> "$$report"; \
		if [ $$status -eq 0 ]; then \
			echo "PASS: $$v"; \
		else \
			echo "FAIL: $$v"; \
			failed="$$failed $$v"; \
		fi; \
		MM_VERSION=$$v docker compose down -v; \
	done; \
	if [ -n "$$failed" ]; then \
		printf "\nFAILED:$$failed\n" >> "$$report"; \
		echo ""; \
		echo "FAILED:$$failed"; \
		echo "Report saved to $$report"; \
		exit 1; \
	else \
		printf "\nAll versions passed.\n" >> "$$report"; \
		echo "Report saved to $$report"; \
	fi
