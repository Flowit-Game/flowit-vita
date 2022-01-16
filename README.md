# Flowit-Vita / Flowit-Desktop
A port of the puzzle game [Flowit](https://github.com/Flowit-Game/Flowit/) by ByteHamster. The original is an Android app written in Java; this is a reimplementation written in Lua using [Lua Player Plus Vita](https://github.com/Rinnegatamante/lpp-vita) by Rinnegatamante. The port runs on Desktop and on the PlayStation Vita.

## Screenshots
<img src="screenshots/screenshot01.png" width="350"/>
<img src="screenshots/screenshot02.png" width="350"/>
<img src="screenshots/screenshot03.png" width="350"/>
<img src="screenshots/screenshot04.png" width="350"/>

## Running on Desktop
To run on Desktop, install the [LÖVE](https://love2d.org) engine and execute `love .` from the top directory.

## Building for PS Vita
Gameplay depends on the touchscreen, so the experience is better on the handheld PS Vita than on PS TV.

On Linux, enter the `flowit-vita` directory and execute `./build.sh`.

The `eboot.bin` file is compiled from [Lua Player Plus](https://github.com/Rinnegatamante/lpp-vita). To build that for yourself as well, note that you need a version of Lua Player Plus recent enough to include text width and height detection (added in [this commit](https://github.com/Rinnegatamante/lpp-vita/commit/8124c469d6b8c43d1567b253a3ba13c6e0dcaa67)).

## Making levels
New levels can be created using the online editor at [https://flowit.bytehamster.com](https://flowit.bytehamster.com) and contributed [upstream](https://github.com/Flowit-Game/Flowit/). Alternatively, you can create levels and append the resulting XML to the level packs in `assets/levels/`.

## Languages
The app can run in English, Chinese (中文), or Japanese (日本語). Localization strings are in `lib/translation.lua`.

## License
Licenses for the bundled fonts can be found in the `fonts/` directory.

Jonathan Poelen's [xmlparser](https://github.com/jonathanpoelen/xmlparser) library and Egor Malyutin's [hlp](https://github.com/egormalyutin/hlp) library are included under their original MIT licenses.

Other files and code are released under GPLv3.
