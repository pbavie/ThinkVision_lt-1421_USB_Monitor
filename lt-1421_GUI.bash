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
# |_____|_|     |_|  |_||_____|_|				VERSIONE GUI (zenity)
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
function usage(){
	echo -e "
	  ====================== USO DI ${0} ========================

	Script per l'attivazione dello Schermo ThinkVision lt-1421
	Lo script puo essere eseguito con i permessi utente.

	Necessita la presenza di xrandr e, per la GUI, di zenity.

	Lo script individua automamente lo schermo principale
	(o comunque uno di riferimento) e avvia il ThinkVision
	nella posizione desiderata.

	Sintassi: ${0} [sx,dx,up,down,same,off]
	Parametri:
	-nessuno-		GUI con zenity
	dx|r [default]		DESTRA del princpale
	sx|l		SINISTRA del princpale
	up		SOPRA del princpale
	down		SOTTO del princpale
	same|clone	CLONA i due Schermi
	off		Spegne lo Schermo lt-1421

	hint to paolo@baviero.it"
}

# Scrive errori su terminale o GUI
function scrivi_shell_GUI(){
	# output su terminale o su zenity
	if [ "$GUI" == "off" ]; then
		echo -e "$1"
	else
		zenity --error --width=400 --height=200 --text "$1"
	fi
}

