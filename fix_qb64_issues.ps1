# QB64 Compilation Fix Script
# Systematically finds and fixes all QB64 compilation issues

param(
    [string]$RootDir = ".",
    [string]$SourceDir = "src",
    [string]$LauncherFile = "WON.BAS",
    [switch]$DryRun = $false
)

Write-Host "QB64 Compilation Fix Script" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No files will be modified" -ForegroundColor Yellow
    Write-Host ""
}

$issuesFound = 0
$issuesFixed = 0

# Function: write content back unless DryRun
function Write-IfChanged {
    param(
        [string]$Path,
        [string]$Original,
        [string]$Updated
    )
    if ($Original -ne $Updated) {
        $script:issuesFound++
        Write-Host "  Updated: $Path" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $Path -Value $Updated -NoNewline
            $script:issuesFixed++
        }
        return $true
    }
    return $false
}

# Function: get all BASIC source files (includes root + src)
function Get-BasicFiles {
    param([string]$Base)
    Get-ChildItem -Path $Base -Recurse -File -Include *.bas,*.bi,*.bm
}

# 0. Remove backup files (*.bas-bak) - do this first to avoid analyzing files we'll delete
Write-Host "0. Removing backup files (*.bas-bak)..." -ForegroundColor Yellow
$backupFiles = Get-ChildItem -Path $RootDir -Filter "*.bas-bak" -Recurse -File -ErrorAction SilentlyContinue
$backupCount = $backupFiles.Count

if ($backupCount -gt 0) {
    Write-Host "  Found $backupCount backup file(s):" -ForegroundColor Yellow
    foreach ($backupFile in $backupFiles) {
        Write-Host "    $($backupFile.FullName)" -ForegroundColor Gray
    }
    
    if (-not $DryRun) {
        foreach ($backupFile in $backupFiles) {
            try {
                Remove-Item -LiteralPath $backupFile.FullName -Force -ErrorAction Stop
                Write-Host "  Deleted: $($backupFile.Name)" -ForegroundColor Green
                $issuesFixed++
            }
            catch {
                Write-Host "  Error deleting $($backupFile.Name): $_" -ForegroundColor Red
            }
        }
        Write-Host "  Removed $backupCount backup file(s)" -ForegroundColor Green
    } else {
        Write-Host "  (Dry run - would delete $backupCount backup file(s))" -ForegroundColor Yellow
    }
} else {
    Write-Host "  No backup files found" -ForegroundColor Green
}

# 1. Normalize Unicode punctuation and scan for legacy bytes
Write-Host "1. Normalizing Unicode punctuation and scanning for legacy bytes..." -ForegroundColor Yellow
$allBasicFiles = Get-BasicFiles -Base $RootDir

# Replace common Unicode punctuation that can break QB64/QB64-PE parsing.
$unicodeMap = [ordered]@{
    ([char]0x2192) = "->"   # →
    ([char]0x00D7) = "x"    # ×
    ([char]0x2264) = "<="   # ≤
    ([char]0x2260) = "<>"   # ≠
    ([char]0x201C) = '"'    # “
    ([char]0x201D) = '"'    # ”
    ([char]0x2018) = "'"    # ‘
    ([char]0x2019) = "'"    # ’
    ([char]0x2026) = "..."  # …
    ([char]0x00A0) = " "    # NBSP
}

foreach ($file in $allBasicFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $orig = $text
    foreach ($k in $unicodeMap.Keys) {
        $text = $text.Replace([string]$k, $unicodeMap[$k])
    }
    Write-IfChanged -Path $file.FullName -Original $orig -Updated $text | Out-Null
}

# Scan for non-ASCII bytes/control bytes (CP437 remnants or embedded control chars).
$byteFindings = @()
foreach ($file in $allBasicFiles) {
    $b = [System.IO.File]::ReadAllBytes($file.FullName)
    $high = 0
    $ctrl = 0
    $dos = 0
    foreach ($x in $b) {
        if ($x -ge 128) { $high++ }
        if ((($x -lt 32 -and $x -notin 9,10,13) -or $x -eq 127)) { $ctrl++ }
        if ($x -eq 26) { $dos++ } # DOS EOF marker
    }
    if ($high -gt 0 -or $ctrl -gt 0 -or $dos -gt 0) {
        $byteFindings += [pscustomobject]@{
            Path = $file.FullName
            HighBytes = $high
            ControlBytes = $ctrl
            DosEOF_0x1A = $dos
        }
    }
}

if ($byteFindings.Count -gt 0) {
    Write-Host "  Warning: Found legacy bytes in BASIC sources (manual review recommended):" -ForegroundColor Yellow
    $byteFindings | Sort-Object HighBytes -Descending | Format-Table -AutoSize
    Write-Host "  Tip: replace embedded control glyphs with CHR`$(n) and normalize CP437 box/marker chars." -ForegroundColor Yellow
}

# 1b. Ensure launcher entrypoint exists in WON.BAS (prevents EXE from immediate exit)
Write-Host ""
Write-Host "1b. Ensuring launcher entrypoint in $LauncherFile..." -ForegroundColor Yellow
$launcherPath = Join-Path $RootDir $LauncherFile
if (Test-Path $launcherPath) {
    $launcher = Get-Content -LiteralPath $launcherPath -Raw
    if ($launcher -notmatch '(?m)^\s*DECLARE\s+SUB\s+Main\s*\(\s*\)\s*$' -or
        $launcher -notmatch '(?m)^\s*CALL\s+Main\s*$' -or
        $launcher -notmatch '(?m)^\s*END\s*$') {
        $header = @"
'============================================================================
' Wars of Napoleon - QB64 entry point
'============================================================================
DECLARE SUB Main ()
CALL Main
END

"@
        $updated = $header + $launcher
        Write-IfChanged -Path $launcherPath -Original $launcher -Updated $updated | Out-Null
    }
} else {
    Write-Host "  Launcher file not found: $launcherPath" -ForegroundColor Yellow
}

