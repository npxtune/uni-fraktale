# Build instructions

### MacOS & Linux

#### OpenGL
```zsh
git clone https://github.com/npxtune/uni-fraktale
cd uni-fraktale
git submodule update --init --recursive   # To fetch raylib & raygui
mkdir build && cd ./build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j 6 # '6' -> How many cores you want to use
./uni-fraktale
```
That's it. Remember to install the necessary raylib + raygui [dependencies](https://github.com/raysan5/raylib/wiki) for your platform.

---
### Windows
**Info:**    I do not own a device that runs on Windows. These instructions might not work.
If there are any issues, feel free to open an issue & PR request.

**Requirements:**
1. Git (https://git-scm.com/)
2. MinGW-w64 (https://www.mingw-w64.org/)
3. CMake (https://cmake.org/download/)

**Follow these steps to install MinGW-w64 for Windows:** https://code.visualstudio.com/docs/cpp/config-mingw#_installing-the-mingww64-toolchain

Once complete, continue in Powershell:

```zsh
git clone https://github.com/npxtune/uni-fraktale.git
cd uni-fraktale
git submodule update --init --recursive   # To fetch raylib & raygui
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j 6 # '6' -> How many cores you want to use
```

There should now be an executable called `uni-fraktale.exe` in your build folder.
Run it and the application should open.

---
#### Copyright & Licensing
```
    Copyright (c) 2023-2024 Tim <npxtune@scanf.dev> , All rights served.
    This project is MIT licensed.
```
