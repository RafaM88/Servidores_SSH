#############Funciones#######################


$menu = $false

$cruz = [char]0x2716
$check = [char]0x2714
#$cerveza = [char]0x1F37A
#$cervezas = [char]0x1F37B


#Función que imprime texto caracter por caracter
function ImprimirLetraPorLetra {
    param (
        [string]$texto,
	[System.ConsoleColor]$color,
    [int]$intervalo = 50
    )

    foreach ($caracter in $texto.ToCharArray()) {
        # Imprimir el carácter actual
	       		Write-Host -NoNewline $caracter -ForegroundColor $color 
	
        # Pausa breve entre cada carácter para simular la impresión letra por letra
        Start-Sleep -Milliseconds $intervalo
    }

    # Imprimir un salto de línea al final para mantener la salida ordenada
    #Write-Host
}

function ArchivoEntornos {
	 # Ruta completa al archivo env.txt en el mismo directorio que el script
    $rutaEnvTxt = Join-Path -Path $PSScriptRoot -ChildPath "env.txt"

    # Verificar si el archivo env.txt existe
    if (-not (Test-Path -Path $rutaEnvTxt)) {
		ImprimirLetraPorLetra -texto "Cargando configuración inicial`n" -color DarkMagenta
		
 Start-Sleep -Seconds 1
 
        ImprimirLetraPorLetra -texto "Creando fichero de variables de entorno`n" -color DarkYellow
		
 Start-Sleep -Seconds 1
		ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
        # Crear el archivo env.txt
        New-Item -Path $rutaEnvTxt -ItemType File -Force | Out-Null
        ImprimirLetraPorLetra -texto "Fichero de variables de entorno creado correctamente`n" -color DarkGreen
		CrearAccesoDirecto -Icono "$PSScriptRoot\icono.ico"
	
}
}


#########################

function Emoji{
	param(
	[string]$codigo
	)
	$EmojiIcon = [System.Convert]::toInt32($codigo,16)
$emoji = [System.Char]::ConvertFromUtf32($EmojiIcon)
return $emoji
}



#Función que lee entrada por teclado imprimiento el mensaje letra por letra
function LeerConMensajeLetraPorLetra {
    param (
        [string]$mensaje,
	[System.ConsoleColor]$color
    )

    # Imprimir cada carácter del mensaje uno por uno con un pequeño retraso
    foreach ($caracter in $mensaje.ToCharArray()) {
        Write-Host -NoNewline $caracter -ForegroundColor $color
        Start-Sleep -Milliseconds 50  # Ajusta el tiempo de espera según sea necesario
    }

    # Solicitar entrada del usuario después de mostrar el mensaje completo
    $respuesta = Read-Host
    return $respuesta
}

#Función que genera el acceso directo del programa
function CrearAccesoDirecto {
    param (
        [string]$Icono = ""
    )
    # Ruta completa al archivo env.txt en el mismo directorio que el script
    $rutaEnvTxt = Join-Path -Path $PSScriptRoot -ChildPath "env.txt"

    # Verificar si el archivo env.txt no existe y crearlo si es necesario
    if (-not (Test-Path -Path $rutaEnvTxt)) {
        # Crear el archivo env.txt vacío
        $null = New-Item -Path $rutaEnvTxt -ItemType File -Force
    }

    # Leer el contenido del archivo env.txt
    $contenidoEnv = Get-Content -Path $rutaEnvTxt -ErrorAction SilentlyContinue
    $variablesEnv = @{}

    # Convertir el contenido en un hashtable si el archivo no está vacío
    foreach ($linea in $contenidoEnv) {
        if ($linea -match '^\s*(\S+)\s*=\s*(\S+)\s*$') {
            $key, $value = $linea -split '=', 2
            $variablesEnv[$key.Trim()] = $value.Trim()
        }
    }

    # Verificar si la variable desktop está definida y tiene valor "true"
    if (-not $variablesEnv.ContainsKey('desktop') -or $variablesEnv['desktop'] -ne "true") {
        # Actualizar el valor de desktop a "true"
        $variablesEnv['desktop'] = "true"
        ImprimirLetraPorLetra -texto "Creando acceso directo en el escritorio`n" -color DarkYellow
        ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
        # Guardar el hashtable como líneas en el archivo env.txt
        $nuevoContenidoEnv = $variablesEnv.GetEnumerator() | ForEach-Object {
            "{0}={1}" -f $_.Key, $_.Value
        }
        Set-Content -Path $rutaEnvTxt -Value $nuevoContenidoEnv

        # Ruta al archivo init.bat en la carpeta superior al script
        $rutaInitBat = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "init.bat"

        # Verificar si el archivo init.bat existe
        if (Test-Path -Path $rutaInitBat) {
            # Ruta al escritorio del usuario
            $rutaEscritorio = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'Lista de servidores SSH.lnk')

            # Crear el acceso directo
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($rutaEscritorio)
            $shortcut.TargetPath = $rutaInitBat
            # Asignar el icono si se proporcionó una ruta de icono
            if ($Icono -ne "") {
                $Shortcut.IconLocation = $Icono
            }
            $shortcut.Save()
            ImprimirLetraPorLetra -texto "Acceso directo creado correctamente`n" -color DarkGreen
        }
    }
}


