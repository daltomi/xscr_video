#!/bin/bash

# Lugar en donde se encuentran los vídeos.
videos="$1"

wid="$2"

# Indica si se reproduce audio o no.
audio="--no-audio"

# Un simple array...
declare -a array

# Separar la lista por salto de línea.
SAVEIFS=$IFS
IFS=$'\n'

# Listamos los archivos disponibles según formato.
for nombre in $(ls $videos/{*.avi,*.mp4,*.flv,*.webm,*.ogv} 2>/dev/null)
do
	N=${#array[*]} # Número de ítemes del array.

	array[N]=$nombre; # Almacenamos el nombre.
done

# Restaurar
IFS=$SAVEIFS

# Obtener un número aleatorio de rango en base al número de ítemes del array.
rand=$(( RANDOM % ${#array[*]} ))

# Esperar a que la ventana de xscreensaver esté lista.
sleep 1s 

# Que bash nos envie algunas señales provenientes de xscreensaver.
trap : SIGTERM SIGINT SIGHUP

# Iniciamos MPV en segundo plano.
mpv --really-quiet $audio --fs --loop=inf --no-stop-screensaver --wid=$wid "${array[$rand]}" &

# El ID del proceso de MPV
mpv_pid=$!

# Esperamos alguna señal de xscreensaver
wait

# Le notificamos a MPV que estamos saliendo.
kill $mpv_pid
