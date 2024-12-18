
# Ruta raíz de la carpeta del proyecto
$rootPath = "lib"

# Estructura de carpetas y archivos
$structure = @{
    "lib" = @{
        "screens" = @{
            "auth" = @{
                "login_screen.dart" = $null
            }
            "dashboard" = @{
                "dashboard_screen.dart" = $null
                "profile_screen.dart" = $null
            }
            "marketplace" = @{
                "marketplace_screen.dart" = $null
                "vet_detail_screen.dart" = $null
            }
            "tasks" = @{
                "task_list_screen.dart" = $null
            }
        }
        "models" = @{
            "user.dart" = $null
            "animal.dart" = $null
            "donation.dart" = $null
        }
        "services" = @{
            "auth_service.dart" = $null
            "payment_service.dart" = $null
        }
        "utils" = @{
            "constants.dart" = $null
            "helpers.dart" = $null
        }
        "widgets" = @{
            "custom_button.dart" = $null
            "animal_card.dart" = $null
        }
    }
}

# Función para crear carpetas y archivos recursivamente
function Create-FilesAndDirectories($basePath, $structure) {
    foreach ($key in $structure.Keys) {
        $currentPath = Join-Path $basePath $key
        if ($structure[$key] -eq $null) {
            # Crear archivo vacío
            New-Item -ItemType File -Path $currentPath -Force | Out-Null
        } else {
            # Crear carpeta y procesar contenido
            New-Item -ItemType Directory -Path $currentPath -Force | Out-Null
            Create-FilesAndDirectories -basePath $currentPath -structure $structure[$key]
        }
    }
}

# Crear la estructura de archivos y carpetas
Create-FilesAndDirectories -basePath $rootPath -structure $structure
