# ============================================================================
#
#  Script de mise à jour Windows + applications tierces 
#  
# ============================================================================

# --- 1. Vérification de la politique d'exécution ---------------------------

$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Restricted") {
    Write-Host "[INFO] Politique d'exécution 'Restricted' détectée. Application de 'RemoteSigned'..." -ForegroundColor Yellow
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Write-Host "[OK]   Politique d'exécution mise à jour." -ForegroundColor Green
} else {
    Write-Host "[OK]   Politique d'exécution actuelle : $currentPolicy (aucune action requise)." -ForegroundColor Green
}

# --- 2. Vérification du module PSWindowsUpdate ------------------------------

$moduleInstalled = Get-Module -ListAvailable -Name PSWindowsUpdate
if (-not $moduleInstalled) {
    Write-Host "[INFO] Module PSWindowsUpdate introuvable. Installation en cours..." -ForegroundColor Yellow

    try {
        # Assure qu'un fournisseur NuGet et le dépôt PSGallery sont disponibles.
        if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
        }

        if (-not (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) {
            Register-PSRepository -Default
        }

        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

        # -Force : réinstalle si un état corrompu existe
        # -Scope CurrentUser : évite d'exiger les droits admin pour l'installation du module
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck
        Write-Host "[OK]   Module PSWindowsUpdate installé." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Impossible d'installer PSWindowsUpdate : $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
} else {
    Write-Host "[OK]   Module PSWindowsUpdate déjà installé (v$($moduleInstalled.Version))." -ForegroundColor Green
}

# Importation explicite
try {
    Import-Module PSWindowsUpdate -Force
    Write-Host "[OK]   Module PSWindowsUpdate importé." -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] L'import du module PSWindowsUpdate a échoué : $($_.Exception.Message)" -ForegroundColor Red
    throw
}

# --- 3. Mises à jour Windows (système) --------------------------------------
Write-Host "`n=== Recherche des mises à jour Windows ===" -ForegroundColor Cyan

$pendingUpdates = Get-WindowsUpdate
if ($pendingUpdates) {
    Write-Host "[INFO] $($pendingUpdates.Count) mise(s) à jour Windows trouvée(s) :" -ForegroundColor Yellow
    $pendingUpdates | Format-Table -AutoSize -Wrap Title, KBArticleID, UpdateType, RebootRequired

    Write-Host "[INFO] Téléchargement et installation en cours..." -ForegroundColor Yellow
    $installResult = Install-WindowsUpdate -AcceptAll -IgnoreReboot -Progress
    Write-Host "[OK]   Mises à jour Windows installées." -ForegroundColor Green
    $rebootNeeded = $true
} else {
    Write-Host "[OK]   Windows est à jour." -ForegroundColor Green
    $rebootNeeded = $false
}

# --- 4. Mises à jour des applications tierces ----------------------
Write-Host "`n=== Recherche des mises à jour d'applications (winget) ===" -ForegroundColor Cyan

$wingetAvailable = Get-Command -Name winget -ErrorAction SilentlyContinue
if ($wingetAvailable) {
    # Rafraîchir les sources avant la recherche
    winget source update *> $null

    $wingetListOutput = winget upgrade --list --accept-source-agreements 2>&1
    $hasWingetUpdates = ($LASTEXITCODE -eq 0) -and
        ($wingetListOutput -notmatch '(?i)No package updates found|No upgrades available|There are no updates available')

    if ($hasWingetUpdates) {
        Write-Host "[INFO] Mises à jour d'applications trouvées :" -ForegroundColor Yellow
        $wingetListOutput | Write-Host

        Write-Host "[INFO] Application des mises à jour d'applications..." -ForegroundColor Yellow
        winget upgrade --all --silent --disable-interactivity `
            --accept-package-agreements --accept-source-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK]   Mises à jour d'applications installées." -ForegroundColor Green
            $rebootNeeded = $true
        } else {
            Write-Host "[WARN] Des mises à jour d'applications ont été détectées, mais leur installation a échoué." -ForegroundColor DarkYellow
        }
    } else {
        Write-Host "[OK]   Toutes les applications sont à jour." -ForegroundColor Green
    }
} else {
    Write-Host "[WARN] winget non trouvé. Passage des mises à jour tierces." -ForegroundColor DarkYellow
}

# --- 5. Proposition de redémarrage ------------------------------------------
Write-Host ""
if ($rebootNeeded) {
    Write-Host "=== Redémarrage requis ===" -ForegroundColor Red
    $choice = Read-Host "Voulez-vous redémarrer maintenant ? (O/N)"
    if ($choice -match "^[OoYy]$") {
        Write-Host "Redémarrage dans 10 secondes..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer
    } else {
        Write-Host "[INFO] Redémarrage différé. N'oubliez pas de redémarrer manuellement." -ForegroundColor DarkYellow
    }
} else {
    Write-Host "Aucun redémarrage nécessaire. Terminé." -ForegroundColor Green
}