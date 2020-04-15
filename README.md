# ThinkVision_lt-1421_USB_Monitor
Script in bash per l'attivazione del monitor ThinkVision lt-1421, non necessita di particolari permessi e puo essere quindi eseguito come utente comune.

Necessita la presenza di xrandr per l'impostazione dello schermo e zenity per la piccola GUI, altri comandi dovrebbero essere gia' presenti di default.

Lo script individua il monitor principale e avvia il monitor lt-1421 alla sua sinistra o destra a seconda della scelta dell'utente. 

Le tre versioni presenti svolgono lo stesso compito

# Usage:
$ chmod +x script.bash
$ ./script.bash

Per la versione GUI puo' essere comodo crearsi un lanciatore.


# Reference:
Thanks to https://github.com/thecaffiend/tvlt1421_ubuntu