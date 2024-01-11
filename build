.PHONY: help
## Print this message.
# Parses this Makefile and prints targets that are preceded by "##" comments.
help:
	$(info $(car))
	@echo "" >&2
	@echo "Available targets: " >&2
	@echo "" >&2
	@awk -F : '\
			BEGIN { in_doc = 0; } \
			/^##/ && in_doc == 0 { \
				in_doc = 1; \
				doc_first_line = $$0; \
				sub(/^## */, "", doc_first_line); \
			} \
			$$0 !~ /^#/ && in_doc == 1 { \
				in_doc = 0; \
				if (NF <= 1) { \
					next; \
				} \
				printf "  %-15s %s\n", $$1, doc_first_line; \
			} \
			' <"$(abspath $(lastword $(MAKEFILE_LIST)))" \
		| sort >&2
	@echo "" >&2

.PHONY: bin
## Compiles only the main code, skipping test compilation and running
bin:
	./mvnw package -U -Dmaven.test.skip=true

.PHONY: build
## Builds and runs the tests
build: env
	./mvnw clean verify -U -DskipITs

.PHONY: env
## Sets up the docker environment needed to run the app locally
env:
	docker compose up -d

.PHONY: test
## Runs all tests
test: env
	./mvnw clean -U verify

.PHONY: open
## Opens the internal web page of a locally running the application
open:
	open 'http://localhost:8080/internal'

.PHONY: outdated
## Shows outdated dependencies
outdated:
	mvn -N versions:display-property-updates | grep -e '->'

.PHONY: clean
## Removes the docker environment and clears build files
clean:
	docker compose down
	mvn clean

.PHONY: fmt
## Formats the code with ktlint (install with brew install ktlint)
fmt:
	ktlint -F "*/src/**/*.kt"
