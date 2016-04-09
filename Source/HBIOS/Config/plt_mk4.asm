;
;==================================================================================================
;   ROMWBW 2.X CONFIGURATION FOR N8 2312
;==================================================================================================
;
; BUILD CONFIGURATION OPTIONS
;
CPUOSC		.EQU	18432000	; CPU OSC FREQ
RAMSIZE		.EQU	512		; SIZE OF RAM IN KB, MUST MATCH YOUR HARDWARE!!!
CONBAUD		.EQU	38400		; DEFAULT BAUDRATE USED BELOW
;
CRTACT		.EQU	FALSE		; CRT ACTIVATION AT STARTUP
VDAEMU		.EQU	EMUTYP_ANSI	; DEFAULT VDA EMULATION (EMUTYP_TTY, EMUTYP_ANSI, ...)
;
DSKYENABLE	.EQU	FALSE		; TRUE FOR DSKY SUPPORT (DO NOT COMBINE WITH PPIDE)
;
SIMRTCENABLE	.EQU	FALSE		; SIMH CLOCK DRIVER
DSRTCENABLE	.EQU	TRUE		; DS-1302 CLOCK DRIVER
DSRTCMODE	.EQU	DSRTCMODE_STD	; DSRTCMODE_STD, DSRTCMODE_MFPIC
;
UARTENABLE	.EQU	TRUE		; TRUE FOR UART SUPPORT (ALMOST ALWAYS WANT THIS TO BE TRUE)
UARTOSC		.EQU	1843200		; UART OSC FREQUENCY
UARTCNT		.EQU	6		; NUMBER OF UARTS
UART0IOB	.EQU	$80		; IOBASE (CASSETTE INTERFACE)
UART0BAUD	.EQU	CONBAUD		; BAUDRATE
UART0FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
UART1IOB	.EQU	$88		; IOBASE (MF/PIC)
UART1BAUD	.EQU	CONBAUD		; BAUDRATE
UART1FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
UART2IOB	.EQU	$C0		; IOBASE (4UART PORT A)
UART2BAUD	.EQU	CONBAUD		; BAUDRATE
UART2FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
UART3IOB	.EQU	$C8		; IOBASE (4UART PORT B)
UART3BAUD	.EQU	CONBAUD		; BAUDRATE
UART3FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
UART4IOB	.EQU	$D0		; IOBASE (4UART PORT C)
UART4BAUD	.EQU	CONBAUD		; BAUDRATE
UART4FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
UART5IOB	.EQU	$D8		; IOBASE (4UART PORT D)
UART5BAUD	.EQU	CONBAUD		; BAUDRATE
UART5FEAT	.EQU	UF_FIFO		; FEATURE FLAGS: UF_FIFO | UF_AFC
;
ASCIENABLE	.EQU	TRUE		; TRUE FOR Z180 ASCI SUPPORT
ASCI0BAUD	.EQU	CONBAUD		; ASCI0 BAUDRATE (IMPLEMENTED BY Z180_ASCIB0)
ASCI1BAUD	.EQU	CONBAUD		; ASCI1 BAUDRATE (IMPLEMENTED BY Z180_ASCIB1)
;
VDUENABLE	.EQU	FALSE		; TRUE FOR VDU BOARD SUPPORT
CVDUENABLE	.EQU	FALSE		; TRUE FOR CVDU BOARD SUPPORT
NECENABLE	.EQU	FALSE		; TRUE FOR uPD7220 BOARD SUPPORT
TMSENABLE	.EQU	FALSE		; TRUE FOR N8 (TMS9918) VIDEO/KBD SUPPORT
;
MDENABLE	.EQU	TRUE		; TRUE FOR ROM/RAM DISK SUPPORT (ALMOST ALWAYS WANT THIS ENABLED)
MDTRACE		.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF MDENABLE = TRUE)
;
FDENABLE	.EQU	FALSE		; TRUE FOR FLOPPY SUPPORT
FDMODE		.EQU	FDMODE_N8	; FDMODE_DIO, FDMODE_ZETA, FDMODE_DIDE, FDMODE_N8, FDMODE_DIO3
FDTRACE		.EQU	1		; 0=SILENT, 1=FATAL ERRORS, 2=ALL ERRORS, 3=EVERYTHING (ONLY RELEVANT IF FDENABLE = TRUE)
FDMEDIA		.EQU	FDM144		; FDM720, FDM144, FDM360, FDM120 (ONLY RELEVANT IF FDENABLE = TRUE)
FDMEDIAALT	.EQU	FDM720		; ALTERNATE MEDIA TO TRY, SAME CHOICES AS ABOVE (ONLY RELEVANT IF FDMAUTO = TRUE)
FDMAUTO		.EQU	TRUE		; SELECT BETWEEN MEDIA OPTS ABOVE AUTOMATICALLY
;
RFENABLE	.EQU	FALSE		; TRUE FOR RAM FLOPPY SUPPORT
RFCNT		.EQU	1		; NUMBER OF RAM FLOPPY UNITS
;
IDEENABLE	.EQU	TRUE		; TRUE FOR IDE SUPPORT
IDEMODE		.EQU	IDEMODE_MK4	; IDEMODE_DIO, IDEMODE_DIDE, IDEMODE_MK4
IDECNT		.EQU	2		; NUMBER OF IDE UNITS
IDETRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
IDE8BIT		.EQU	TRUE		; USE IDE 8BIT TRANSFERS (PROBABLY ONLY WORKS FOR CF CARDS!)
;
PPIDEENABLE	.EQU	FALSE		; TRUE FOR PPIDE SUPPORT (DO NOT COMBINE WITH DSKYENABLE)
PPIDEMODE	.EQU	PPIDEMODE_DIO3	; PPIDEMODE_SBC, PPPIDEMODE_DIO3, PPIDEMODE_MFP, PPIDEMODE_N8
PPIDECNT	.EQU	1		; NUMBER OF PPIDE UNITS
PPIDETRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPIDEENABLE = TRUE)
PPIDE8BIT	.EQU	FALSE		; USE IDE 8BIT TRANSFERS (PROBABLY ONLY WORKS FOR CF CARDS!)
PPIDESLOW	.EQU	FALSE		; ADD DELAYS TO HELP PROBLEMATIC HARDWARE (TRY THIS IF PPIDE IS UNRELIABLE)
;
SDENABLE	.EQU	TRUE		; TRUE FOR SD SUPPORT
SDMODE		.EQU	SDMODE_MK4	; SDMODE_JUHA, SDMODE_CSIO, SDMODE_UART, SDMODE_PPI, SDMODE_DSD, SDMODE_MK4
SDTRACE		.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
SDCSIOFAST	.EQU	TRUE		; TABLE-DRIVEN BIT INVERTER
;
PRPENABLE	.EQU	FALSE		; TRUE FOR PROPIO SUPPORT
PRPIOB		.EQU	$A8		; PORT IO ADDRESS BASE
PRPSDENABLE	.EQU	TRUE		; TRUE FOR PROPIO SD SUPPORT
PRPSDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PRPSDENABLE = TRUE)
PRPCONENABLE	.EQU	TRUE		; TRUE FOR PROPIO CONSOLE SUPPORT (PS/2 KBD & VGA VIDEO)
;
PPPENABLE	.EQU	FALSE		; TRUE FOR PARPORTPROP SUPPORT
PPPSDENABLE	.EQU	TRUE		; TRUE FOR PARPORTPROP SD SUPPORT
PPPSDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPPENABLE = TRUE)
PPPCONENABLE	.EQU	TRUE		; TRUE FOR PROPIO CONSOLE SUPPORT (PS/2 KBD & VGA VIDEO)
;
HDSKENABLE	.EQU	FALSE		; TRUE FOR SIMH HDSK SUPPORT
HDSKTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF IDEENABLE = TRUE)
;
PPKENABLE	.EQU	FALSE		; TRUE FOR PARALLEL PORT KEYBOARD
PPKTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF PPKENABLE = TRUE)
KBDENABLE	.EQU	FALSE		; TRUE FOR PS/2 KEYBOARD ON I8242
KBDTRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF KBDENABLE = TRUE)
;
TTYENABLE	.EQU	FALSE		; INCLUDE TTY EMULATION SUPPORT
ANSIENABLE	.EQU	FALSE		; INCLUDE ANSI EMULATION SUPPORT
ANSITRACE	.EQU	1		; 0=SILENT, 1=ERRORS, 2=EVERYTHING (ONLY RELEVANT IF ANSIENABLE = TRUE)
;
BOOTTYPE	.EQU	BT_MENU		; BT_MENU (WAIT FOR KEYPRESS), BT_AUTO (BOOT_DEFAULT AFTER BOOT_TIMEOUT SECS)
BOOT_TIMEOUT	.EQU	20		; APPROX TIMEOUT IN SECONDS FOR AUTOBOOT, 0 FOR IMMEDIATE
BOOT_DEFAULT	.EQU	'Z'		; SELECTION TO INVOKE AT TIMEOUT
;
; 18.432MHz OSC @ FULL SPEED, 38.4Kbps
;
Z180_CLKDIV	.EQU	1		; 0=OSC/2, 1=OSC, 2=OSC*2
Z180_MEMWAIT	.EQU	0		; MEMORY WAIT STATES TO INSERT (0-3)
Z180_IOWAIT	.EQU	0		; IO WAIT STATES TO INSERT (0-3)
Z180_ASCIB0	.EQU	20H		; SERIAL PORT 0 DIV, SEE Z180 CLOCKING DOCUMENT
Z180_ASCIB1	.EQU	20H		; SERIAL PORT 1 DIV, SEE Z180 CLOCKING DOCUMENT
;
; 18.432MHz OSC @ DOUBLE SPEED, 38.4Kbps
;
;Z180_CLKDIV	.EQU	2		; 0=OSC/2, 1=OSC, 2=OSC*2
;Z180_MEMWAIT	.EQU	1		; MEMORY WAIT STATES TO INSERT (0-3)
;Z180_IOWAIT	.EQU	1		; IO WAIT STATES TO INSERT (0-3)
;Z180_ASCIB0	.EQU	21H		; SERIAL PORT 0 DIV, SEE Z180 CLOCKING DOCUMENT
;Z180_ASCIB1	.EQU	21H		; SERIAL PORT 1 DIV, SEE Z180 CLOCKING DOCUMENT