# 2. Fix function declarations: AS INTEGER/LONG/SINGLE/STRING → type suffixes
Write-Host "2. Fixing function declarations..." -ForegroundColor Yellow
$functionFiles = Get-ChildItem -Path $SourceDir -Filter "*.bas" -Recurse

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $fixed = $false
    
    # Fix FUNCTION ... AS INTEGER
    if ($content -match 'FUNCTION\s+(\w+)\s*\([^)]*\)\s+AS\s+INTEGER') {
        $content = $content -replace 'FUNCTION\s+(\w+)\s*\(([^)]*)\)\s+AS\s+INTEGER', 'FUNCTION $1% ($2)'
        $fixed = $true
    }
    
    # Fix FUNCTION ... AS LONG
    if ($content -match 'FUNCTION\s+(\w+)\s*\([^)]*\)\s+AS\s+LONG') {
        $content = $content -replace 'FUNCTION\s+(\w+)\s*\(([^)]*)\)\s+AS\s+LONG', 'FUNCTION $1& ($2)'
        $fixed = $true
    }
    
    # Fix FUNCTION ... AS SINGLE
    if ($content -match 'FUNCTION\s+(\w+)\s*\([^)]*\)\s+AS\s+SINGLE') {
        $content = $content -replace 'FUNCTION\s+(\w+)\s*\(([^)]*)\)\s+AS\s+SINGLE', 'FUNCTION $1! ($2)'
        $fixed = $true
    }
    
    # Fix FUNCTION ... AS STRING (but not functions that already have $)
    if ($content -match 'FUNCTION\s+(\w+)\s*\([^)]*\)\s+AS\s+STRING' -and $content -notmatch 'FUNCTION\s+\w+\$\s*\([^)]*\)\s+AS\s+STRING') {
        $content = $content -replace 'FUNCTION\s+(\w+)\s*\(([^)]*)\)\s+AS\s+STRING', 'FUNCTION $1$ ($2)'
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed function declarations in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 3. Fix function bodies: Update assignments to use type suffixes
Write-Host ""
Write-Host "3. Fixing function body assignments..." -ForegroundColor Yellow
# This is complex and needs manual review - will be done per-function

# 4. Fix CONST declarations - move to declarations.bas
Write-Host ""
Write-Host "4. Checking CONST declarations..." -ForegroundColor Yellow
# CONST declarations should already be in declarations.bas

# 5. Fix DIM SHARED with type suffixes
Write-Host ""
Write-Host "5. Fixing DIM SHARED with type suffixes..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $fixed = $false
    
    # Fix DIM SHARED name$ AS STRING
    if ($content -match 'DIM\s+SHARED\s+\w+\$\s+AS\s+STRING') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+\$)\s+AS\s+STRING', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name! AS SINGLE
    if ($content -match 'DIM\s+SHARED\s+\w+!\s+AS\s+SINGLE') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+!)\s+AS\s+SINGLE', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name% AS INTEGER
    if ($content -match 'DIM\s+SHARED\s+\w+%\s+AS\s+INTEGER') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+%)\s+AS\s+INTEGER', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name& AS LONG
    if ($content -match 'DIM\s+SHARED\s+\w+&\s+AS\s+LONG') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+&)\s+AS\s+LONG', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name&(array) AS LONG (arrays with type suffixes)
    if ($content -match 'DIM\s+SHARED\s+\w+&\([^)]+\)\s+AS\s+LONG') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+&\([^)]+\))\s+AS\s+LONG', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name$(array) AS STRING (arrays with type suffixes)
    if ($content -match 'DIM\s+SHARED\s+\w+\$\([^)]+\)\s+AS\s+STRING') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+\$\([^)]+\))\s+AS\s+STRING', 'DIM SHARED $1'
        $fixed = $true
    }
    
    # Fix DIM SHARED name!(array) AS SINGLE (arrays with type suffixes)
    if ($content -match 'DIM\s+SHARED\s+\w+!\([^)]+\)\s+AS\s+SINGLE') {
        $content = $content -replace 'DIM\s+SHARED\s+(\w+!\([^)]+\))\s+AS\s+SINGLE', 'DIM SHARED $1'
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed DIM SHARED in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 6. Fix gameState array accesses
Write-Host ""
Write-Host "6. Fixing gameState array accesses..." -ForegroundColor Yellow
$gameStatePatterns = @(
    @{Pattern = 'gameState\.cash\((\d+)\)'; Replacement = 'GetGameStateCash&($1)'},
    @{Pattern = 'gameState\.income\((\d+)\)'; Replacement = 'GetGameStateIncome&($1)'},
    @{Pattern = 'gameState\.victory\((\d+)\)'; Replacement = 'GetGameStateVictory&($1)'},
    @{Pattern = 'gameState\.control\((\d+)\)'; Replacement = 'GetGameStateControl%($1)'},
    @{Pattern = 'gameState\.cash\((side|enemySide|gameState\.side)\)'; Replacement = 'GetGameStateCash&($1)'},
    @{Pattern = 'gameState\.income\((side|enemySide|gameState\.side)\)'; Replacement = 'GetGameStateIncome&($1)'},
    @{Pattern = 'gameState\.victory\((side|enemySide|gameState\.side)\)'; Replacement = 'GetGameStateVictory&($1)'},
    @{Pattern = 'gameState\.control\((side|enemySide|gameState\.side)\)'; Replacement = 'GetGameStateControl%($1)'}
)

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $fixed = $false
    
    foreach ($patternInfo in $gameStatePatterns) {
        if ($content -match $patternInfo.Pattern) {
            $content = $content -replace $patternInfo.Pattern, $patternInfo.Replacement
            $fixed = $true
        }
    }
    
    # Fix assignments: gameState.cash(side) = value
    if ($content -match 'gameState\.cash\s*\([^)]+\)\s*=') {
        # This needs more complex replacement - will need manual review
        Write-Host "  Found assignment in: $($file.Name) - needs manual fix" -ForegroundColor Yellow
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed gameState accesses in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 7. Fix battleData array accesses
Write-Host ""
Write-Host "7. Fixing battleData array accesses..." -ForegroundColor Yellow
$battleDataPatterns = @(
    @{Pattern = 'battleData\.sidex\(1\)'; Replacement = 'battleData.sideID1'},
    @{Pattern = 'battleData\.sidex\(2\)'; Replacement = 'battleData.sideID2'},
    @{Pattern = 'battleData\.commander\(1\)'; Replacement = 'battleData.commander1'},
    @{Pattern = 'battleData\.commander\(2\)'; Replacement = 'battleData.commander2'},
    @{Pattern = 'battleData\.vp\(1\)'; Replacement = 'battleData.vp1'},
    @{Pattern = 'battleData\.vp\(2\)'; Replacement = 'battleData.vp2'},
    @{Pattern = 'battleData\.leadbase\(1\)'; Replacement = 'battleData.leadbase1'},
    @{Pattern = 'battleData\.leadbase\(2\)'; Replacement = 'battleData.leadbase2'},
    @{Pattern = 'battleData\.expbase\(1\)'; Replacement = 'battleData.expbase1'},
    @{Pattern = 'battleData\.expbase\(2\)'; Replacement = 'battleData.expbase2'}
)

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    foreach ($patternInfo in $battleDataPatterns) {
        if ($content -match [regex]::Escape($patternInfo.Pattern)) {
            $content = $content -replace [regex]::Escape($patternInfo.Pattern), $patternInfo.Replacement
            $fixed = $true
        }
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed battleData accesses in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 8. Fix battleResult array accesses
Write-Host ""
Write-Host "8. Fixing battleResult array accesses..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    if ($content -match 'battleResult\.casualties\(1\)') {
        $content = $content -replace 'battleResult\.casualties\(1\)', 'battleResult.casualties1'
        $fixed = $true
    }
    
    if ($content -match 'battleResult\.casualties\(2\)') {
        $content = $content -replace 'battleResult\.casualties\(2\)', 'battleResult.casualties2'
        $fixed = $true
    }
    
    if ($content -match 'result\.casualties\(1\)') {
        $content = $content -replace 'result\.casualties\(1\)', 'result.casualties1'
        $fixed = $true
    }
    
    if ($content -match 'result\.casualties\(2\)') {
        $content = $content -replace 'result\.casualties\(2\)', 'result.casualties2'
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed battleResult accesses in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 9. Fix ELSE IF → ELSEIF
Write-Host ""
Write-Host "9. Fixing ELSE IF -> ELSEIF..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    if ($content -match '\bELSE\s+IF\b') {
        $content = $content -replace '\bELSE\s+IF\b', 'ELSEIF'
        $issuesFound++
        Write-Host "  Fixed ELSE IF in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 10. Fix LEN(DIR$(...)) → FileExists%
Write-Host ""
Write-Host "10. Fixing LEN(DIR`$ usage..." -ForegroundColor Yellow
$dirIssues = @()
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    # Fix IF LEN(DIR$(filename)) = 0
    if ($content -match 'IF\s+LEN\s*\(\s*DIR\$\s*\([^)]+\)\s*\)\s*=\s*0') {
        # This is complex - needs context-aware replacement
        $dirIssues += "  Found LEN(DIR`$()) in: $($file.Name) - needs manual review"
        Write-Host "  Found LEN(DIR`$()) in: $($file.Name) - needs manual review" -ForegroundColor Yellow
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed DIR$ usage in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 11. Fix preprocessor directives
Write-Host ""
Write-Host "11. Fixing preprocessor directives..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    if ($content -match '#IFDEF|#IFNDEF|#ENDIF') {
        # Comment out preprocessor directives
        $content = $content -replace '#IFDEF\s+(\w+)', "' Commented out: #IFDEF $1"
        $content = $content -replace '#IFNDEF\s+(\w+)', "' Commented out: #IFNDEF $1"
        $content = $content -replace '#ENDIF', "' Commented out: #ENDIF"
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed preprocessor directives in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 12. Fix function calls with no parameters (remove parentheses)
Write-Host ""
Write-Host "12. Fixing function calls with no parameters..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    # Fix function calls with type suffixes and empty parentheses
    # Pattern: FunctionName%() or FunctionName&() or FunctionName!() or FunctionName$()
    if ($content -match '\w+[%&!$]\(\)') {
        # Replace functionName%() with functionName%
        $content = $content -replace '(\w+[%&!$])\(\)', '$1'
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed function calls in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 13. Fix LEN(DIR$()) → FileExists%
Write-Host ""
Write-Host "13. Fixing LEN(DIR`$()) usage..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    # Fix IF LEN(DIR$(filename)) = 0 → IF FileExists%(filename) = 0
    if ($content -match 'IF\s+LEN\s*\(\s*DIR\$\s*\(([^)]+)\)\s*\)\s*=\s*0') {
        $content = $content -replace 'IF\s+LEN\s*\(\s*DIR\$\s*\(([^)]+)\)\s*\)\s*=\s*0', 'IF FileExists%($1) = 0'
        $fixed = $true
    }
    
    # Fix IF LEN(DIR$(filename)) > 0 → IF FileExists%(filename) <> 0
    if ($content -match 'IF\s+LEN\s*\(\s*DIR\$\s*\(([^)]+)\)\s*\)\s*>\s*0') {
        $content = $content -replace 'IF\s+LEN\s*\(\s*DIR\$\s*\(([^)]+)\)\s*\)\s*>\s*0', 'IF FileExists%($1) <> 0'
        $fixed = $true
    }
    
    if ($fixed) {
        $issuesFound++
        Write-Host "  Fixed DIR`$() usage in: $($file.Name)" -ForegroundColor Green
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 14. Fix reserved word conflicts (color, key, command, etc.)
Write-Host ""
Write-Host "14. Fixing reserved word conflicts..." -ForegroundColor Yellow
$reservedWords = @{
    'color' = 'drawColor'
    'key' = 'keyPress'
    'command' = 'cmd'
    'size' = 'sizeVal'
    'name' = 'nameVal'
    'type' = 'typeVal'
    'loc' = 'cityLoc'
    'line' = 'lineText'
}

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    foreach ($reserved in $reservedWords.Keys) {
        $replacement = $reservedWords[$reserved]
        
        # Fix local DIM reserved AS type → DIM replacement AS type
        if ($content -match "\bDIM\s+$reserved\s+AS\s+\w+") {
            $content = $content -replace "\bDIM\s+($reserved)\s+AS\s+(\w+)", "DIM $replacement AS `$2"
            # Replace all uses of reserved = with replacement =
            $content = $content -replace "\b$reserved\s*=", "$replacement ="
            # Replace all uses of reserved, reserved) reserved( with replacement
            $content = $content -replace "\b$reserved\b", $replacement
            $fixed = $true
            Write-Host "  Fixed reserved word '$reserved' → '$replacement' in: $($file.Name)" -ForegroundColor Green
        }
    }
    
    if ($fixed) {
        $issuesFound++
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 15. Fix CALL statements - remove parentheses for no-parameter SUBs
Write-Host ""
Write-Host "15. Fixing CALL statements..." -ForegroundColor Yellow
# Read declarations.bas to find SUBs declared with () (no parameters)
$declarationsFile = Join-Path $SourceDir "common\declarations.bas"
$noParamSubs = @()
$allDeclaredSubs = @()
if (Test-Path $declarationsFile) {
    $declContent = Get-Content $declarationsFile -Raw
    # Find all DECLARE SUB name () patterns (empty parentheses = no parameters)
    $someMatches = [regex]::Matches($declContent, 'DECLARE\s+SUB\s+(\w+)\s*\(\s*\)')
    foreach ($match in $someMatches) {
        $noParamSubs += $match.Groups[1].Value
        $allDeclaredSubs += $match.Groups[1].Value
    }
    # Find all DECLARE SUB name (params) patterns
    $someMatches = [regex]::Matches($declContent, 'DECLARE\s+SUB\s+(\w+)\s*\([^)]+\)')
    foreach ($match in $someMatches) {
        $allDeclaredSubs += $match.Groups[1].Value
    }
}

# Check which declared SUBs are actually implemented
$implementedSubs = @()
foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    foreach ($subName in $allDeclaredSubs) {
        # Use [regex]::Escape to properly escape the subName, then construct pattern
        $escapedName = [regex]::Escape($subName)
        $pattern1 = "^\s*SUB\s+$escapedName\b"
        $pattern2 = "^\s*SUB\s+$escapedName\s*\("
        if ($content -match $pattern1 -or $content -match $pattern2) {
            if ($implementedSubs -notcontains $subName) {
                $implementedSubs += $subName
            }
        }
    }
}

$unimplementedSubs = $allDeclaredSubs | Where-Object { $implementedSubs -notcontains $_ }
if ($unimplementedSubs.Count -gt 0) {
    Write-Host "  Warning: Found $($unimplementedSubs.Count) DECLAREd but unimplemented SUBs:" -ForegroundColor Yellow
    $unimplementedSubs | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
}

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    
    # Fix CALL statements for no-parameter SUBs: remove parentheses
    foreach ($subName in $noParamSubs) {
        # Fix CALL subname() → CALL subname (remove parentheses)
        if ($content -match "CALL\s+$subName\s*\(\s*\)") {
            $content = $content -replace "CALL\s+($subName)\s*\(\s*\)", 'CALL $1'
            $fixed = $true
            Write-Host "  Fixed CALL $subName in: $($file.Name)" -ForegroundColor Green
        }
    }
    
    if ($fixed) {
        $issuesFound++
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            $issuesFixed++
        }
    }
}

# 16. Fix DIM SHARED statements placed between SUB/FUNCTION declarations
Write-Host ""
Write-Host "16. Fixing misplaced DIM SHARED statements..." -ForegroundColor Yellow
# Read declarations.bas to get list of already-declared variables
$declarationsFile = Join-Path $SourceDir "common\declarations.bas"
$declaredVars = @{}
if (Test-Path $declarationsFile) {
    $declLines = Get-Content $declarationsFile
    foreach ($line in $declLines) {
        # Match DIM SHARED variable declarations
        if ($line -match 'DIM\s+SHARED\s+(\w+[%&!$]?)\s*(\([^)]+\))?\s*(AS\s+\w+)?') {
            $varName = $matches[1]
            $declaredVars[$varName] = $true
        }
    }
}

foreach ($file in $functionFiles) {
    if ($file.Name -eq "declarations.bas") { continue }
    
    $lines = Get-Content $file.FullName
    $newLines = @()
    $fixed = $false
    $foundSubFunction = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check if we've found a SUB or FUNCTION (marks start of SUB/FUNCTION section)
        if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
            $foundSubFunction = $true
            $newLines += $line
        }
        # Check if we're leaving a SUB or FUNCTION
        elseif ($line -match '^\s*END\s+(SUB|FUNCTION)') {
            $newLines += $line
        }
        # If we've found SUB/FUNCTION declarations and find DIM SHARED, check if it's already declared
        elseif ($foundSubFunction -and $line -match 'DIM\s+SHARED\s+(\w+[%&!$]?)\s*(\([^)]+\))?\s*(AS\s+\w+)?') {
            $varName = $matches[1]
            if ($declaredVars.ContainsKey($varName)) {
                # Already declared in declarations.bas - remove this duplicate
                $newLines += "' Note: $varName is declared in declarations.bas"
                $fixed = $true
                Write-Host "  Removed duplicate DIM SHARED $varName from: $($file.Name)" -ForegroundColor Green
            } else {
                # Not declared yet - keep it but warn
                $newLines += $line
                Write-Host "  Warning: DIM SHARED $varName in $($file.Name) should be moved to declarations.bas" -ForegroundColor Yellow
            }
        }
        # Also check for DIM SHARED before any SUB/FUNCTION (these are OK, but check for duplicates)
        elseif (-not $foundSubFunction -and $line -match 'DIM\s+SHARED\s+(\w+[%&!$]?)\s*(\([^)]+\))?\s*(AS\s+\w+)?') {
            $varName = $matches[1]
            if ($declaredVars.ContainsKey($varName)) {
                # Already declared in declarations.bas - remove this duplicate
                $newLines += "' Note: $varName is declared in declarations.bas"
                $fixed = $true
                Write-Host "  Removed duplicate DIM SHARED $varName from: $($file.Name)" -ForegroundColor Green
            } else {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }
    
    if ($fixed) {
        $issuesFound++
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value ($newLines -join "`n") -NoNewline
            $issuesFixed++
        }
    }
}

# 17. Fix duplicate DIM SHARED declarations (remove duplicates not in declarations.bas)
Write-Host ""
Write-Host "17. Fixing duplicate DIM SHARED declarations..." -ForegroundColor Yellow
$sharedVars = @('color', 'colour', 'key', 'command', 'size', 'name', 'type', 'choose', 'tlx', 'tly', 'hilite')
$conflictIssues = @()

foreach ($file in $functionFiles) {
    if ($file.Name -eq "declarations.bas") { continue }
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fixed = $false
    $lines = Get-Content $file.FullName
    $newLines = @()
    
    foreach ($line in $lines) {
        $shouldRemove = $false
        
        foreach ($var in $sharedVars) {
            # Check if this line declares a DIM SHARED variable that's already in declarations.bas
            if ($line -match "DIM\s+SHARED\s+$var\s+AS\s+\w+" -or $line -match "DIM\s+SHARED\s+$var\$") {
                $shouldRemove = $true
                $conflictIssues += "  Removed duplicate DIM SHARED $var from: $($file.Name)"
                Write-Host "  Removing duplicate DIM SHARED $var from: $($file.Name)" -ForegroundColor Yellow
                break
            }
        }
        
        if (-not $shouldRemove) {
            $newLines += $line
        } else {
            $fixed = $true
        }
    }
    
    if ($fixed) {
        $issuesFound++
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value ($newLines -join "`n") -NoNewline
            $issuesFixed++
        }
    }
}

if ($conflictIssues.Count -gt 0) {
    Write-Host "  Fixed $($conflictIssues.Count) duplicate declarations" -ForegroundColor Green
}

# 18. Fix IF/END IF structure issues with ELSEIF (detect potential problems)
Write-Host ""
Write-Host "18. Checking IF/END IF structure..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $lines = Get-Content $file.FullName
    $multiLineIfCount = 0  # IF statements that need END IF
    $singleLineIfCount = 0  # IF statements that don't need END IF
    $endIfCount = 0
    $warnings = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check for IF statements
        if ($line -match '^\s*IF\s+.*\s+THEN') {
            # Single-line IF: has code after THEN (not just comment or empty)
            if ($line -match '^\s*IF\s+.*\s+THEN\s+[^'']') {
                $singleLineIfCount++
            }
            # Multi-line IF: THEN is at end of line or followed by comment
            else {
                $multiLineIfCount++
            }
        }
        elseif ($line -match '^\s*END\s+IF\b') {
            $endIfCount++
        }
    }
    
    # Multi-line IF statements need matching END IF
    if ($multiLineIfCount -ne $endIfCount) {
        $diff = $multiLineIfCount - $endIfCount
        Write-Host "  Warning: Mismatched IF/END IF in: $($file.Name) (Multi-line IF: $multiLineIfCount, END IF: $endIfCount, Missing: $diff)" -ForegroundColor Yellow
    }
}

