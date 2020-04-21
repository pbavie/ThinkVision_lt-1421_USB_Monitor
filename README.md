# ThinkVision_lt-1421_USB_Monitor
Script in bash per l'attivazione del monitor ThinkVision lt-1421, non necessita di particolari permessi e puo essere quindi eseguito come utente comune.

Per funzionare serve -xrandr- per l'impostazione dello schermo e -zenity- per la piccola GUI.

Lo script individua il monitor principale (o comunque un altro monitor collegato) e avvia il ThinkVision lt-1421 nella posizione scelta dell'utente.

Versione ThinkVision (OLD - Sostituita da versione con GUI)
Versione funzionante ma con poche feature

# Versione GUI
Script completo,usabile sia da terminale che con una semplice GUI realizzata con zenity. Gestisce tutte le posizioni possibili compreso il clone dello schermo.

Possibili parametri da terminale (Versione GUI):
	-nessuno-		GUI con zenity
	dx|r [default]		DESTRA del princpale
	sx|l		SINISTRA del princpale
	up		SOPRA del princpale
	down		SOTTO del princpale
	same|clone	CLONA i due Schermi
	off		Spegne lo Schermo lt-1421


# Versione Small
Solo il necessario per l'individuazione del monitor e la sua attivazione in una posizione predefinita (default a DX). Tutto il necessario quindi per essere usato nelle automazioni.


# 10-ThinkVision_lt-1421.conf
Allego una versione di un file .conf per - /etc/X11/xorg.conf.d/ -
per la individuazione automatica dello schermo da parte del sistema al boot, non conosco X11 ma a volte funziona :).

# Usage:
$ chmod +x script.bash
$ ./script.bash

Per la versione GUI puo' essere comodo crearsi un lanciatore.


# Reference:
Thanks to https://github.com/thecaffiend/tvlt1421_ubuntu