#Función que almacena o recupera el nombre del usuario
function Nombre {
    # Ruta completa al archivo env.txt en el mismo directorio que el script
    $rutaEnvTxt = Join-Path -Path $PSScriptRoot -ChildPath "env.txt"

    # Verificar si el archivo env.txt existe y leer su contenido
    if (Test-Path -Path $rutaEnvTxt) {
        $contenidoEnv = Get-Content -Path $rutaEnvTxt -ErrorAction SilentlyContinue
        $variablesEnv = @{}

        # Convertir el contenido en un hashtable si el archivo no está vacío
        foreach ($linea in $contenidoEnv) {
            if ($linea -match '^\s*(\S+)\s*=\s*(\S+)\s*$') {
                $key, $value = $linea -split '=', 2
                $variablesEnv[$key.Trim()] = $value.Trim()
            }
        }
    } else {
        # Si el archivo no existe, crear un hashtable vacío
        $variablesEnv = @{}
    }

    # Verificar si la variable "nombre" está definida
    if (-not $variablesEnv.ContainsKey('nombre')) {
        # Si la variable "nombre" no está definida, pedir al usuario que introduzca su nombre
        ImprimirLetraPorLetra -texto "Bienvenid@ al software de gestión de servidores SSH`n" -color Blue
        $nombre = LeerConMensajeLetraPorLetra -mensaje "Vaya... Aún no te has presentado. ¿Cómo te llamas?: " -color DarkMagenta

        # Agregar la variable "nombre" al hashtable
        $variablesEnv['nombre'] = $nombre

        # Convertir el hashtable a una cadena de texto
        $nuevoContenidoEnv = $variablesEnv.GetEnumerator() | ForEach-Object {
            "{0}={1}" -f $_.Key, $_.Value
        }

        # Escribir todo el contenido actualizado al archivo env.txt
        Set-Content -Path $rutaEnvTxt -Value $nuevoContenidoEnv
		ImprimirCabecera
    } else {
        # Si la variable "nombre" está definida, obtener su valor
        $nombre = $variablesEnv['nombre']
    }

    return $nombre
}

function ComprobarCsv {
	
    
    # Ruta completa al archivo servidores.csv en el mismo directorio que el script
    $rutaServidoresCsv = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"

    # Verificar si el archivo servidores.csv existe
    if (-not (Test-Path -Path $rutaServidoresCsv)) {
        # Crear el archivo servidores.csv vacío
        New-Item -Path $rutaServidoresCsv -ItemType File -Force | Out-Null
		
        
    } 
        # Verificar si el archivo servidores.csv está vacío
        $contenidoServidoresCsv = Get-Content -Path $rutaServidoresCsv -ErrorAction SilentlyContinue
        if ($contenidoServidoresCsv -eq $null -or $contenidoServidoresCsv.Count -eq 0) {
			"Alias,IP o dominio,Puerto,Usuario,Contraseña" | Out-File -FilePath $rutaServidoresCsv -Encoding UTF8
            ImprimirLetraPorLetra -texto "Aún no tienes configurado ningún servidor. Vamos a configurarlo:`n`n" -color White
			Start-Sleep -Seconds 1
			AnadirServidor
        } elseif ($contenidoServidoresCsv.Count -eq 1) {
            # Si el archivo solo contiene la cabecera, pedir la configuración
            ImprimirLetraPorLetra -texto "Aún no tienes configurado ningún servidor. Vamos a configurarlo:`n`n" -color White
            Start-Sleep -Seconds 1
            AnadirServidor
        }
    


	
	
}

#Función que devuelve un valor de tecla introducido
function MostrarMensajeYLeerTecla {
    param (
        [string]$mensaje,
        [System.ConsoleColor]$color = [System.ConsoleColor]::White
    )

    do {
        # Limpiar la línea actual
		
        Write-Host -NoNewline "`r" -ForegroundColor $color

        # Imprimir el mensaje letra por letra
        foreach ($caracter in $mensaje.ToCharArray()) {
            Write-Host -NoNewline $caracter -ForegroundColor $color
            Start-Sleep -Milliseconds 50  # Ajusta el tiempo de espera según sea necesario
        }

        # Leer una tecla sin imprimirla en la consola
        $keyInfo = [System.Console]::ReadKey($true)

        # Guardar la tecla pulsada
        $tecla = $keyInfo.KeyChar

        # Condición del bucle: repetir si la tecla es 's' o 'n' (ignorando mayúsculas y minúsculas)
    } while ($tecla -ne 's' -and $tecla -ne 'n' -and $tecla -ne 'S' -and $tecla -ne 'N')

    # Devolver la tecla pulsada
    return $tecla
}