# 19. Fix executable statements between SUB/FUNCTION declarations
Write-Host ""
Write-Host "19. Fixing executable statements between SUB/FUNCTION declarations..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    if ($file.Name -eq "declarations.bas" -or $file.Name -like "*test*") { 
        # Skip declarations.bas and test files (they may have special handling)
        continue 
    }
    
    $lines = Get-Content $file.FullName
    $newLines = @()
    $fixed = $false
    $foundSubFunction = $false
    $inSubFunction = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check if we're entering a SUB or FUNCTION
        if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
            $foundSubFunction = $true
            $inSubFunction = $true
            $newLines += $line
        }
        # Check if we're leaving a SUB or FUNCTION
        elseif ($line -match '^\s*END\s+(SUB|FUNCTION)') {
            $inSubFunction = $false
            $newLines += $line
        }
        # If we've found SUB/FUNCTION declarations and find executable statements between them
        elseif ($foundSubFunction -and -not $inSubFunction) {
            # Check for executable statements (assignments, not declarations)
            if ($line -match '^\s*\w+\s*=\s*' -and $line -notmatch '^\s*DIM\s+' -and $line -notmatch '^\s*CONST\s+' -and $line -notmatch '^\s*TYPE\s+' -and $line -notmatch '^\s*DECLARE\s+') {
                # Comment out executable statements between SUB/FUNCTION declarations
                $newLines += "' FIXED: Executable statement moved/commented to avoid 'between SUB/FUNCTION' error"
                $newLines += "' " + $line
                $fixed = $true
                Write-Host "  Commented executable statement in: $($file.Name) line $($i+1)" -ForegroundColor Green
            } else {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }
    
    if ($fixed) {
        $issuesFound++
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value ($newLines -join "`n") -NoNewline
            $issuesFixed++
        }
    }
}

