#!/bin/bash

# color-echo.sh: Echoing text messages in color.
# 
# Taken from: http://www.tldp.org/LDP/abs/html/colorizing.html
#
# Modify this script for your own purposes.
# It's easier than hand-coding color.
#
# Usage: 
#    cecho "Some text..." $blue  -> Print text in blue colour
#    cecho "Some text..."        -> Print text in black
#    cecho                       -> Print "No message passed."
# -------------------------------------------------------------------------
# ANSI color codes
RS="\033[0m"    # reset
HC="\033[1m"    # hicolor
UL="\033[4m"    # underline
INV="\033[7m"   # inverse background and foreground
FBLK="\033[0;30m" # foreground black
FRED="\033[0;31m" # foreground red
FGRN="\033[0;32m" # foreground green
FYEL="\033[0;33m" # foreground yellow
FBLE="\033[0;34m" # foreground blue
FMAG="\033[0;35m" # foreground magenta
FCYN="\033[0;36m" # foreground cyan
FWHT="\033[0;37m" # foreground white
BBLK="\033[0;40m" # background black
BRED="\033[0;41m" # background red
BGRN="\033[0;42m" # background green
BYEL="\033[0;43m" # background yellow
BBLE="\033[0;44m" # background blue
BMAG="\033[0;45m" # background magenta
BCYN="\033[0;46m" # background cyan
BWHT="\033[0;47m" # background white
# -------------------------------------------------------------------------
#alias Reset="tput sgr0"      #  Reset text attributes to normal
                             #+ without clearing screen.


cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.
message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$FWHT}           # Defaults to white, if not specified.

  echo -en "$color"
  echo "$message"
tput sgr0
#  Reset                      # Reset to normal.

  return
} 