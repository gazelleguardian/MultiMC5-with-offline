@echo off

pushd "%~dp0"

set BUILD_TYPE=%1
set COMPILER=%2

set VCPKG_D=C:/Source/vcpkg
set CLANG_BIN=C:/Source/LLVM/build/bin

set CMAKE_BASE=cmake -S . -DCMAKE_TOOLCHAIN_FILE=%VCPKG_D%/scripts/buildsystems/vcpkg.cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

if "%COMPILER%"=="mingw" (
  goto :mingw
) else (
  goto :clang
)

exit /b

rem MinGW configuration
:mingw

mkdir build\MinGW-%BUILD_TYPE%
mkdir build\MinGW-%BUILD_TYPE%-install

set COMMAND=%CMAKE_BASE% ^
  -B build/MinGW-%BUILD_TYPE% ^
  -G "MinGW Makefiles"
  -DCMAKE_INSTALL_PREFIX=build/%COMPILER%-%BUILD_TYPE%-install ^
  -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^

echo CMake command: %COMMAND%
%COMMAND%
goto :end

rem clang + Visualstudio (not clang-cl)
:clang
set COMPILER=Clang
mkdir build\Clang-%BUILD_TYPE%
mkdir build\Clang-%BUILD_TYPE%-install

if "%LIB%"=="" goto :clang_env_err

set COMMAND=%CMAKE_BASE% ^
  -B build/Clang-%BUILD_TYPE% ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX=build/Clang-%BUILD_TYPE%-install ^
  -DCMAKE_C_COMPILER=%CLANG_BIN%/clang.exe ^
  -DCMAKE_CXX_COMPILER=%CLANG_BIN%/clang.exe

echo CMake command: %COMMAND%
%COMMAND%
goto :end

:clang_env_err
echo This command has to be run from a Visual Studio Developer command prompt (vcvars.bat)
exit /b 1

:end
echo Configuration %BUILD_TYPE% created with compiler %COMPILER% in build/%COMPILER%-%PRESET%
echo Commands:
echo compile: cmake --build build/%COMPILER%-%PRESET%
echo install: cmake --build build/%COMPILER%-%PRESET% -t install