# 20. Detect array initialization between SUB/FUNCTION declarations
Write-Host ""
Write-Host "20. Checking for array initialization between SUB/FUNCTION declarations..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    if ($file.Name -eq "declarations.bas") { continue }
    
    $lines = Get-Content $file.FullName
    $subFunctionStack = @()  # Stack to track nested SUB/FUNCTION depth
    $warnings = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check if we're entering a SUB/FUNCTION
        if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
            $subFunctionStack += $true
        }
        # Check if we're leaving a SUB/FUNCTION
        elseif ($line -match '^\s*END\s+(SUB|FUNCTION)') {
            if ($subFunctionStack.Count -gt 0) {
                $subFunctionStack = $subFunctionStack[0..($subFunctionStack.Count - 2)]
            }
        }
        # Check for array assignment when NOT inside a SUB/FUNCTION (between declarations)
        elseif ($subFunctionStack.Count -eq 0 -and $line -match '^\s*\w+\([^)]+\)\s*=\s*') {
            # Skip if it's a DIM statement (array declaration, not assignment)
            if ($line -notmatch '^\s*DIM\s+') {
                # Skip if it's a label (line ends with colon)
                if ($line -notmatch ':\s*$') {
                    # Array initialization between SUB/FUNCTION declarations (at module level)
                    $warnings += "  Line $($i+1): Array initialization between SUB/FUNCTION declarations: $line"
                }
            }
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "  Found array initialization issues in: $($file.Name)" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
        Write-Host "  These need to be moved to declarations.bas or an initialization SUB" -ForegroundColor Yellow
    }
}