function AnadirServidor {
	ImprimirCabecera
	Write-Host "Añadir un servidor"
	Write-Host "===============================`n"
	   $Alias = LeerConMensajeLetraPorLetra -mensaje "Introduce un Alias para el servidor: " -color DarkYellow
    $IP = LeerConMensajeLetraPorLetra -mensaje "Introduce una IP o dominio: " -color DarkYellow
    $User = LeerConMensajeLetraPorLetra -mensaje "Introduce un usuario para conexión SSH: " -color DarkYellow
	$Password = LeerConMensajeLetraPorLetra -mensaje "Introduce una contraseña: " -color DarkYellow
    $Port = LeerConMensajeLetraPorLetra -mensaje "Introduce un puerto para conexión SSH: " -color DarkYellow
    Clear-Host
	ImprimirCabecera
	Write-Host "Añadir un servidor"
	Write-Host "===============================`n"
	
    ImprimirLetraPorLetra -texto "Has introducido la siguiente información`n" -color DarkBlue
	Write-Host "________________________________________`n" -ForegroundColor DarkGray
	ImprimirLetraPorLetra -texto "Alias:        " -color DarkYellow -intervalo 20
	ImprimirLetraPorLetra -texto "$($Alias)`n" -color DarkGreen -intervalo 20
	
	ImprimirLetraPorLetra -texto "IP o dominio: " -color DarkYellow -intervalo 20
	ImprimirLetraPorLetra -texto "$($IP)`n" -color DarkGreen -intervalo 20
	
	ImprimirLetraPorLetra -texto "Usuario SSH:  " -color DarkYellow -intervalo 20
	ImprimirLetraPorLetra -texto "$($User)`n" -color DarkGreen -intervalo 20
	
	ImprimirLetraPorLetra -texto "Contraseña:   " -color DarkYellow -intervalo 20
	ImprimirLetraPorLetra -texto "$($Password)`n" -color DarkGreen -intervalo 20
	
	ImprimirLetraPorLetra -texto "Puerto SSH:   " -color DarkYellow -intervalo 20
	ImprimirLetraPorLetra -texto "$($Port)`n" -color DarkGreen -intervalo 20
   
	$letra = MostrarMensajeYLeerTecla -mensaje "¿Es correcta la información? (s/n): `n" -color DarkBlue
	Write-Host "`n"
	if($letra -eq "s" -or $letra -eq "S"){
		
		
		GuardarCSV -alias $Alias -direccionIP $IP -puerto $Port -usuario $User -password $Password
	}else{
		ImprimirLetraPorLetra -texto "De acuerdo. Vuelve a introducir los datos`n" -color DarkYellow
		Start-Sleep -Seconds 1
		AnadirServidor
	}
}

#Función para guardar un registro en CSV
function GuardarCSV {
    param (
        [string]$alias,
        [string]$direccionIP,
        [string]$puerto,
        [string]$usuario,
        [string]$password
    )
	ImprimirLetraPorLetra -texto "Guardando información`n" -color DarkYellow
	ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
	Start-Sleep -Seconds 1
    # Obtener la ruta completa al archivo servidores.csv en el mismo directorio que el script
    $rutaCSV = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"

    # Crear el contenido del registro CSV
    $registro = "{0},{1},{2},{3},{4}" -f $alias, $direccionIP, $puerto, $usuario, $password

    # Verificar si el archivo ya existe
    if (Test-Path -Path $rutaCSV) {
        # Agregar el registro al archivo existente
        Add-Content -Path $rutaCSV -Value $registro
		ImprimirLetraPorLetra -texto "Servidor $($Alias) guardado correctamente`n" -color DarkGreen
		
		$letra = MostrarMensajeYLeerTecla -mensaje "¿Quieres registrar otro servidor? (s/n): `n" -color DarkBlue
		
		if($letra -eq "s" -or $letra -eq "S"){
			ImprimirLetraPorLetra -texto "Genial!! Vamos a registrar otro servidor" -color DarkMagenta
			Start-Sleep -Seconds 1
			AnadirServidor
		}else{
			if($menu){
				AdministrarServidores
			}
		}
    } 

   
}

#Función que muestra el menú principal del programa
function MenuPrincipal {
	ImprimirCabecera
	
	
	Write-Host "Menú Principal"
	Write-Host "===============================`n"
	ImprimirLetraPorLetra -texto "¿Qué quieres hacer?`n" -color DarkGray
	Write-Host "`n"
	ImprimirLetraPorLetra -texto "1. Administrar servidores`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "2. Conectarme a un servidor`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "3. Configurar entorno`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "4. Salir`n" -color White -intervalo 10
	Write-Host "`n"

    $numero = MostrarMensajeYLeerNumero -mensaje "Introduce una opción válida de la lista: `n" -minimo 1 -maximo 4 -color DarkYellow
	
	if ($numero -eq 1) {
    AdministrarServidores
   
} elseif ($numero -eq 2) {
	Conectar
} elseif ($numero -eq 3) {
   ConfigurarEntorno
} elseif ($numero -eq 4) {
    CerrarConexionSSH
}
	
	
	
}
#Función que sirve para cambiar el nombre de Usuario
function CambiarNombre{
	# Obtener la ruta del directorio actual
$directorioActual = $PSScriptRoot

# Construir la ruta completa al archivo env.txt en el directorio actual
$rutaArchivo = Join-Path -Path $directorioActual -ChildPath "env.txt"

# Verificar si el archivo existe
if (Test-Path $rutaArchivo) {
    # Leer el contenido del archivo
    $contenido = Get-Content $rutaArchivo

    # Buscar la línea que contiene la variable "nombre"
    $lineaNombre = $contenido | Where-Object { $_ -match "^nombre\s*=\s*(.*)" } | ForEach-Object { $matches[1] }

    # Si se encontró la línea, imprimir su contenido
    if ($lineaNombre) {
        ImprimirLetraPorLetra -texto "Actualmente, el nombre de usuario es " -color DarkYellow
        ImprimirLetraPorLetra -texto "$($lineaNombre)`n" -color DarkGreen
		Write-Host "`n"
		$letra = MostrarMensajeYLeerTecla -mensaje "¿Quieres cambiar tu nombre de usuario?(S/N) `n" -color DarkYellow
		
		if($letra -eq 's' -or $letra -eq 'S'){
			$nombre=LeerConMensajeLetraPorLetra -mensaje "Escribe un nuevo nombre de usuario:" -color DarkYellow
			ImprimirLetraPorLetra -texto "Cambiando nombre de usuario`n" -color DarkYellow
			ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
			Start-Sleep -Seconds 1
			  $nuevoContenido = $contenido -replace "^nombre\s*=\s*.*", "nombre=$nombre"
                Set-Content -Path $rutaArchivo -Value $nuevoContenido
			ImprimirLetraPorLetra -texto "Nombre de usuario cambiado correctamente`n" -color DarkGreen
			ImprimirLetraPorLetra -texto "A partir de ahora me dirigiré a ti como " -color DarkYellow
			ImprimirLetraPorLetra -texto "$($nombre)`n" -color DarkGreen
			Start-Sleep -Seconds 1
			ConfigurarEntorno
		}else{
			ConfigurarEntorno
		}
		
    } else {
        Write-Host "La variable 'nombre' no fue encontrada en el archivo."
    }
} else {
    Write-Host "El archivo env.txt no fue encontrado en el directorio actual."
}
	
}

