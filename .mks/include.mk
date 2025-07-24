########################################################################################################################
# Environment variables
########################################################################################################################
PYTHON_INTERPRETER ?= python3
PLATFORM := $(shell $(PYTHON_INTERPRETER) -c "import platform; print(platform.platform())")
ARCH = $(shell $(PYTHON_INTERPRETER) -c "import sys; print(sys.platform)")
RMTREE ?= rm -rf
MKDIR ?= mkdir -p
CAT ?= cat
SET ?= export
WHICH ?= which
DEVNULL ?= /dev/null
CMDSEP ?= ;
DATE ?= $(shell date +%Y-%m-%d)
USERNAME ?= $(shell whoami)
COMMUNICATION_CHANNEL ?= email

# This is a minimal set of ANSI/VT100 color codes
PURPLE=\033[1;35m # Bold Purple
NO_COLOR=\033[0m # No Color

SHELL := zsh
CONDA_PROG := mamba
CONDA_EXE ?= $(shell $(WHICH) mamba)  # Find the system mamba executable

ENV_LOCKFILE := environment.$(PLATFORM).$(ARCH).lock.yml
POST_CREATE_ENVIRONMENT_FILE := .mks/.post-create-environment.txt
POST_UPDATE_ENVIRONMENT_FILE := .mks/.post-update-environment.txt
POST_DELETE_ENVIRONMENT_FILE := .mks/.post-delete-environment.txt

DEBUG_FILE := debug.logs
MODULE_NAME := src