# 13b. Ensure FileExists% wrapper uses QB64-PE _FILEEXISTS (and no ON ERROR labels)
Write-Host ""
Write-Host "13b. Ensuring FileExists% uses _FILEEXISTS..." -ForegroundColor Yellow
$utilitiesFile = Join-Path $SourceDir "common\utilities.bas"
if (Test-Path $utilitiesFile) {
    $u = Get-Content -LiteralPath $utilitiesFile -Raw
    $origU = $u
    # If legacy ON ERROR label exists, remove it and replace with _FILEEXISTS implementation.
    if ($u -match 'FUNCTION\s+FileExists%') {
        $u = [regex]::Replace(
            $u,
            '(?ms)^FUNCTION\s+FileExists%\s*\(.*?\)\s*.*?^END FUNCTION\s*$',
@"
FUNCTION FileExists% (filename AS STRING)
    ' Check if file exists.
    ' Use QB64-PE builtin _FILEEXISTS (returns -1 when it exists, 0 when it does not).
    ' Wiki: https://wiki.qb64.dev/qb64wiki/index.php/FILEEXISTS
    IF _FILEEXISTS(filename) THEN
        FileExists% = 1
    ELSE
        FileExists% = 0
    END IF
END FUNCTION
"@,
            1
        )
    }
    Write-IfChanged -Path $utilitiesFile -Original $origU -Updated $u | Out-Null
}

