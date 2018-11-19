# Invoke-CreateRemoteThread64

Powershell script for creating a remote thread in a 64 bit process from a 32 bit process.

## Usage

* The remote executable memory needs to have been allocated and filled with the target shellcode.  
* An open handle to the remote process is required.


            Invoke-CreateRemoteThread64 -ProcessHandle $hProcess -ThreadStartRoutine $pShellcode
            Invoke-CreateRemoteThread64 -ProcessHandle $hProcess -ThreadStartRoutine $pShellcode -Parameter 123

## Troubleshooting


See "Invoke-Test.ps1" for an example            
            

## Acknowledgments

This is essentially a C# wrapper around a modified version of Stephen Fewer's 32->64 remote thread code from metasploit.

https://github.com/rapid7/metasploit-payloads/tree/master/c/meterpreter/source/common/arch/win/i386
