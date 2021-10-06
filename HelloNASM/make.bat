REM assemble the program
nasm -f win64 hello.asm
REM link the assembled .obj and create an executable file 
gcc hello.obj -o hello.exe
cls
hello.exe