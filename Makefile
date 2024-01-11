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

.PHONY: health
## Shows outdated and used dependencies
health:
	@dep_updates=$$(mvn versions:display-dependency-updates | grep -e '->'); \
	plugin_updates=$$(mvn versions:display-plugin-updates | grep -e '->'); \
	prop_updates=$$(mvn -N versions:display-property-updates | grep -e '->'); \
	dependency_analysis=$$(mvn dependency:analyze | grep -e '^\[WARNING\]'); \
	if [ -n "$$dep_updates" ]; then \
		echo "Dependency Updates:"; \
		echo "$$dep_updates"; \
		echo; \
	fi; \
	if [ -n "$$plugin_updates" ]; then \
		echo "Plugin Updates:"; \
		echo "$$plugin_updates"; \
		echo; \
	fi; \
	if [ -n "$$prop_updates" ]; then \
		echo "Property Updates:"; \
		echo "$$prop_updates"; \
		echo; \
	fi; \
	if [ -n "$$dependency_analysis" ]; then \
		echo "Dependency Analysis Warnings:"; \
		echo "$$dependency_analysis"; \
		echo; \
	fi

.PHONY: clean
## Removes the docker environment and clears build files
clean:
	docker ps -q -a | xargs docker rm -f;
	mvn clean

.PHONY: fmt
## Formats the code with ktlint (install with brew install ktlint)
fmt:
	ktlint -F "*/src/**/*.kt"
