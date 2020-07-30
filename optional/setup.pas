{
	  Copyright (C) 2018,2019 daltomi <daltomi@disroot.org> <danieltborelli@tutanota.com>

	  This library is free software; you can redistribute it and/or modify it
	  under the terms of the GNU Library General Public License as published by
	  the Free Software Foundation; either version 2 of the License, or (at your
	  option) any later version.

	  This program is distributed in the hope that it will be useful, but WITHOUT
	  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
	  for more details.

	  You should have received a copy of the GNU Library General Public License
	  along with this library; if not, write to the Free Software Foundation,
	  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}


{
	== Sinopsis ==
	
		Permite utilizar archivos de vídeos como protector de pantalla con XScreenSaver y MPV.
		
		Primero se buscan todos los archivos de vídeo en un directorio, luego de esa lista,
		se reproduce uno de ellos seleccionado aleatoriamente

	== Dependencias ==
	
		XScreenSaver (xscreensaver-demo)
	
		MPV (mpv)
		
		xscr_video.sh (script)
		
	== Compilación ==
		
		(Free Pascal Compiler >= 3.0)
		
		fpc setup.pas
	
	
	== Manual del programa ==
		
		Una vez compilado.
		
	== Instalar == 
	
		./setup -i "video_dir"

		- Se verifican las dependencias(MPV, xscreensaver-demo, etc).
		- Se copia el script xscr_video.sh hacia ~/.local/bin.
		- Se modifica el archivo de configuración ~/.xscreensaver.
		
		Nota:
			La instalación es local al usuario que ejecuta éste programa.
		

	== Desinstalar ==

		./setup -u
		
		- Se eliminan las modificaciónes del archivo de configuración ~/.xscreensaver.
		- Se elimina el script xscr_video.sh ubicado en ~/.local/bin.
		
		Nota:
			La desinstalación es local al usuario que ejecuta éste programa.

	== Fin Manual del programa ==
	
	
	== Script ==
	
		xscr_video.sh

		Éste script se utiliza con el programa xscreensaver-demo,
		para reproducir vídeos como protector de pantalla.

		Nota:
			MPV repite el vídeo infinitamente.
			MPV no repruducirá audio, en cualquier caso, modificar éste script para hacerlo.
	
	== Tips ==
	
		- Buscar en sitios como youtube.com referencias a "video ambient loop".
		  Se encuentran vídeos como nieve, fuego, lluvia, etc.
		  
		- Organizar los vídeos que se usarán en un directorio especial, como videos4screensaver, etc.
		
		
}

program setup;

uses SysUtils, Classes, BaseUnix;

const
	kBinPath 		= '/usr/bin:/usr/local/bin:/bin';
	kLocalDir		= '.local';
	kLocalBinDir		= kLocalDir + '/' + 'bin';
	kBashScript		= 'xscr_video.sh';
	kXScreenSaverConfig	= '.xscreensaver';
	kXScreenSaverBin	= 'xscreensaver-demo';
	kMpvBin			= 'mpv';
	kTitulo			= '"XSCR_VIDEO"';

type
	TAction			= (eActionInstall, eActionUninstall, eActionNone);

var
	srcFile 		: TFileStream;
	dstFile		 	: TFileStream;
	config			: TStringList;
	answer 			: char;
	path			: string;
	count			: integer;
	lineCount		: integer 	= 0;
	action			: TAction 	= eActionNone;
	videosDir		: string 	= '';



