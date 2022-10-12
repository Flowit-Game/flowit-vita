#!/usr/bin/env bash
set -euo pipefail

make_pkg=true

options=$(getopt -l "copy-only" -o "c" -a -- "$@")
eval set -- "$options"
while true
do
    case $1 in
        -c|--copy-only)
            make_pkg=false
            ;;
        --)
            shift
            break;;
    esac
    shift
done

title="Flowit"
appid="FLWT02021"

# get app version from ../lib/version.lua
appver=$(grep "^version_str =" ../lib/version.lua | cut -d '"' -f 2)
[[ "$appver" =~ ^[0-9]\.[0-9][0-9]$ ]] || (echo "App version extraction failed: $appver is not x.xx. Aborting." && exit 1)

# Copy app skeleton and lua libs to build folder
echo "Copying build files"
mkdir -p build
cp -r app_skeleton/* build/
cp -r ../images build/assets/
cp -r ../levels build/assets/
cp -r ../sounds build/assets/
cp -r ../fonts build/assets/

shopt -s extglob
mkdir -p build/assets/lib
cp -r ../lib/!(*_desktop.lua|locale) build/assets/lib/

if $make_pkg
then
    # Make vita package
    vita-mksfoex -s APP_VER="0${appver}" -s TITLE_ID="${appid}" "${title}" build/sce_sys/param.sfo
    7z a -tzip "${title}_v${appver}.vpk" -r ./build/* ./build/eboot.bin
fi
