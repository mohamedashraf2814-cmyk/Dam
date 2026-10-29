@echo off
title DAMSTOCK Code Guide - Build
cd /d "%~dp0"
if exist D:\ (
  if not exist D:\temp mkdir D:\temp
  set "TEMP=D:\temp"
  set "TMP=D:\temp"
  set "GRADLE_USER_HOME=D:\gradle-home"
  set "PUB_CACHE=D:\pub-cache"
)
if not exist android\app\src\main\AndroidManifest.xml (
  echo Creating platform files...
  call flutter create . --org com.softstream --project-name damstock_code_guide --platforms=android,web
  powershell -NoProfile -Command "$m='android/app/src/main/AndroidManifest.xml'; $c=Get-Content $m -Raw; $c=$c -replace 'android:label=\"[^\"]*\"','android:label=\"DAMSTOCK Code\"'; Set-Content $m $c -Encoding UTF8"
)
call flutter pub get
echo.
echo Building the Android app (first time takes a few minutes)...
call flutter build apk --release
if not exist build\app\outputs\flutter-apk\app-release.apk (
  echo Build failed - see the messages above.
  pause
  exit /b 1
)
copy /y build\app\outputs\flutter-apk\app-release.apk "%USERPROFILE%\Desktop\DAMSTOCK_Code.apk" >nul
echo.
echo APK saved to your Desktop: DAMSTOCK_Code.apk
echo Installing on the connected phone (if any)...
call flutter install --release
echo.
pause
