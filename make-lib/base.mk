# Makefiles using this library should include a target called `help` or override
# `.DEFAULT_GOAL` if another default behavior is needed.
.DEFAULT_GOAL := help

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
# Based off of https://stackoverflow.com/questions/10858261/how-to-abort-makefile-if-variable-not-set
check_defined = \
	$(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
	$(if $(value $1),, \
		$(error Undefined $1$(if $2, ($2))$(if $(value @), \
			required by target '$@')))

# Prints the make targets and their docstring (the content after '##'). Pull it
# into your own `help` target as a prerequisite.
help/targets:
	@grep -Eh '^[^#[:space:]]+[[:print:]]+:.*?##' $(MAKEFILE_LIST) | \
	sort -d | \
	awk -F':.*?## ' '{printf "\033[36m%s\033[0m\t%s\n", $$1, $$2}' | \
	column -t -s "$$(printf '\t')"

# Prints various make/env vars name and current value, some common ones and any
# specified by the HELP_VARS variable
# @printf "%s\n" $(foreach env_var, $(HELP_VARS), $(var)=$($(var)_HELP))
help/vars:
	@printf "%s\n" $(foreach var_name, $(HELP_VARS), "$(var_name)=$($(var_name))")
	@echo ""
	@echo "SHELL=$(SHELL)"
	@echo "MAKE_VERSION=$(MAKE_VERSION)"


help/empty-line:
	@echo ""

# A common configuration that should cover the basics.
#
# Most projects should be able to just define:
#
#    help: ## Prints the help documentation and info about each command
#    help: help-standard
#
# And set HELP_VARS for any project-specific variables to include.
help/standard: help/targets help/empty-line help/vars
