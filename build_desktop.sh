#!/usr/bin/env bash
set -euo pipefail

BUILD_MAC=0
BUILD_WIN=0

options=$(getopt -l "win,mac,help" -o "w,m,h" -a -- "$@")
eval set -- "$options"
while true
do
    case $1 in
        -w|--win)
            BUILD_WIN=1
            ;;
        -m|--mac)
            BUILD_MAC=1
            ;;
        -h|--help)
            echo "Produce flowit.love in the build directory."
            echo ""
            echo "Usage:"
            echo "  $0 [-w | --win] [-m | --mac]"
            echo ""
            echo "  -w, --win    also build windows executable (.exe)"
            echo "  -m, --mac    also build mac app (.app)"
            exit 0
            ;;
        --)
            shift
            break;;
    esac
    shift
done

shopt -s extglob
mkdir -p build

echo "Compressing flowit.love..."
zip -9 -q -r build/flowit.love lib/!(*_vita.lua) fonts images levels LICENSE main.lua sounds


cd build

if [[ $BUILD_WIN -eq 1 ]]; then
    echo "Packaging Windows exe..."

    WIN_FLOWIT_DIR="flowit-win"
    WIN_FLOWIT_ZIP="$WIN_FLOWIT_DIR.zip"

    WIN_LOVE_DIR="love-11.4-win32"
    WIN_LOVE_ZIP="$WIN_LOVE_DIR.zip"

    # download zip if it doesn't exist
    if [ ! -f "$WIN_LOVE_ZIP" ]; then
        curl -L -O "https://github.com/love2d/love/releases/download/11.4/love-11.4-win32.zip"
    fi

    # delete directories built previously
    if [ -d "$WIN_LOVE_DIR" ]; then
        rm -r "$WIN_LOVE_DIR"
    fi
    if [ -d "$WIN_FLOWIT_DIR" ]; then
        rm -r "$WIN_FLOWIT_DIR"
    fi


    unzip -q "$WIN_LOVE_ZIP"
    mkdir -p "$WIN_FLOWIT_DIR"

    cat "$WIN_LOVE_DIR/love.exe" flowit.love > "$WIN_FLOWIT_DIR/Flowit.exe"
    cp "$WIN_LOVE_DIR/"*.dll "$WIN_FLOWIT_DIR"

    cp "$WIN_LOVE_DIR/license.txt" "$WIN_FLOWIT_DIR/love_license.txt"
    cp "../README.md" "$WIN_FLOWIT_DIR/flowit_readme_license.md"
    cat "../LICENSE" >> "$WIN_FLOWIT_DIR/flowit_readme_license.md"

    zip -q -r "$WIN_FLOWIT_ZIP" "$WIN_FLOWIT_DIR"

    rm -r "$WIN_FLOWIT_DIR"
    rm -r "$WIN_LOVE_DIR"

fi

if [[ $BUILD_MAC -eq 1 ]]; then
    echo "Packaging Mac app..."

    MAC_LOVE_APP_DIR="love.app"
    MAC_FLOWIT_APP_DIR="Flowit.app"
    MAC_FLOWIT_APP_ZIP="Flowit.app.zip"

    MAC_LOVE_DIR="love-11.4-macos"
    MAC_LOVE_ZIP="$MAC_LOVE_DIR.zip"

    # download zip if it doesn't exist
    if [ ! -f "$MAC_LOVE_ZIP" ]; then
        curl -L -O "https://github.com/love2d/love/releases/download/11.4/love-11.4-macos.zip"
    fi

    # delete directories built previously
    if [ -d "$MAC_LOVE_DIR" ]; then
        rm -r "$MAC_LOVE_DIR"
    fi
    if [ -d "$MAC_LOVE_APP_DIR" ]; then
        rm -r "$MAC_LOVE_APP_DIR"
    fi
    if [ -d "$MAC_FLOWIT_APP_DIR" ]; then
        rm -r "$MAC_FLOWIT_APP_DIR"
    fi


    unzip -q "$MAC_LOVE_ZIP"

    mv "$MAC_LOVE_APP_DIR" "$MAC_FLOWIT_APP_DIR"


    cp flowit.love "$MAC_FLOWIT_APP_DIR/Contents/Resources/Flowit.love"
    cp ../desktop_resources/Info.plist "$MAC_FLOWIT_APP_DIR/Contents/"
    cp ../desktop_resources/flowit.icns "$MAC_FLOWIT_APP_DIR/Contents/Resources/GameIcon.icns"
    cp ../desktop_resources/flowit.icns "$MAC_FLOWIT_APP_DIR/Contents/Resources/OS X AppIcon.icns"
    rm "$MAC_FLOWIT_APP_DIR/Contents/Resources/Assets.car"

    cp "../README.md" "$MAC_FLOWIT_APP_DIR/Contents/Resources/flowit_readme_license.md"
    cat "../LICENSE" >> "$MAC_FLOWIT_APP_DIR/Contents/Resources/flowit_readme_license.md"

    zip -q -r "$MAC_FLOWIT_APP_ZIP" "$MAC_FLOWIT_APP_DIR"

    rm -r "$MAC_FLOWIT_APP_DIR"

fi