function Install() : boolean;
begin
	if ExeSearch(kMpvBin, kBinPath) = '' then
	begin
		WriteLn('* Error: no se encontró el programa ''' + kMpvBin + '''');
		Exit(False);
	end;

	if ExeSearch(kXScreenSaverBin, kBinPath) = '' then
	begin
		WriteLn('* Error: no se encontró el programa ''' + kXScreenSaverBin + '''');
		Exit(False);
	end;

	if FileSearch(kXScreenSaverConfig, GetUserDir()) = '' then
	begin
		WriteLn('* Error: no se encontró el archivo de Configuración de ''' + kXScreenSaverBin + '''');
		WriteLn('  Inicie ' + kXScreenSaverBin + ' por primera vez, temporalmente, para que genere');
		WriteLn('  el archivo de Configuración correspondiente.');
		Exit(False);
	end;

	if not FileExists(videosDir) then
	begin
		WriteLn('* Error: no existe la ruta a los archivos de videos: ''' + videosDir + '''');
		Exit(False);
	end
	else if (FileGetAttr(videosDir) and faDirectory) <> faDirectory then
	begin
		WriteLn('* Error: se encontró ''' + videosDir + ''' pero no es un directorio.');
		Exit(False);
	end;

	path := GetUserDir() + kLocalDir;

	if FileSearch(kLocalDir, GetUserDir()) = '' then
		MkDir(path)
	else
	begin
		if (FileGetAttr(path) and faDirectory) <> faDirectory then
		begin
			WriteLn('* Error: se encontró ''' + path + ''' pero no es un directorio.');
			Exit(False);
		end;
	end;

	path := GetUserDir() + kLocalBinDir;

	if FileSearch(kLocalBinDir, GetUserDir()) = '' then
		MkDir(path)
	else
	begin
		if (FileGetAttr(path) and faDirectory) <> faDirectory then
		begin
			WriteLn('* Error: se encontró ''' + path + ''' pero no es un directorio.');
			Exit(False);
		end;
		
	end;

	if not FileExists(kBashScript) then { Local al prorgrama }
	begin
		WriteLn('* Error: no se encontró el kBashScript ''' + kBashScript + '''');
		WriteLn('  Debería estar ubicado en el directorio de éste programa.');
		Exit(False);
	end;

	path := GetUserDir() + kLocalBinDir +  '/' + kBashScript;

	if FileExists(path) then
	begin
		WriteLn('* El archivo ''' +  path + ''' ya existe. ¿Sobrescribirlo? S/n');
		ReadLn(answer);
		if answer <> 'S' then
		begin
			WriteLn('* Error: no se permitió sobrescribir el archivo.');
			Exit(False);
		end;
	end;

	srcFile := TFileStream.Create(kBashScript, fmOpenRead);
	dstFile := TFileStream.Create(path, fmCreate);
	dstFile.CopyFrom(srcFile, srcFile.Size);
	srcFile.Free();
	dstFile.Free();

	FpChMod(path, S_IXUSR or S_IRUSR or S_IWUSR);

	config := TStringList.Create();
	config.LoadFromFile(GetUserDir() + kXScreenSaverConfig);

	for count := config.count - 1 downto 0 do
	begin
		if Pos('\n\', config[count]) > 0 then
		begin
			lineCount := count;
			Break;
		end;
	end;

	config.Insert(lineCount + 1, #9 + #9 + kTitulo + path + ' ' + videosDir + ' ' + '$XSCREENSAVER_WINDOW \n\');
	config.SaveToFile(GetUserDir() + kXScreenSaverConfig);
	config.Free();
	Exit(True);
end;


procedure Uninstall();
var
	okXScreenSaver 	: boolean;
	okScript 	: boolean;
	countFind	: integer = 0;
begin
	if FileSearch(kXScreenSaverConfig, GetUserDir()) = '' then
	begin
		WriteLn('* Error: no se encontró el archivo de Configuración de ''' + kXScreenSaverBin + '''');
		WriteLn('  Archivo de Configuración: ''' + kXScreenSaverConfig + '''');
		okXScreenSaver := False;
	end
	else
	begin
		WriteLn('* Buscando itemes en el archivo de Configuración ' + kXScreenSaverConfig + ' ...');
		
		config := TStringList.Create();
		config.LoadFromFile(GetUserDir() + kXScreenSaverConfig);
		
		for count:= config.count - 1 downto 0 do
		begin
			if Pos(kTitulo, config[count]) > 0 then
			begin
				if RightStr(config[count], 2) = ' \' then
				begin
					config.Delete(count);
					config.Delete(count);
					config.Delete(count);
				end
				else
					config.Delete(count);

				Inc(countFind);
			end;
		end;

		if countFind > 0 then
		begin
			config.SaveToFile(GetUserDir() + kXScreenSaverConfig);
			WriteLn('* Se desinstalaron ' + IntToStr(countFind) + ' itemes.');
			okXScreenSaver := True;
		end
		else
		begin
			WriteLn('* No se encontró ningun item para desinstalar en el archivo de Configuración ''' + kXScreenSaverConfig + '''');
			okXScreenSaver := False;
		end;
		config.Free();
	end;

	path := GetUserDir() + kLocalBinDir +  '/' + kBashScript;

	WriteLn('* Buscando el script ' + path + ' ...');

	if FileExists(path) then
	begin
		WriteLn('* Se encontró el script ''' +  path + '''. ¿Desea eliminarlo? S/n');
		ReadLn(answer);
		if answer <> 'S' then
		begin
			WriteLn('* Error: no se permitió eliminar el script.');
			okScript := False;
		end
		else
		begin
			DeleteFile(path);
			WriteLn('* Se eliminó el script ''' +  path + '''');
			okScript := True;
		end;
	end
	else
	begin
		WriteLn('* No se encontró el script ''' +  path + '''');
		okScript := False;
	end;

	if ((not okScript) and okXScreenSaver) or ((not okXScreenSaver) and okScript) then
		WriteLn('* Sólo algunos pasos de la desinstalación se completaron.')

	else if (not okScript) and (not okXScreenSaver) then
		WriteLn('* Ningúno de los pasos de la desinstalación se completaron.')

	else if (okScript and okXScreenSaver) then
		WriteLn('* La desinstalación se completo correctamente.');
end;


procedure Help; {noreturn}
begin
	path := GetUserDir() + kLocalBinDir +  '/';
	WriteLn(' Help:');
	WriteLn('   -i   Install : Indicar directorio de archivos de vídeos ha reproducir.');
	WriteLn('   -u   Uninstall.');
	WriteLn();
	WriteLn('   Install      : ./setup -i ~/Vídeos/mis_videos');
	WriteLn('   Se copia el script ''' + kBashScript + ''' hacia '  + path);
	WriteLn('   Se modifica el archivo de Configuración ''' + GetUserDir() + kXScreenSaverConfig + '''');
	WriteLn();
	WriteLn('   Uninstall   : ./setup -u');
	WriteLn('   Se elimina el script ''' + kBashScript + ''' ubicado en '  + path);
	WriteLn('   Se elimina los itemes agregados en el archivo de Configuración ''' + GetUserDir() + kXScreenSaverConfig + '''');
	Halt(1);
end;


begin {  MAIN  }

	if ParamCount() = 0 then Help();

	for count := 1 to ParamCount do
	begin
		if ParamStr(count) = '-i' then
		begin
			action := eActionInstall;
			videosDir := ParamStr(count + 1);
		end;

		if ParamStr(count) = '-u' then action := eActionUninstall;
	end;

	if action = eActionNone then Help();

	if (videosDir = '') and (action <> eActionUninstall) then Help();

	if action = eActionInstall then
	begin
		if Install() = False then
			WriteLn('No se completó la instalación.')
		else
			WriteLn('La instalación se completo correctamente.');
	end
	else
		Uninstall();
end.
{TheEnd}