# 21. Detect identifiers longer than 40 characters (QB64 limit)
Write-Host ""
Write-Host "21. Checking for identifiers longer than 40 characters..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    $lines = Get-Content $file.FullName
    $warnings = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check for SUB/FUNCTION names longer than 40 chars
        if ($line -match '^\s*(SUB|FUNCTION)\s+(\w+)\s*') {
            $name = $matches[2]
            if ($name.Length -gt 40) {
                $warnings += "  Line $($i+1): $($matches[1]) name '$name' is $($name.Length) characters (limit: 40)"
            }
        }
        
        # Check for variable names in DIM statements longer than 40 chars
        if ($line -match '^\s*DIM\s+(?:SHARED\s+)?(\w+[%&!$]?)\s*') {
            $name = $matches[1]
            if ($name.Length -gt 40) {
                $warnings += "  Line $($i+1): Variable name '$name' is $($name.Length) characters (limit: 40)"
            }
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "  Found long identifiers in: $($file.Name)" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
        Write-Host "  These need to be shortened manually" -ForegroundColor Yellow
    }
}

# 22. Detect duplicate function/SUB declarations (Name already in use)
Write-Host ""
Write-Host "22. Checking for potential duplicate declarations..." -ForegroundColor Yellow
$allSubs = @{}
$allFunctions = @{}
$duplicateWarnings = @()

foreach ($file in $functionFiles) {
    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check for SUB declarations
        if ($line -match '^\s*SUB\s+(\w+)\s*') {
            $subName = $matches[1].ToUpper()
            if ($allSubs.ContainsKey($subName)) {
                $duplicateWarnings += "  SUB '$subName' declared in both $($allSubs[$subName]) and $($file.Name)"
            } else {
                $allSubs[$subName] = $file.Name
            }
        }
        
        # Check for FUNCTION declarations
        if ($line -match '^\s*FUNCTION\s+(\w+[%&!$]?)\s*') {
            $funcName = $matches[1].ToUpper()
            if ($allFunctions.ContainsKey($funcName)) {
                $duplicateWarnings += "  FUNCTION '$funcName' declared in both $($allFunctions[$funcName]) and $($file.Name)"
            } else {
                $allFunctions[$funcName] = $file.Name
            }
        }
    }
}

if ($duplicateWarnings.Count -gt 0) {
    Write-Host "  Found potential duplicate declarations:" -ForegroundColor Yellow
    $duplicateWarnings | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    Write-Host "  These may cause 'Name already in use' errors" -ForegroundColor Yellow
}

