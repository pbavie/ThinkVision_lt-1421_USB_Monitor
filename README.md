# ThinkVision_lt-1421_USB_Monitor
Script in bash per l'attivazione del monitor ThinkVision lt-1421, non necessita di particolari permessi e puo essere quindi eseguito come utente comune.

Necessita la presenza di xrandr per l'impostazione dello schermo e zenity per la piccola GUI, altri comandi necessari dovrebbero essere gia' presenti di default nelle classiche distribuzoni linux.

Lo script individua il monitor principale (o comunque un altro monitor) e avvia il monitor lt-1421 nella posizione scelta dell'utente.

Versione ThinkVision (OLD - Sostituita da versione con GUI)
Versione funzionante ma con poche feature

#Versione GUI
Script completo,usabile sia da terminale che con una semplice GUI realizata con zenity. Gestisce tutte le posizioni possibili compreso il clone dello schermo.

Parametri possibili:
	-nessuno-		GUI con zenity
	dx|r [default]		DESTRA del princpale
	sx|l		SINISTRA del princpale
	up		SOPRA del princpale
	down		SOTTO del princpale
	same|clone	CLONA i due Schermi
	off		Spegne lo Schermo lt-1421


# Versione Small
Solo il necessario per l'individuazione del monitor e la sua attivazione in una posizione. Tutto il necessario quindi per essere usato nelle automazioni.


# 10-ThinkVision_lt-1421.conf
Allego una versione di un file .conf per - /etc/X11/xorg.conf.d/ -
per la individuazione automatica dello schermo da parte del sistema.

# Usage:
$ chmod +x script.bash
$ ./script.bash

Per la versione GUI puo' essere comodo crearsi un lanciatore.


# Reference:
Thanks to https://github.com/thecaffiend/tvlt1421_ubuntu
