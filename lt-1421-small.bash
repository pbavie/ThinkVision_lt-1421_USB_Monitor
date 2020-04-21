#!/bin/bash
#  _____ _     _       _   __     ___     _
# |_   _| |__ (_)_ __ | | _\ \   / (_)___(_) ___  _ __
#   | | | '_ \| | '_ \| |/ /\ \ / /| / __| |/ _ \| '_ \
#   | | | | | | | | | |   <  \ V / | \__ \ | (_) | | | |
#   |_| |_| |_|_|_| |_|_|\_\  \_/  |_|___/_|\___/|_| |_|
#
#  _   _____     _ _  _  ____  _
# | | |_   _|   / | || ||___ \/ |				Script in bash che permette l'uso
# | |   | |_____| | || |_ __) | | 			dello Schermo USB su sistemi linux.
# | |___| |_____| |__   _/ __/| |				Testato solamente su Ubuntu.
# |_____|_|     |_|  |_||_____|_|				VERSIONE SMALL e SILENZIOSA :)
#                                       Adatta ad essere usata con altri
#                                       programmi (tipo udev)
#
##############################################################################
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
##############################################################################
#  Script-source by Paolo Baviero  <paolo@baviero.it>  https://www.baviero.it

# export DISPLAY=:0.0

  # individuo il monitor Principale
  PRINC=`xrandr | grep primary | awk '{print $1}'`
  if [ -z "$PRINC" ];  then
    exit 1
  fi

  # Individuo il monitor ThinkVision
  DVIN=`xrandr | grep DVI* | cut -f1 -d' '`
  if [ -z "$DVIN" ];  then
    exit 1
  fi

  #Eseguo
  LIBGL_ALWAYS_SOFTWARE=1
  xrandr --newmode "1368x768_59.90"  85.72  1368 1440 1584 1800  768 769 772 795  -HSync +Vsync &> /dev/null
  xrandr --addmode $DVIN 1368x768_59.90 &> /dev/null
  xrandr --output $DVIN --off &> /dev/null
  xrandr --output $DVIN --mode "1368x768_59.90" --right-of $PRINC &> /dev/null
	# xrandr --output $DVIN --mode "1368x768_59.90" --left-of $PRINC &> /dev/null
	# xrandr --output $DVIN --mode "1368x768_59.90" --above $PRINC &> /dev/null
	# xrandr --output $DVIN --mode "1368x768_59.90" --below $PRINC &> /dev/null
  # --same-as puo dare problemi, servono configurazioni aggiuntive
	# xrandr --output $DVIN --primary --mode "1368x768_59.90" --same-as $PRINC &> /dev/null
