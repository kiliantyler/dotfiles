#!/usr/bin/env zsh
## ZSH Options (https://zsh.sourceforge.io/Doc/Release/Options.html) ##

### CD Options ###

## Lets you cd into directories without the cd command
setopt autocd

## Pushes all cd commands to the stack (https://serverfault.com/a/1056164)
setopt autopushd

## Don't print the directory stack after a pushd or popd command
setopt cdsilent

## Don't push multiple copies of the same directory onto the directory stack
setopt pushdignoredups

## Don't print the directory stack after a pushd or popd command
setopt pushdsilent

### END CD ###

### Completion Options ###

## Always move cursor to end of line on completion
setopt alwaystoend

## Automatically list choices on ambiguous completion
setopt autolist

### END Completion ###

### History Options ###

## Appends history instead of overwriting it
setopt appendhistory

## Saves commands with time
setopt extendedhistory

## Don't find duplicates in history
setopt histfindnodups

## Don't record subsequent duplicates in history
setopt histignoredups

## Remove blanks from history
setopt histreduceblanks

### END History ###

### Input Options ###

## Allow aliases in scripts
setopt aliases

## Try to correct spelling errors
setopt correct

## Allow comments even in interactive shells
setopt interactivecomments

### END Input ###

### Prompt Options ###

## Allows ! expansion (eg sudo !!)
setopt promptbang

## Allow parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt promptsubst

### END Prompt ###

### Script Options ###

## Give exit status of any non-zero command in a pipe
setopt pipefail

### END Script ###
