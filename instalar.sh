#!/bin/bash

if [ $# -ne 1 ] || [ "$1" == "." ]; then
	echo "* Error. Faltan parámetros."
	echo
	echo "* Indicar el directorio donde se encuentran los archivos de vídeos ha reproducir."
	echo
	echo "* Ejemplo: ./instalar.sh ~/Vídeos/mis_videos"
	exit
fi

if [ ! -e "$1" ] || [ ! -d "$1" ]; then
	echo "* Directorio de vídeos no válido."
	exit
fi

# Lugar en donde se encuentran los vídeos.
videos="$1"

# Archivo de configuración de xscreensaver
config=$HOME/.xscreensaver

# Ubicación de destino del script
destino=$HOME/.local/bin

# Nombre del script de destino
script=xscr_video.sh

usr_bin="/usr/bin"

usr_local_bin="/usr/local/bin"


# Verificar si existe el programa MPV
if [ ! -e $usr_bin/mpv ] && [ ! -e $usr_local_bin/mpv ]; then
	echo "* No se encontró instalado el programa MPV."
	exit
fi

# Verificar si existe el programa ed
if [ ! -e $usr_bin/ed ] && [ ! -e $usr_local_bin/ed ]; then
	echo "* No se encontró instalado el programa ed."
	echo "* Necesario sólo para el script 'instalar.sh'"
	exit
fi

# Verificar si existe el programa xscreensaver-demo
if [ ! -e $usr_bin/xscreensaver-demo ] && [ ! -e $usr_local_bin/xscreensaver-demo ]; then
	echo "* No se encontró instalado el programa xscreensaver-demo."
	exit
fi

# Verificar si existe el archivo .xscreensaver
if [ ! -e "$config" ]; then
	echo "* El archivo $config no existe. Ejecute xscreensaver-demo primero."
	exit
fi

# Verificar que no exista ya el script...
if [ -e "$destino/$script" ]; then
	echo "* El archivo $destino/$script ya existe. ¿Sobrescribirlo? S/n"         
	read -n 1 continuar
	echo
	if [ "$continuar" != "S" ]; then
		echo; echo "* No se completo la instalación."
		exit
	fi
fi

# Crear el directorio por si no existe.   
mkdir -p $destino

# .. se continua, copiar el script al directorio bin.
cp $script $destino/$script

echo "* El scipt '$script' se ha instalado en: '$destino/$script'"

chmod +x $destino/$script

# Actualizar .xscreensaver

# Busca la última linea de 'programs':
linea=$(grep -n  '\\n\\' $config | cut -d: -f1 | tail -n 1)

# Escribir en la siguiente.
linea=$(($linea + 1))

programa="\"XSCR_VIDEO\" $destino/$script $videos \$XSCREENSAVER_WINDOW \\n\\"

# Agregamos el ítem en dónde corresponde.
printf '%s\n' H ${linea}i "$programa" . wq | ed -s $config

echo; echo "* La instalación se completó con éxito."
echo; echo "* A continuación inicie 'xscreensaver-demo' y luego"
echo       "   seleccione XSCR_VIDEO en la lista de 'Modos de visualización'".

exit 0