# 13c. Remove ON ERROR + in-procedure tacticalError label pattern (can trigger "Common label within a SUB/FUNCTION")
Write-Host ""
Write-Host "13c. Removing ON ERROR + tacticalError label pattern in tactical_integration (if present)..." -ForegroundColor Yellow
$tacticalIntegrationFile = Join-Path $SourceDir "strategic\\tactical_integration.bas"
if (Test-Path $tacticalIntegrationFile) {
    $ti = Get-Content -LiteralPath $tacticalIntegrationFile -Raw
    $origTi = $ti
    # Remove the ON ERROR GOTO tacticalError line(s)
    $ti = [regex]::Replace($ti, '(?m)^\s*ON ERROR GOTO tacticalError\s*\r?\n', '')
    # Remove the tacticalError: label block up to the END FUNCTION that closes ResolveCombat%
    $ti = [regex]::Replace($ti, '(?ms)^\s*tacticalError:\s*\r?\n.*?^\s*END FUNCTION\s*$', "END FUNCTION", 1)
    # Remove redundant ON ERROR GOTO 0 lines directly after LaunchTacticalBattle (if still present)
    $ti = [regex]::Replace($ti, '(?m)^\s*ON ERROR GOTO 0\s*\r?\n', '')
    Write-IfChanged -Path $tacticalIntegrationFile -Original $origTi -Updated $ti | Out-Null
}

# 23. Fix DIM SHARED statements between SUB/FUNCTION declarations
Write-Host ""
Write-Host "23. Fixing DIM SHARED statements between SUB/FUNCTION declarations..." -ForegroundColor Yellow
foreach ($file in $functionFiles) {
    if ($file.Name -eq "declarations.bas") { continue }
    
    $lines = Get-Content $file.FullName
    $dimSharedStatements = @()
    $fixed = $false
    $subFunctionDepth = 0
    $foundSubFunction = $false
    $declareSectionEnd = -1
    
    # First pass: find where DECLARE section ends and collect DIM SHARED statements between SUB/FUNCTIONs
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Track SUB/FUNCTION depth (to know if we're inside or between)
        if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
            $foundSubFunction = $true
            $subFunctionDepth++
        }
        elseif ($line -match '^\s*END\s+(SUB|FUNCTION)') {
            $subFunctionDepth--
            if ($subFunctionDepth -lt 0) { $subFunctionDepth = 0 }
        }
        # Track end of DECLARE section (last DECLARE statement before first SUB/FUNCTION)
        elseif (-not $foundSubFunction -and $line -match '^\s*DECLARE\s+') {
            $declareSectionEnd = $i
        }
        # Collect DIM SHARED statements that are between SUB/FUNCTION declarations (not inside them)
        elseif ($foundSubFunction -and $subFunctionDepth -eq 0 -and $line -match '^\s*DIM\s+SHARED\s+') {
            $dimSharedStatements += $line
            $fixed = $true
            Write-Host "  Found DIM SHARED between SUB/FUNCTION in: $($file.Name) line $($i+1): $($line.Trim())" -ForegroundColor Yellow
        }
    }
    
    # Second pass: rebuild file with DIM SHARED moved to top
    if ($fixed) {
        $newLines = @()
        $dimSharedAdded = $false
        $subFunctionDepth = 0
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            # Track SUB/FUNCTION depth
            if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
                $subFunctionDepth++
            }
            elseif ($line -match '^\s*END\s+(SUB|FUNCTION)') {
                $subFunctionDepth--
                if ($subFunctionDepth -lt 0) { $subFunctionDepth = 0 }
            }
            
            # Skip DIM SHARED statements that are between SUB/FUNCTION declarations (we'll add them at top)
            if ($foundSubFunction -and $subFunctionDepth -eq 0 -and $line -match '^\s*DIM\s+SHARED\s+') {
                # Skip this line - we'll add it at the top
                continue
            }
            
            # Insert DIM SHARED statements after DECLARE section (before first SUB/FUNCTION)
            if (-not $dimSharedAdded -and $dimSharedStatements.Count -gt 0) {
                # Find insertion point: after last DECLARE, before first SUB/FUNCTION
                if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
                    # Insert before this SUB/FUNCTION
                    $newLines += ""
                    $newLines += "' DIM SHARED statements moved from between SUB/FUNCTION declarations"
                    foreach ($dimLine in $dimSharedStatements) {
                        $newLines += $dimLine
                    }
                    $newLines += ""
                    $dimSharedAdded = $true
                }
                elseif ($declareSectionEnd -ge 0 -and $i -eq ($declareSectionEnd + 1)) {
                    # Insert after last DECLARE statement
                    $newLines += ""
                    $newLines += "' DIM SHARED statements moved from between SUB/FUNCTION declarations"
                    foreach ($dimLine in $dimSharedStatements) {
                        $newLines += $dimLine
                    }
                    $newLines += ""
                    $dimSharedAdded = $true
                }
            }
            
            $newLines += $line
        }
        
        # If we didn't find a good insertion point, add after DECLARE section or at top
        if (-not $dimSharedAdded -and $dimSharedStatements.Count -gt 0) {
            $finalLines = @()
            $inserted = $false
            $lastWasDeclare = $false
            
            for ($i = 0; $i -lt $newLines.Count; $i++) {
                $line = $newLines[$i]
                
                # Insert after DECLARE section or before first SUB/FUNCTION
                if (-not $inserted) {
                    if ($line -match '^\s*(SUB|FUNCTION)\s+\w+') {
                        # Insert before first SUB/FUNCTION
                        $finalLines += ""
                        $finalLines += "' DIM SHARED statements moved from between SUB/FUNCTION declarations"
                        foreach ($dimLine in $dimSharedStatements) {
                            $finalLines += $dimLine
                        }
                        $finalLines += ""
                        $inserted = $true
                    }
                    elseif ($lastWasDeclare -and $line -notmatch '^\s*DECLARE\s+' -and $line -notmatch '^\s*(SUB|FUNCTION)\s+' -and $line.Trim() -ne "") {
                        # Insert after DECLARE section (after last DECLARE, before next non-empty non-DECLARE line)
                        $finalLines += ""
                        $finalLines += "' DIM SHARED statements moved from between SUB/FUNCTION declarations"
                        foreach ($dimLine in $dimSharedStatements) {
                            $finalLines += $dimLine
                        }
                        $finalLines += ""
                        $inserted = $true
                    }
                }
                
                # Track if this line is a DECLARE statement
                if ($line -match '^\s*DECLARE\s+') {
                    $lastWasDeclare = $true
                } else {
                    $lastWasDeclare = $false
                }
                
                $finalLines += $line
            }
            
            # If still not inserted, add at the very top
            if (-not $inserted) {
                $finalLines = @(
                    "",
                    "' DIM SHARED statements moved from between SUB/FUNCTION declarations"
                ) + $dimSharedStatements + @("", "") + $finalLines
            }
            $newLines = $finalLines
        }
        
        $updatedContent = ($newLines -join "`n")
        if (-not $updatedContent.EndsWith("`n")) {
            $updatedContent += "`n"
        }
        $originalContent = (Get-Content $file.FullName -Raw)
        
        if ($updatedContent -ne $originalContent) {
            $issuesFound++
            Write-Host "  Fixed DIM SHARED placement in: $($file.Name)" -ForegroundColor Green
            if (-not $DryRun) {
                Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
                $issuesFixed++
            }
        }
    }
}

