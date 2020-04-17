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
# |_____|_|     |_|  |_||_____|_|				VERSIONE GUI con zenity
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

# export DISPLAY=":0"

# Help e descrizione
function usage()
{
	echo "================= USO DI ${0} ===================

	Script per l'attivazione dello Schermo ThinkVision lt-1421
	Lo script puo essere eseguito con i permessi utente.

	Necessita la presenza di xrandr e, per la GUI, di zenity.

	Lo script individua automamente lo schermo principale e avvia lo schermo
	lt-1421 alla sua sinistra o destra.

	Sintassi: ${0} [sx,dx,off] -h
	Parametri:
	-nessuno-        GUI con zenity
	sx               Prova ad avviare lo Schermo lt-1421 a SINISTRA del princpale
	dx  [default]    Prova ad avviare lo Schermo lt-1421 a DESTRA del princpale
	off              Spegne lo Schermo lt-1421
	-h               Questo help

	hint to paolo@baviero.it"
}

function scrivi_shell_GUI() {
	# output su terminale o su zenity
	if [[ "$GUI" == "no" ]]; then
		echo -e "$1"
	else
		zenity --error --width=400 --height=200 --timeout 15 --text "$1"
	fi
}

# Trovo gli indicatori dei due Schermo, il principale (riferimento) e l'lt-1421
function individua_Schermo() {
	# Individuo il Schermo Principale
	PRINC=`xrandr | grep primary | awk '{print $1}'`
	if [ "$PRINC" ];  then
		echo "Schermo principale trovato - $PRINC"
	else
		scrivi_shell_GUI "Riconoscimento automatico del Schermo principale NON riuscito!\nPer il corretto funzionamento e' necessario individuare il numero indicativo del Schermo PRINCPALE ed assegnare il valore alla variabile \$PRINC.\nPuoi provare da terminale usando l'output del comando:\n xrandr\ned inserendo \"a mano\" il valore nello script"
		exit 1
	fi

	# Individuo il Schermo ThinkVision
	DVIN=`xrandr | grep DVI* | cut -f1 -d' '`
	if [ "$DVIN" ];  then
		echo "Schermo lt-1421 trovato - $DVIN"
	else
		scrivi_shell_GUI "Schermo lt-1421 NON TROVATO!\nPotrebbe non essere collegato correttamente? Se problema invece persiste prova a vedere l'output di xrandr da terminale e inserire il numero identiicativo del Schermo \"a mano\" nello script"
		exit 1
	fi
}

# Imposto risoluzione e caratteristiche del Schermo e lo attivo nella posizione desiderata
function init_Schermo() {
	LIBGL_ALWAYS_SOFTWARE=1
	xrandr --newmode "1368x768_59.90"  85.72  1368 1440 1584 1800  768 769 772 795  -HSync +Vsync &> /dev/null
	xrandr --addmode $DVIN 1368x768_59.90 &> /dev/null
	xrandr --output $DVIN --off &> /dev/null
	if [ $1 == sx ]; then
		echo "Provo ad avviare il Schermo a SINSTRA del principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --left-of $PRINC &> /dev/null
	elif [ $1 == dx ]; then
		echo "Provo ad avviare il Schermo a DESTRA del principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --right-of $PRINC &> /dev/null
	fi
}
# Spengo il Schermo lt-1421
function spengni_Schermo() {
	echo "Spengo il Schermo"
	xrandr --output $DVIN --off &> /dev/null
	exit 0
}

##-------------MAIN----------
# Controllo se presenti parametri
# Se non presenti avvio GUI
if [ $# -lt 1 ]; then
	GUI="on"
	individua_Schermo
	SELEZ=`zenity --title="$0" --width=400 --height=270 --text="<big><b>ATTIVAZIONE THINKVSION LT-1421</b></big>\nSchermo principale individuato:  $PRINC\nSchermo Thinkvision individuato:  $DVIN\n\nDove lo vorresti posizionare?" --list --column "VLF" --column "Lato" TRUE "A Destra" FALSE "A Sinistra" FALSE "Spegni lt-1421" --radiolist 2>/dev/null`
	# se annullato esco
	if [ -z "$SELEZ" ]; then
		exit
	fi
	# presenza parametro
else
	GUI="off"
	individua_Schermo
	SELEZ="$1"
fi

case "$SELEZ" in
	# SINISTRA
	sx|"A Sinistra")
	init_Schermo sx
	;;
	# DESTRA
	dx|"A Destra")
	init_Schermo dx
	;;
	# OFF
	off|"Spegni lt-1421")
	spengni_Schermo
	exit 0
	;;
	# ALTRO
	*)
	echo "Parametro errato!"
	usage
	exit 1
	;;
esac
