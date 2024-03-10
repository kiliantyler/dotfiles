EXT_PATH := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

export PATH := $(EXT_PATH)/dotfiles_extention/bin:$(EXT_PATH)/dotfiles_extention/scripts:$(PATH)

TEST:
	echo "TEST"

brew: INSTALL_FORMULAS

add_to_list:
	$(EXT_PATH)/dotfiles_extention/scripts/addToBrew.sh $(FORMULA) || (echo "Error adding ${1} to Brew list"; exit 1)

add_brew: add_to_list brew
