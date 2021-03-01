## xscr_video - XScreenSaver video

Permite utilizar archivos de vídeos como protector de pantalla con XScreenSaver y MPV.

<img src="https://github.com/daltomi/xscr_video/raw/master/screenshot.png"/>




### Instalación

Ejecutar el script `instalar.sh`


### Descripción de los script's

#### instalar.sh

Se utiliza para verificar dependencias, copiar el script `xscr_video.sh` hacia `~/.local/bin` y
modificar el archivo de configuración `~/.xscreensaver`

    Notas:
        La instalación es local al usuario que ejecuta éste script.


#### xscr_video.sh

Éste script se utilizará, luego de la instalación, por el programa `XScreenSaver`
para reproducir vídeos como protector de pantalla.

Funcionamiento: se buscan todos los archivos de vídeo en un directorio, luego de esa lista
se reproduce uno de ellos seleccionado aleatoriamente.

    Notas:
        MPV repite el vídeo infinitamente.
        MPV no repruducirá audio, en cualquier caso, modificar éste script para hacerlo.


#### optional/setup.pas (experimental)

Igual al script instalar.sh pero permite desinstalar, es decir, revertir los
cambios en el archivo de configuración `~/.xscreensaver` y eliminar el script
`xscr_video.sh` de la ubicación `~/.local/bin`.


### Tips 

1): Buscar en sitios como youtube.com referencias a "video ambient loop". 
    Se encuentran vídeos como nieve, fuego, lluvia, etc.

2): Organizar los vídeos que se usarán en un directorio especial, como `videos4screensaver`, etc.
