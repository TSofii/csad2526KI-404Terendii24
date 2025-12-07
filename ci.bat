@echo off
REM Створюємо папку build, якщо її немає
if not exist build mkdir build

REM Переходимо в папку build
cd build

REM 1. Конфігурація (cmake ..)
cmake ..
if %errorlevel% neq 0 exit /b %errorlevel%

REM 2. Білдування (cmake --build .)
cmake --build .
if %errorlevel% neq 0 exit /b %errorlevel%

REM 3. Запуск тестів (ctest)
ctest -C Debug --output-on-failure
if %errorlevel% neq 0 exit /b %errorlevel%

echo.
echo === BUILD AND TESTS SUCCESSFUL ===
pause