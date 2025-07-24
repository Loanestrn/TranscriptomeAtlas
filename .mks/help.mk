#################################################################################
# Self Documenting Help for Make Targets                                        #
#################################################################################
.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help

HELP_VARS := ARCH PLATFORM DEBUG_FILE PROJECT_NAME PROJECT_PATH

help-prefix:
	@echo "${PURPLE}$(LOGO)${NO_COLOR}\n"
	@echo "Usage:"
	@echo "  >>> $$(tput bold)make <RULE> [OPTION=<value>]$$(tput sgr0)"
	@echo ""
	@echo "To get started:"
	@echo "  >>> $$(tput bold)make create_environment$$(tput sgr0)"
	@echo ""
	@echo "To activate conda environment:"
	@echo "  >>> $$(tput bold)conda activate $(CONDA_ENV_PATH)$$(tput sgr0)"
	@echo ""
	@echo "To activate project python environment:"
	@echo "  >>> $$(tput bold)source .venv/bin/activate$$(tput sgr0)"
	@echo ""
	@echo "To update environment:"
	@echo "  >>> $$(tput bold)make update_environment$$(tput sgr0)"
	@echo ""
	@echo "$$(tput bold)Project Variables:$$(tput sgr0)"

# Find the maximum key length by iterating over KEYS
	@$(eval MAX_KEY_LENGTH=$(shell echo $(HELP_VARS) | xargs -n1 | awk '{ if (length > max) max = length; } END { print max; }'))
# Echo each key-value pair with aligned formatting
	@$(foreach KEY, $(HELP_VARS),\
		$(eval KEY_VALUE=$($(KEY)))\
		$(eval PADDED_KEY=$(shell printf '%-*s' $(MAX_KEY_LENGTH) $(KEY)))\
		printf '${PURPLE}%s =${NO_COLOR}%s\n' '$(PADDED_KEY)' '$(KEY_VALUE)';\
	)


help: help-prefix
	@echo
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| cat
	@echo
	@echo "--------------------------------------------------------------------------"
	@echo "Report bugs to <${AUTHOR_EMAIL}>"
	@echo "--------------------------------------------------------------------------"