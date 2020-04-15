#!/bin/bash
#  _____ _     _       _   __     ___     _
# |_   _| |__ (_)_ __ | | _\ \   / (_)___(_) ___  _ __
#   | | | '_ \| | '_ \| |/ /\ \ / /| / __| |/ _ \| '_ \
#   | | | | | | | | | |   <  \ V / | \__ \ | (_) | | | |
#   |_| |_| |_|_|_| |_|_|\_\  \_/  |_|___/_|\___/|_| |_|
#
#  _   _____     _ _  _  ____  _
# | | |_   _|   / | || ||___ \/ |				Script in bash che permette l'uso
# | |   | |_____| | || |_ __) | | 			del monitor USB su sistemi linux.
# | |___| |_____| |__   _/ __/| |				Testato solamente su Ubuntu.
# |_____|_|     |_|  |_||_____|_|				See You!
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

# usage
function usage()
	{
	echo "================= USO DI ${0} ===================

Script per l'attivazione del monitor ThinkVision lt-1421
Lo script puo essere eseguito con i permessi utente.
Necessita la presenza di xrandr.
Lo script individua il monitor principale e avvia il monitor
lt-1421 alla sua sinistra o destra.

Sintassi: ${0} [sx,dx,off] -h
Parametri:
  sx               Prova ad avviare il monitor a SINISTRA del princpale
  dx  [default]    Prova ad avviare il monitor a DESTRA del princpale
  off              Spegne il monitor
  -h               Questo help

  hint to paolo@baviero.it"
}

function individua_monitors() {
  # Individuo il monitor Principale
  PRINC=`xrandr | grep primary | awk '{print $1}'`
  if [ "$PRINC" ];  then
    echo "Monitor principale trovato - $PRINC"
  else
    echo "Riconoscimento automatico del monitor principale NON riuscito!"
    echo "Per il corretto funzionamento dello script e' necessario
		individuare il numero indicativo del monitor Principale ed assegnare
		il valore alla variabile \$PRINC. Puoi provare usando l'output del
		comando - xrandr -"
    exit 1
  fi

  # Individuo il monitor ThinkVision
  DVIN=`xrandr | grep DVI* | cut -f1 -d' '`
  #if [ -n "$DVIN" ]
  if [ "$DVIN" ];  then
    echo "Monitor lt-1421 trovato - $DVIN"
  else
    echo "Monitor lt-1421 NON TROVATO!
    potrebbe non essere collegato correttamente?"
    exit 1
  fi
}

function init_monitor() {
	# Imposto caratteristiche video e posiziono schermo nella posizione desiderata
  LIBGL_ALWAYS_SOFTWARE=1
  xrandr --newmode "1368x768_59.90"  85.72  1368 1440 1584 1800  768 769 772 795  -HSync +Vsync &> /dev/null
  xrandr --addmode $DVIN 1368x768_59.90 &> /dev/null
  xrandr --output $DVIN --off &> /dev/null
  if [ $1 == sx ]; then
    echo "Provo ad avviare il monitor a SINSTRA del principale"
    xrandr --output $DVIN --mode "1368x768_59.90" --left-of $PRINC &> /dev/null
  elif [ $1 == dx ]; then
    echo "Provo ad avviare il monitor a DESTRA del principale"
    xrandr --output $DVIN --mode "1368x768_59.90" --right-of $PRINC &> /dev/null
  fi
}

function spengni_monitor() {
  echo "Spengo il monitor"
  xrandr --output $DVIN --off &> /dev/null
  exit 0
}

##-------------MAIN----------
# Controllo se presenti parametri
if [ $# -lt 1 ]; then
  individua_monitors
  init_monitor dx
  exit 0
fi

case "$1" in
# SINISTRA
sx)
   individua_monitors
   init_monitor sx
   ;;
# DESTRA
dx)
   individua_monitors
   init_monitor dx
   ;;
# OFF
off)
    echo "Spengo il monitor"
    individua_monitors
    spengni_monitor
    exit 0
    ;;
# ALTRO
*)
   echo "Parametro errato!"
   usage
   exit 1
   ;;
esac