#Función que muestra el menú para configurar el entorno
function ConfigurarEntorno {
	ImprimirCabecera
	
	
	Write-Host "Configuración de entorno"
	Write-Host "===============================`n"
	ImprimirLetraPorLetra -texto "¿Qué quieres hacer?`n" -color DarkGray
	Write-Host "`n"
	ImprimirLetraPorLetra -texto "1. Cambiar nombre de usuario`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "2. Crear nuevo acceso directo del programa`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "3. Volver al menú principal`n" -color White -intervalo 10
	
	Write-Host "`n"

    $numero = MostrarMensajeYLeerNumero -mensaje "Introduce una opción válida de la lista: `n" -minimo 1 -maximo 3 -color DarkYellow
	
	if ($numero -eq 1) {
   CambiarNombre
} elseif ($numero -eq 2) {
     ImprimirLetraPorLetra -texto "Creando acceso directo en el escritorio`n" -color DarkYellow
        ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
		
           # Ruta al archivo init.bat en la carpeta superior al script
        $rutaInitBat = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "init.bat"

        # Verificar si el archivo init.bat existe
        if (Test-Path -Path $rutaInitBat) {
            # Ruta al escritorio del usuario
            $rutaEscritorio = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop'), 'Lista de servidores SSH.lnk')

            # Crear el acceso directo
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($rutaEscritorio)
            $shortcut.TargetPath = $rutaInitBat
            # Asignar el icono si se proporcionó una ruta de icono
			$Icono ="$PSScriptRoot\icono.ico"
            if ($Icono -ne "") {
                $Shortcut.IconLocation = $Icono
            }
            $shortcut.Save()
            ImprimirLetraPorLetra -texto "Acceso directo creado correctamente`n" -color DarkGreen
		}
	Start-Sleep -Seconds 1
	ConfigurarEntorno
} elseif ($numero -eq 3) {
   MenuPrincipal
} 
}

#Función que lee un número por teclado
function MostrarMensajeYLeerNumero {
    param (
        [string]$mensaje,
        [int]$minimo,
        [int]$maximo,
        [System.ConsoleColor]$color = [System.ConsoleColor]::White
    )

    do {
        # Limpiar la línea actual
        Write-Host -NoNewline "`r" -ForegroundColor $color

        # Imprimir el mensaje letra por letra
        foreach ($caracter in $mensaje.ToCharArray()) {
            Write-Host -NoNewline $caracter -ForegroundColor $color
            Start-Sleep -Milliseconds 50  # Ajusta el tiempo de espera según sea necesario
        }

        # Leer una tecla sin imprimirla en la consola
        $keyInfo = [System.Console]::ReadKey($true)

        # Guardar la tecla pulsada
        $tecla = $keyInfo.KeyChar

        # Comprobar si la tecla pulsada es un número
        if ($tecla -match '^\d$') {
            
			$numero = [convert]::ToInt32($tecla, 10)
            # Comprobar si el número está en el rango permitido
            if ($numero -ge $minimo -and $numero -le $maximo) {
                return $numero
            }
        }

        # Si no se cumple la condición, limpiar la línea
        Write-Host -NoNewline "`r"
        Write-Host -NoNewline (" " * $mensaje.Length) -ForegroundColor $color  # Espacios para limpiar la línea
        Write-Host -NoNewline "`r"  # Retornar al inicio de la línea
    } while ($true)
}

