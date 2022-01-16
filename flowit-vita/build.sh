#! /bin/bash

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
    vita-mksfoex -s TITLE_ID="${appid}" "${title}" build/sce_sys/param.sfo
    7z a -tzip "${title}.vpk" -r ./build/* ./build/eboot.bin
fi
