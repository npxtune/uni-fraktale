cmake_minimum_required(VERSION 3.27)
project(Mandelbrot C)

set(CMAKE_C_STANDARD 11)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/raylib)

add_executable(Mandelbrot main.c)
target_include_directories(${PROJECT_NAME} PRIVATE external/raylib/src /opt/homebrew/Cellar/gmp/6.3.0/include)
target_link_libraries(${PROJECT_NAME} raylib_static)