#Función que elimina un servidor de la Lista
function EliminarServidor {
    $rutaServidoresCsv = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"
    ImprimirCabecera
    Write-Host "Eliminar servidor"
    Write-Host "===============================`n"

    # Importar el contenido del archivo CSV
    $servidoresArray = Import-Csv -Path $rutaServidoresCsv

    # Mostrar la lista de servidores con sus índices
    $indice = 1
    foreach ($servidor in $servidoresArray) {
        ImprimirLetraPorLetra -texto "$($indice). $($servidor.Alias)`n" -color White
        $indice++
    }

    # Solicitar al usuario que elija un servidor para eliminar
    $numero = MensajeConIntro -texto "Elige un servidor de la lista para eliminarlo. Despúes, pulsa Intro. Elige 0 para cancelar: `n" -minimo 0 -maximo ($indice - 1) -color DarkYellow
	
    $server = $servidoresArray[$numero - 1]
   
    # Confirmar la eliminación del servidor
    ImprimirLetraPorLetra -texto "Estás a punto de borrar el servidor " -color DarkRed
    ImprimirLetraPorLetra -texto "$($server.Alias)`n" -color DarkYellow
    $acepta = MostrarMensajeYLeerTecla -mensaje "¿Estás seguro? (S/N) `n" -color DarkRed

    if ($acepta -eq "s" -or $acepta -eq "S") {
        # Eliminar el registro del array
        $servidoresArray = $servidoresArray | Where-Object { $_ -ne $servidoresArray[$numero - 1] }

        # Vaciar el contenido del archivo CSV
        Clear-Content -Path $rutaServidoresCsv

        # Añadir la cabecera al archivo CSV
        $cabecera = "Alias,IP o dominio,Puerto,Usuario,Contraseña"
        Add-Content -Path $rutaServidoresCsv -Value $cabecera -Encoding UTF8

        # Escribir el contenido actualizado del array en el archivo CSV
        $servidoresArray | Export-Csv -Path $rutaServidoresCsv -NoTypeInformation -Append -Encoding UTF8

        # Mostrar mensaje de confirmación
        ImprimirLetraPorLetra -texto "Eliminando registro`n" -color DarkYellow
        ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
        ImprimirLetraPorLetra -texto "Registro eliminado correctamente`n" -color DarkGreen

        Start-Sleep -Seconds 2
      
    } 
	  AdministrarServidores
}

#Función que cierra el programa
function CerrarConexionSSH {
    # Mostrar mensaje de despedida
	Clear-Host
      ImprimirLetraPorLetra -texto "Adiós, $($nombre). Vuelve pronto ;-)`n" -color DarkYellow

    # Esperar 3 segundos
    Start-Sleep -Seconds 1
        ImprimirLetraPorLetra -texto "Gracias por usar este programa. Este software cuenta con Licencia Beerware.`n" -color DarkMagenta -intervalo 10
	#	$EmojiIcon = [System.Convert]::toInt32("1F37A",16)
	#	[System.Char]::ConvertFromUtf32($EmojiIcon)

	ImprimirLetraPorLetra -texto "Eres libre de usar, modificar y distribuir este programa, siempre mencionando a su autor (Rafa Montes), pero si alguna vez nos cruzamos..." -color DarkMagenta -intervalo 10
	Start-Sleep -Milliseconds 400
	ImprimirLetraPorLetra -texto " me debes una caña!!" -color DarkMagenta -intervalo 10

Write-Host "`n"
    # Mostrar el mensaje de pulsar una tecla para salir
    Start-Sleep -Seconds 2
    Write-Host "`nPresiona cualquier tecla para salir..." -ForegroundColor DarkCyan
    [void][System.Console]::ReadKey($true)

    # Cerrar la ventana de PowerShell
    exit
}

function Conectar {
	ImprimirCabecera
	 Write-Host "Conectar a un servidor"
	Write-Host "===============================`n"
	$rutaServidoresCsv = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"
	ImprimirLetraPorLetra -texto "Lista de servidores registrados`n" -color DarkYellow
	$servers = Import-Csv -Path $rutaServidoresCsv
	
# Mostrar la lista numerada de alias

    $i = 0
	
	
    foreach ($server in $servers) {
      $i++
$hostname = $server.'IP o dominio'
$port = $server.Puerto


$timeout = 2000  # Tiempo de espera en milisegundos (2000 ms = 2 segundos)

# Crear un objeto TcpClient
$tcpClient = New-Object System.Net.Sockets.TcpClient
$array=@()
# Iniciar el proceso de conexión con el tiempo de espera especificado
try {
    $asyncResult = $tcpClient.BeginConnect($hostname, $port, $null, $null)
    $waitHandle = $asyncResult.AsyncWaitHandle

    if ($waitHandle.WaitOne($timeout, $false)) {
        if ($tcpClient.Connected) {
            $tcpClient.EndConnect($asyncResult)
			#$emoji = Emoji -codigo "2705"
            Write-Host "$i. $($server.Alias) $($check)`n"  -ForegroundColor DarkGreen
			
			
        } else {
			#$emoji = Emoji -codigo "274C"
           Write-Host "$i. $($server.Alias) $($cruz)`n" -ForegroundColor DarkRed
		   
           $array+=$i
        }
    } else {
		#$emoji = Emoji -codigo "274C"
		
        Write-Host "$i. $($server.Alias) $($cruz)`n" -ForegroundColor DarkRed
        $array+=$i
        # Cerrar la conexión si no se pudo establecer en el tiempo de espera
        $tcpClient.Close()
       
    }
} catch {
	#$emoji = Emoji -codigo "274C"
      Write-Host "$i. $($server.Alias) $($cruz)`n" -ForegroundColor DarkRed
      $array+=$i
} finally {
	
    # Asegurarse de cerrar el objeto TcpClient
    $tcpClient.Dispose()
}
        
    }
	if($array.Length -eq $i){
		ImprimirLetraPorLetra "Parece que no tienes conectividad con ningún servidor. Considera revisar tu conexión a internet antes de seguir usando este software`n" -color DarkRed
		Start-Sleep -Seconds 2
		MenuPrincipal
	}

$numero=MensajeConIntro -texto "Elige un servidor de la lista para establecer conexión o elige 0 para volver al menú. Después, pulsa intro: " -color DarkYellow -minimo 0 -maximo $i
$selectedServer = $servers[$numero - 1]

if($array -contains $numero){
	ImprimirLetraPorLetra "Este servidor no está disponible temporalmente" -color DarkRed
	Start-Sleep -Seconds 1
	Conectar
}


ImprimirLetraPorLetra "Introduce el siguiente password para " -color DarkYellow
ImprimirLetraPorLetra "$($selectedServer.Alias): " -color DarkGreen
ImprimirLetraPorLetra "$($selectedServer.'Contraseña')`n" -color DarkBlue
ImprimirLetraPorLetra "Conectando...`n" -color Green
# Ejecutar la conexión SSH
$sshCommand = "ssh $($selectedServer.Usuario)@$($selectedServer.'IP o dominio') -p $($selectedServer.'Puerto')"
Invoke-Expression $sshCommand

MenuPrincipal

}

