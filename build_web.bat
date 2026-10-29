@echo off
title DAMSTOCK Code Guide - Web build
cd /d "%~dp0"
if not exist android\app\src\main\AndroidManifest.xml call flutter create . --org com.softstream --project-name damstock_code_guide --platforms=android,web
call flutter pub get
call flutter build web --release --base-href /Dam/
echo.
echo Web version is in build\web  (upload it to GitHub Pages)
pause