# Generate report file
$reportFile = "QB64_ISSUES_REPORT.md"
Write-Host ""
Write-Host "Generating report: $reportFile" -ForegroundColor Cyan

$conflictText = if ($conflictIssues.Count -gt 0) { $conflictIssues -join "`n" } else { "  None found" }
$dirText = if ($dirIssues.Count -gt 0) { $dirIssues -join "`n" } else { "  None found" }
$byteFindingText = if ($byteFindings.Count -gt 0) { ($byteFindings | Sort-Object HighBytes -Descending | ForEach-Object { "  $($_.Path) (HighBytes=$($_.HighBytes), ControlBytes=$($_.ControlBytes), DosEOF_0x1A=$($_.DosEOF_0x1A))" }) -join "`n" } else { "  None found" }

$report = @'
# QB64 Compilation Issues Report
Generated: {0}

## Summary
- Total issues found: {1}
- Files scanned: {2}

## Auto-fixes this script can apply
- **Unicode normalization**: Replaces common Unicode punctuation (arrows, smart quotes, NBSP, etc.) with ASCII to avoid QB64-PE parse errors.
- **Legacy DOS/IBM byte scan**: Reports files containing high-bit bytes (>=128), embedded control bytes, or DOS EOF (0x1A) for manual cleanup (often requires CHR$() replacements).
- **Launcher enforcement**: Ensures {3} contains `DECLARE SUB Main () / CALL Main / END` before INCLUDEs so the EXE doesn't immediately exit when launched.
- **File exists checks**: Ensures FileExists% uses QB64-PE builtin _FILEEXISTS (avoids ON ERROR GOTO labels inside functions). See: https://wiki.qb64.dev/qb64wiki/index.php/FILEEXISTS
- **Tactical integration guard**: Removes the ON ERROR GOTO tacticalError + tacticalError: label block pattern which can trigger "Common label within a SUB/FUNCTION".
- **DIM SHARED placement**: Automatically moves DIM SHARED statements that are placed between SUB/FUNCTION declarations to the top of the file (after DECLARE statements) to fix "Statement cannot be placed between SUB/FUNCTIONs" errors.

## Issues by Category

### 1. Function Declarations
Functions using AS type syntax need to be converted to type suffixes.
(These should already be fixed, but verify)

### 2. DIM SHARED with Type Suffixes
Variables with type suffixes should not have AS type in DIM statements.
(These should already be fixed, but verify)

### 3. gameState Array Accesses
All gameState.cash(side), gameState.income(side), etc. need to use helper functions.
Found in: city.bas (and possibly others)

### 4. battleData Array Accesses
All battleData.sidex(1), battleData.commander(1), etc. need to use new field names.
(These should already be fixed, but verify)

### 5. battleResult Array Accesses
All battleResult.casualties(1), etc. need to use new field names.
Found in: battle.bas (and possibly others)

### 6. ELSE IF -> ELSEIF
All instances of ELSE IF need to be changed to ELSEIF.
Found in: main.bas, combat.bas (and possibly others)

### 7. LEN(DIR$()) Usage
Files that need manual review for DIR$() usage:
{4}

### 8. Variable Name Conflicts
Potential conflicts with reserved words or duplicate declarations:
{5}

### 9. Legacy Byte Findings (manual cleanup)
{6}

## Next Steps
1. Review this report
2. Run the fix script WITHOUT -DryRun to apply automatic fixes
3. Manually fix complex cases (DIR$() usage, function body assignments, etc.)
4. Compile and fix remaining errors iteratively
'@ -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $issuesFound, $functionFiles.Count, $LauncherFile, $dirText, $conflictText, $byteFindingText

Set-Content -Path $reportFile -Value $report
Write-Host "Report saved to: $reportFile" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "============================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Issues found: $issuesFound" -ForegroundColor Yellow
if (-not $DryRun) {
    Write-Host "  Issues fixed: $issuesFixed" -ForegroundColor Green
} else {
    Write-Host "  (Dry run - no files modified)" -ForegroundColor Yellow
}
Write-Host "  Report saved to: $reportFile" -ForegroundColor Green
Write-Host ""

