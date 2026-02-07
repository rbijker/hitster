@echo off
echo ============================================
echo   HITSTER - Push to GitHub + Enable Pages
echo ============================================
echo.

:: Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed.
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)

:: Check if gh CLI is installed
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo [INFO] GitHub CLI not found - will use git only.
    echo To auto-create the repo, install: https://cli.github.com
    echo.
    set USE_GH=0
) else (
    set USE_GH=1
)

:: Set repo name
set REPO_NAME=hitster

echo [1/5] Initializing git repo...
cd /d "%~dp0"
git init
git branch -M main

echo.
echo [2/5] Adding files...
git add -A
git commit -m "Initial commit - HITSTER PWA"

if "%USE_GH%"=="1" (
    echo.
    echo [3/5] Creating GitHub repo...
    gh repo create %REPO_NAME% --public --source=. --push
    
    echo.
    echo [4/5] Enabling GitHub Pages...
    gh api repos/{owner}/%REPO_NAME%/pages -X POST -f "build_type=legacy" -f "source[branch]=main" -f "source[path]=/" 2>nul
    if %errorlevel% neq 0 (
        echo Pages may already be enabled or needs manual activation.
    )
    
    echo.
    echo [5/5] Getting your URL...
    for /f "tokens=*" %%i in ('gh api repos/{owner}/%REPO_NAME% --jq .full_name') do set FULL_NAME=%%i
    echo.
    echo ============================================
    echo   DONE! Your app is live at:
    echo   https://%FULL_NAME:*/=%/.github.io/%REPO_NAME%/
    echo.
    echo   Open this URL on your iPhone in Safari,
    echo   then tap Share ^> Add to Home Screen
    echo ============================================
) else (
    echo.
    echo [3/5] No GitHub CLI - manual steps needed:
    echo.
    echo   1. Go to https://github.com/new
    echo   2. Create a repo named: %REPO_NAME%
    echo   3. Run these commands:
    echo.
    echo      git remote add origin https://github.com/YOUR_USERNAME/%REPO_NAME%.git
    echo      git push -u origin main
    echo.
    echo   4. Go to repo Settings ^> Pages
    echo   5. Set Source: Deploy from branch ^> main ^> / (root)
    echo   6. Your app will be at: https://YOUR_USERNAME.github.io/%REPO_NAME%/
)

echo.
pause