# In caso di problemi con l'identificazione dello schermo primario
function individua_Schermo_conflict(){
	SCHERMI_CONN=(`xrandr | grep " connected" | awk '{print $1}'`)
	echo "Trovati ${#SCHERMI_CONN[*]} schermi connessi:"
	i=0
	while [ $i -lt ${#SCHERMI_CONN[*]} ]; do
		echo "$i - ${SCHERMI_CONN[$i]}"
		# Se e' il ThinkVision
		if [[ ${SCHERMI_CONN[$i]} =~ ^DVI ]]; then
			echo "      -> Questo e' lo schermo lt-1421"
			DVIN=${SCHERMI_CONN[$i]}

			# Individuo lo Schermo Principale
			PRINC=`xrandr | grep primary | awk '{print $1}'`
			if [ "$PRINC" ] && [ "$PRINC" != "$DVIN" ];  then
				echo "Schermo principale trovato - $PRINC"
			else	# Ne assegno uno a caso tra quelli attivi.
				if [ "${SCHERMI_CONN[(($i-1))]}" ]; then	# precedente
					echo "Imposto come principale  ${SCHERMI_CONN[(($i-1))]}"
					PRINC=${SCHERMI_CONN[(($i-1))]}
				elif [ "${SCHERMI_CONN[(($i+1))]}" ]; then	# sucessivo
					echo "Imposto come principale  ${SCHERMI_CONN[(($i+1))]}"
					PRINC=${SCHERMI_CONN[(($i+1))]}
				else	# nessuno schermo, problemi :)
					scrivi_shell_GUI "${SCHERMI_CONN[$i]} sembra essere l'unico schermo connesso... qualquadra non cosa"
					exit 1
				fi
				# Avviso dell'accaduto
				if [ "$GUI" == "on" ]; then
					zenity --warning --width=400 --height=200 --text "ATTENZIONE - Sembra che nessuno schermo fosse impostato come principale.\nQuesto puo' succedere se la configurazione precedente era di CLONARE lo schermo.\n\nPer ovviare a questo problema lo schermo\n		ThinkVision (lt-1421) -> $DVIN\nverra' posizionato usando come riferimento lo schermo\n		\"principale\" -> $PRINC\n"
				fi
			fi
		fi
		let i=i+1
	done

}

# Trovo gli indicatori dei due Schermi, il principale (riferimento) e l'lt-1421
function individua_Schermo(){
	# Individuo lo Schermo Principale
	PRINC=`xrandr | grep primary | awk '{print $1}'`
	if [ "$PRINC" ];  then
		echo "Schermo principale trovato - $PRINC"
	else
		individua_Schermo_conflict
	fi

	# Individuo lo Schermo ThinkVision
	DVIN=`xrandr | grep DVI* | cut -f1 -d' '`
	if [ "$DVIN" ];  then
		echo "Schermo lt-1421 trovato - $DVIN"
	else
		individua_Schermo_conflict
	fi

	# Se sono lo stesso monitor manca il riferimento
	if [ "$PRINC" == "$DVIN" ]; then
		echo "Sono lo stesso monitor, non va' bene."
		individua_Schermo_conflict
	fi
}

# Imposto risoluzione e caratteristiche del Schermo e lo attivo nella posizione desiderata o lo spengo
function init_Schermo() {
	# LIBGL_ALWAYS_SOFTWARE=1

	if [ $SELEZ == "off" ];then
		spengni_Schermo
	fi

	xrandr --newmode "1368x768_59.90"  85.72  1368 1440 1584 1800  768 769 772 795  -HSync +Vsync &> /dev/null
	xrandr --addmode $DVIN 1368x768_59.90 &> /dev/null
	xrandr --output $PRINC --primary
	xrandr --output $DVIN --off &> /dev/null

	if [ $SELEZ == sx ]; then
		echo "Provo ad avviare il Schermo a SINSTRA del principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --left-of $PRINC &> /dev/null
	elif [ $SELEZ == dx ]; then
		echo "Provo ad avviare il Schermo a DESTRA del principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --right-of $PRINC &> /dev/null
	elif [ $SELEZ == up ]; then
		echo "Provo ad avviare il Schermo a SOPRA il principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --above $PRINC &> /dev/null
	elif [ $SELEZ == down ]; then
		echo "Provo ad avviare il Schermo a SOTTO il principale"
		xrandr --output $DVIN --mode "1368x768_59.90" --below $PRINC &> /dev/null
	elif [ $SELEZ == same ]; then
		echo "Provo ad avviare il Schermo CLONANDO il principale"
		xrandr --output $DVIN --primary --mode "1368x768_59.90" --same-as $PRINC &> /dev/null
	fi

}
# Spengo lo Schermo lt-1421
function spengni_Schermo() {
	echo "Spengo lo Schermo"
	xrandr --output $PRINC --primary
	xrandr --output $DVIN --off &> /dev/null
	exit 0
}

##-------------MAIN----------
# Se non presenti parametri avvio GUI
if [ $# -lt 1 ]; then
	GUI="on"
	individua_Schermo_conflict
	SELEZ=`zenity --title="$0" --width=400 --height=350 --text="<big><b>ATTIVAZIONE THINKVSION LT-1421</b></big>\nSchermo principale individuato:  $PRINC\nSchermo Thinkvision individuato:  $DVIN\n\nDove lo vorresti posizionare?" --list --column "VLF" --column "Lato" TRUE "Destra" FALSE "Sinistra" FALSE "Sopra" FALSE "Sotto" FALSE "Schermi Uguali" FALSE "Spegni lt-1421" --radiolist 2>/dev/null`
	# se annullato esco
	if [ -z "$SELEZ" ]; then
		exit
	fi
	# presenza parametro, utente al terminale
else
	GUI="off"
	SELEZ="$1"
fi

# Seleziono cosa ha scelto l'utente
case "$SELEZ" in
	# DESTRA
	r|dx|"Destra")
	SELEZ="dx"
	;;
	# SINISTRA
	l|sx|"Sinistra")
	SELEZ="sx"
	;;
	# SOPRA
	up|"Sopra")
	SELEZ="up"
	;;
	# SOTTO
	down|"Sotto")
	SELEZ="down"
	;;
	# DUPLICA
	same|clone|"Schermi Uguali")
	SELEZ="same"
	;;
	# OFF
	off|"Spegni lt-1421")
	SELEZ="off"
	;;
	# ALTRO
	*)
	echo "Parametro errato!"
	usage
	exit 1
	;;
esac

# Se varabili impostate nella GUI salto altrimenti ricavo
if [ -z $DVIN ] || [ -z $PRINC ]; then
individua_Schermo_conflict
fi

# ESEGUO - imposto Schermo
init_Schermo

exit 0
# END , See you!
