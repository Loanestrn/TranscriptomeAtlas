########################################################################################################################
# Project environment variables
########################################################################################################################
# Get the name of the parent directory
PARENT_DIR := $(shell basename "$(shell dirname "$(realpath $(lastword $(MAKEFILE_LIST)))")")

# Get the path of the project directory
PROJECT_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

PROJECT_NAME := $(PARENT_DIR)
PROJECT_NAME_LC := $(shell echo $(PROJECT_NAME) | tr "[:upper:]" "[:lower:]")
PROJECT_NAME_UC := $(shell echo $(PROJECT_NAME_LC) | tr "[:lower:]" "[:upper:]")

CONDA_ENV_PATH := $(PROJECT_PATH)/.conda/$(PROJECT_NAME)
VIRTUALENV_PATH := $(PROJECT_PATH)/.venv/$(PROJECT_NAME)

AUTHOR_EMAIL = kchennen@unistra.fr
AUTHOR_NAME = kchennen


# Load program logo
LOGO_FILE := logo.txt
LOGO := $(shell cat $(LOGO_FILE) | sed 's/^/\\n/')
export LOGO

# Reproducible Environments
include .mks/include.mk
include .mks/envs.mk
include .mks/help.mk


#################################################################################
# COMMANDS                                                                      #
#################################################################################
.PHONY: am_i_ready clean
## Check if the environment requirements are installed
am_i_ready:
	@$(PYTHON_INTERPRETER) .mks/am_i_ready.py

black_diff:
	@$(PYTHON_INTERPRETER) -m black --check --diff $(PROJECT_PATH)

## Format the code with black
black:
	@$(PYTHON_INTERPRETER) -m black $(PROJECT_PATH)

ruff_check:
	@$(PYTHON_INTERPRETER) -m ruff check $(PROJECT_PATH)

ruff_format:
	@$(PYTHON_INTERPRETER) -m ruff format $(PROJECT_PATH)