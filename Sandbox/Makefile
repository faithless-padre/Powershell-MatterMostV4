.PHONY: help start stop tests ps ls

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  start   - Start MatterMost stack"
	@echo "  stop    - Stop and remove all containers and volumes"
	@echo "  ps      - Show container status"
	@echo "  ls      - Alias for ps"
	@echo "  tests   - Run Pester integration tests"
	@echo "  help    - Show this help"

start:
	docker compose up -d

stop:
	docker compose down -v

ps:
	docker compose ps

ls: ps

tests:
	docker compose run --rm tests
