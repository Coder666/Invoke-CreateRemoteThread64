%AppData%\..\Local\NASM\nasm.exe -f bin -O3 -o executex64.bin executex64.asm 
%AppData%\..\Local\NASM\nasm.exe -f bin -O3 -o remotethread.bin remotethread.asm 

py bintohex.py remotethread.bin >remotethread.hex
py bintohex.py executex64.bin >executex64.hex
