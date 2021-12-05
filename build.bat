@echo off

set PRESET=%1
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

mkdir build\MinGW-%PRESET%
mkdir build\MinGW-%PRESET%-install

set COMMAND=%CMAKE_BASE% ^
  -B build/MinGW-%PRESET% ^
  -G "MinGW Makefiles"
  -DCMAKE_INSTALL_PREFIX=build/%COMPILER%-%PRESET%-install ^
  -DCMAKE_BUILD_TYPE=%PRESET% ^

echo CMake command: %COMMAND%
%COMMAND%
goto :end

rem clang + Visualstudio (not clang-cl)
:clang
set COMPILER=Clang
mkdir build\Clang-%PRESET%
mkdir build\Clang-%PRESET%-install

if "%LIB%"=="" goto :clang_env_err

set COMMAND=%CMAKE_BASE% ^
  -B build/Clang-%PRESET% ^
  -G "Ninja" ^
  -DCMAKE_INSTALL_PREFIX=build/Clang-%PRESET%-install ^
  -DCMAKE_C_COMPILER=%CLANG_BIN%/clang.exe ^
  -DCMAKE_CXX_COMPILER=%CLANG_BIN%/clang.exe

echo CMake command: %COMMAND%
%COMMAND%
goto :end

:clang_env_err
echo This command has to be run from a Visual Studio Developer command prompt (vcvars.bat)
exit /b 1

:end
echo Configuration %PRESET% created with compiler %COMPILER% in build/%COMPILER%-%PRESET%
echo Commands:
echo compile: cmake --build build/%COMPILER%-%PRESET%
echo install: cmake --build build/%COMPILER%-%PRESET% -t install