function MensajeConIntro {

    param (
        [string]$texto,
        [int]$minimo,
        [int]$maximo,
        [System.ConsoleColor]$color = [System.ConsoleColor]::White
    )

    # Función auxiliar para imprimir el mensaje letra por letra
   
    do {
        # Limpiar la línea actual
        Write-Host -NoNewline "`r" -ForegroundColor $color

        # Imprimir el mensaje letra por letra
        ImprimirLetraPorLetra -texto $texto -color $color

        # Leer una línea completa de la consola
        $input = Read-Host

        # Si la entrada es 'Esc', ejecutar MenuPrincipal y salir
        if ($input -eq 'Esc') {
            MenuPrincipal
            return
        }

        # Intentar convertir la entrada a número
        if ([int]::TryParse($input, [ref]$numero)) {
            # Verificar si el número está dentro del rango permitido
            if ($numero -ge $minimo -and $numero -le $maximo) {
				if($numero -eq 0){
					MenuPrincipal
				}
                return $numero
            } else {
                Write-Host "`nEl número debe estar entre 0 y $maximo. Inténtalo de nuevo." -ForegroundColor Red
            }
        } else {
            Write-Host "`nEntrada no válida. Debe ser un número. Inténtalo de nuevo." -ForegroundColor Red
        }
    } while ($true)
}



########################
function ImprimirCabecera {
Clear-Host

Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor DarkRed
Write-Host "|  _     _     _              _                            _     _                      |" -ForegroundColor DarkMagenta
Write-Host "| | |   (_)___| |_ __ _    __| | ___   ___  ___ _ ____   _(_) __| | ___  _ __ ___  ___  |" -ForegroundColor DarkMagenta
Write-Host "| | |   | / __| __/ _  |  / _  |/ _ \ / __|/ _ \  __\ \ / / |/ _  |/ _ \|  __/ _ \/ __| |" -ForegroundColor Magenta
Write-Host "| | |___| \__ \ || (_| | | (_| |  __/ \__ \  __/ |   \ V /| | (_| | (_) | | |  __/\__ \ |" -ForegroundColor DarkYellow
Write-Host "| |_____|_|___/\__\____|  \____|\___| |___/\___|_|    \_/ |_|\____|\___/|_|  \___||___/ |" -ForegroundColor Yellow
Write-Host "|                                                                                       |" -ForegroundColor DarkGray
Write-Host "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" -ForegroundColor Gray
Write-Host "`n"                                                                                  
}                                                                    
#######################
function Modificar {
    ImprimirCabecera
    Write-Host "Modificar información de servidor"
    Write-Host "===============================`n"

    # Obtener la ruta del archivo CSV
    $rutaServidoresCsv = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"
    
    # Importar el contenido del archivo CSV
    $servers = Import-Csv -Path $rutaServidoresCsv
    
    # Mostrar la lista de servidores en forma de tabla
   
	foreach($server in $servers){
		$Alias=$server.Alias
		$IP=$server.'IP o dominio'
		$User=$server.Usuario
		$Password=$server.Contraseña
		$Port=$server.Puerto
		
		 
	
	Write-Host -NoNewLine "Alias:        " -ForegroundColor DarkYellow
	Write-Host "$($Alias)" -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "IP o dominio: " -ForegroundColor DarkYellow
	Write-Host "$($IP)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Usuario SSH:  " -ForegroundColor DarkYellow
	Write-Host "$($User)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Contraseña:   " -ForegroundColor DarkYellow
	Write-Host "$($Password)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Puerto SSH:   " -ForegroundColor DarkYellow
	Write-Host "$($Port)"  -ForegroundColor DarkGreen
	Write-Host "________________________________________`n" -ForegroundColor DarkGray
	}
    $count=0
    foreach($server in $servers){
        $count++
        ImprimirLetraPorLetra -texto "$($count). $($server.Alias)`n" -color White
    }

    # Solicitar al usuario que elija un número de servidor
    $numeroServidor = MensajeConIntro -texto "Elige el número del servidor que deseas modificar. Después, pulsa intro (0 para volver al menú): " -minimo 0 -maximo ($count) -color DarkYellow
    
    if ($numeroServidor -eq 0) {
        # Volver al menú Modificar si se elige 0
        Modificar
        return
    }
    
    # Obtener el servidor seleccionado
    $servidorSeleccionado = $servers[$numeroServidor - 1]
do{
	ImprimirCabecera
	Write-Host "Modificar información de servidor"
    Write-Host "===============================`n"
    # Mostrar la información del servidor seleccionado
    Write-Host "Información del servidor seleccionado:`n"
    $Alias=$servidorSeleccionado.Alias
		$IP=$servidorSeleccionado.'IP o dominio'
		$User=$servidorSeleccionado.Usuario
		$Password=$servidorSeleccionado.Contraseña
		$Port=$servidorSeleccionado.Puerto
		
		 
	
	Write-Host -NoNewLine "Alias:        " -ForegroundColor DarkYellow
	Write-Host "$($Alias)" -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "IP o dominio: " -ForegroundColor DarkYellow
	Write-Host "$($IP)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Usuario SSH:  " -ForegroundColor DarkYellow
	Write-Host "$($User)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Contraseña:   " -ForegroundColor DarkYellow
	Write-Host "$($Password)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Puerto SSH:   " -ForegroundColor DarkYellow
	Write-Host "$($Port)"  -ForegroundColor DarkGreen
	Write-Host "________________________________________`n" -ForegroundColor DarkGray

    # Obtener la lista de campos para modificar
    $campos = $servers[0] | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    # Mostrar la lista de campos para modificar
    Write-Host "Campos disponibles para modificar:`n"
    $count = 0
	
    ImprimirLetraPorLetra -texto "1. Alias`n" -color White -intervalo 50
    ImprimirLetraPorLetra -texto "2. IP o dominio`n" -color White -intervalo 50
    ImprimirLetraPorLetra -texto "3. Usuario`n" -color White -intervalo 50
    ImprimirLetraPorLetra -texto "4. Contraseña`n" -color White -intervalo 50
    ImprimirLetraPorLetra -texto "5. Puerto`n" -color White -intervalo 50
	ImprimirLetraPorLetra -texto "6. Guardar Cambios `n" -color White -intervalo 50
	ImprimirLetraPorLetra -texto "7. Cancelar `n" -color White -intervalo 50
    
    # Solicitar al usuario que elija el campo a modificar
    $campoAModificar = MensajeConIntro -texto "Elige el número del campo que deseas modificar. Después pulsa intro (0 para volver al menú. 6 para guardar cambios. 7 para cancelar): " -color DarkYellow -minimo 0 -maximo 7
    
	
    if ($campoAModificar -eq 1) {
        ImprimirLetraPorLetra -texto "Introduce un nuevo alias para este servidor. El alias actual es " -color DarkYellow
	   ImprimirLetraPorLetra -texto "$($servidorSeleccionado.Alias)" -color DarkBlue
	   ImprimirLetraPorLetra -texto ": " -color DarkYellow
	  $newValue = Read-Host
	  $servidorSeleccionado.Alias=$newValue
	  ImprimirCabecera
	  $servidorSeleccionado | Format-List
	   
    }
	
	if ($campoAModificar -eq 2) {
       ImprimirLetraPorLetra -texto "Introduce una nueva IP o un nuevo dominio para este servidor. La IP o dominio actual es " -color DarkYellow
	   ImprimirLetraPorLetra -texto "$($servidorSeleccionado.'IP o dominio')" -color DarkBlue
	   ImprimirLetraPorLetra -texto ": " -color DarkYellow
	  $newValue = Read-Host
	  $servidorSeleccionado.'IP o dominio'=$newValue
	  ImprimirCabecera
	  $servidorSeleccionado | Format-List
	   
    }
	
	if ($campoAModificar -eq 3) {
       ImprimirLetraPorLetra -texto "Introduce un nuevo usuario para este servidor. El usuario actual es " -color DarkYellow
	   ImprimirLetraPorLetra -texto "$($servidorSeleccionado.Usuario)" -color DarkBlue
	   ImprimirLetraPorLetra -texto ": " -color DarkYellow
	  $newValue = Read-Host
	  $servidorSeleccionado.Usuario=$newValue
	  ImprimirCabecera
	  $servidorSeleccionado | Format-List
    }
	if ($campoAModificar -eq 4) {
       ImprimirLetraPorLetra -texto "Introduce una nueva contraseña para este servidor. La contraseña actual es " -color DarkYellow
	   ImprimirLetraPorLetra -texto "$($servidorSeleccionado.Contraseña)" -color DarkBlue
	   ImprimirLetraPorLetra -texto ": " -color DarkYellow
	  $newValue = Read-Host
	  $servidorSeleccionado.Contraseña=$newValue
	  ImprimirCabecera
	  $servidorSeleccionado | Format-List
	   
    }
	if ($campoAModificar -eq 5) {
        ImprimirLetraPorLetra -texto "Introduce un nuevo puerto para este servidor. El puerto actual es " -color DarkYellow
	   ImprimirLetraPorLetra -texto "$($servidorSeleccionado.Puerto)" -color DarkBlue
	   ImprimirLetraPorLetra -texto ": " -color DarkYellow
	  $newValue = Read-Host
	  $servidorSeleccionado.Puerto=$newValue
	  $servidorSeleccionado | Format-List
	   
    }
	
	if($campoAModificar -eq 6){
		$tecla = MostrarMensajeYLeerTecla -mensaje "¿Quieres guardar los cambios realizados? (S/N)`n" -color DarkYellow
		if($tecla -eq "n" -or $tecla -eq "N"){
			AdministrarServidores
		}else{
			
			   
			   $servers[$numeroServidor - 1] = $servidorSeleccionado
			   Clear-Content -Path $rutaServidoresCsv

        # Añadir la cabecera al archivo CSV
        $cabecera = "Alias,IP o dominio,Puerto,Usuario,Contraseña"
        Add-Content -Path $rutaServidoresCsv -Value $cabecera -Encoding UTF8

        # Escribir el contenido actualizado del array en el archivo CSV
        $servers | Export-Csv -Path $rutaServidoresCsv -NoTypeInformation -Append -Encoding UTF8
			ImprimirLetraPorLetra -texto "Actualizando registro`n" -color DarkYellow
        ImprimirLetraPorLetra -texto "...`n" -color DarkYellow -intervalo 300
        ImprimirLetraPorLetra -texto "Registro actualizado correctamente`n" -color DarkGreen
		
		Start-Sleep -Seconds 2
		AdministrarServidores
			
			
		}
	}
	
	if($campoAModificar -eq 7){
		AdministrarServidores
	}
}
while($campoAModificar -ne 6 -and $campoAModificar -ne 7)
  
}

 
 
 
 
 
 function AdministrarServidores{
	 
	 $menu = $true
	 ImprimirCabecera
	 Write-Host "Administar servidores"
	Write-Host "===============================`n"
	# Ruta al archivo CSV
$rutaServidoresCsv = Join-Path -Path $PSScriptRoot -ChildPath "servidores.csv"

# Verificar si el archivo CSV existe
if (Test-Path $rutaServidoresCsv) {
    # Importar el contenido del archivo CSV
    $datosCSV = Import-Csv -Path $rutaServidoresCsv
	$i=0
	foreach($servidor in $datosCSV){
		$i++;
	}
    # Mostrar el contenido en formato de lista
   foreach($server in $datosCSV){
		$Alias=$server.Alias
		$IP=$server.'IP o dominio'
		$User=$server.Usuario
		$Password=$server.Contraseña
		$Port=$server.Puerto
		
		 
	
	Write-Host -NoNewLine "Alias:        " -ForegroundColor DarkYellow
	Write-Host "$($Alias)" -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "IP o dominio: " -ForegroundColor DarkYellow
	Write-Host "$($IP)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Usuario SSH:  " -ForegroundColor DarkYellow
	Write-Host "$($User)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Contraseña:   " -ForegroundColor DarkYellow
	Write-Host "$($Password)"  -ForegroundColor DarkGreen
	
	Write-Host -NoNewLine "Puerto SSH:   " -ForegroundColor DarkYellow
	Write-Host "$($Port)"  -ForegroundColor DarkGreen
	Write-Host "________________________________________`n" -ForegroundColor DarkGray
	}
  
	
	
	ImprimirLetraPorLetra -texto "¿Qué quieres hacer?`n" -color DarkGray
	Write-Host "`n"
	ImprimirLetraPorLetra -texto "1. Añadir servidor`n" -color White -intervalo 10
	ImprimirLetraPorLetra -texto "2. Modificar servidor`n" -color White -intervalo 10
	
	if($i -eq 1){
		ImprimirLetraPorLetra -texto "3. Eliminar servidor $($cruz)`n" -color DarkRed -intervalo 10
	}else{
	ImprimirLetraPorLetra -texto "3. Eliminar servidor `n" -color White -intervalo 10
	}
	ImprimirLetraPorLetra -texto "4. Volver al menú principal`n" -color White -intervalo 10
	
	Write-Host "`n"

    $numero = MostrarMensajeYLeerNumero -mensaje "Introduce una opción válida de la lista: `n" -minimo 1 -maximo 4 -color DarkYellow
	
	if ($numero -eq 1) {
		AnadirServidor
} elseif ($numero -eq 2) {
    Modificar
}elseif ($numero -eq 3){
	if($i -eq 1){
		ImprimirLetraPorLetra -texto "Tienes que tener al menos un servidor registrado. Considera modificar el único que tienes si no te va a servir`n" -color DarkRed
		Start-Sleep 2
		AdministrarServidores
	}else{
	 EliminarServidor
	}
}elseif ($numero -eq 4){
	MenuPrincipal
}


	 
 }
 }

 ImprimirCabecera
 
 Start-Sleep -Seconds 1
 ArchivoEntornos
 
  Start-Sleep -Seconds 1
  
  CrearAccesoDirecto -Icono "$PSScriptRoot\icono.ico"
  
   Start-Sleep -Seconds 1
   ImprimirCabecera
   $nombre = Nombre
   
   ImprimirLetraPorLetra -texto "Bienvenid@, $($nombre)`n" -color DarkBlue
   ComprobarCsv
  
   Start-Sleep -Seconds 1
	MenuPrincipal
	
	
	
  
     
   
   
   