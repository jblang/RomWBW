;======================================================================
;
;	AY-3-8910 / YM2149 SOUND DRIVER
;
;======================================================================
;
; @3.579545 OCTAVE RANGE IS 2 - 7 (Bb2/A#2 .. A7)
; @4.000000 OCTAVE RANGE IS 2 - 7 (B2 .. A7)
;
AY_RCSND	.EQU	0		; 0 = EB MODULE, 1=MF MODULE
;
#IF (AYMODE == AYMODE_SCG)
AY_RSEL		.EQU	$9A
AY_RDAT		.EQU	$9B
AY_RIN		.EQU	AY_RSEL
AY_ACR		.EQU	$9C
AY_CLK		.SET	3579545 	; MSX NTSC COLOUR BURST FREQ = 315/88
#ENDIF
;
#IF (AYMODE == AYMODE_N8)
AY_RSEL		.EQU	$9C
AY_RDAT		.EQU	$9D
AY_RIN		.EQU	AY_RSEL
AY_ACR		.EQU	N8_DEFACR
#ENDIF
;
#IF (AYMODE == AYMODE_RCZ80)
AY_RSEL		.EQU	$D8
AY_RDAT		.EQU	$D0
AY_RIN		.EQU	AY_RSEL+AY_RCSND
#ENDIF
;
#IF (AYMODE == AYMODE_RCZ180)
AY_RSEL		.EQU	$68
AY_RDAT		.EQU	$60
AY_RIN		.EQU	AY_RSEL+AY_RCSND
#ENDIF
;
#IF (AYMODE == AYMODE_MSX)
AY_RSEL		.EQU	$A0
AY_RDAT		.EQU	$A1
AY_RIN		.EQU	$A2
#ENDIF
;
#IF (AYMODE == AYMODE_LINC)
AY_RSEL		.EQU	$33
AY_RDAT		.EQU	$32
AY_RIN		.EQU	$32
#ENDIF
;
#IF (AYMODE == AYMODE_MBC)
AY_RSEL		.EQU	$A0
AY_RDAT		.EQU	$A1
AY_RIN		.EQU	AY_RSEL
AY_ACR		.EQU	$A2
AY_CLK		.SET	3579545 	; MSX NTSC COLOUR BURST FREQ = 315/88
#ENDIF
;
;======================================================================
;
;	REGISTERS
;
AY_R2CHBP	.EQU	$02
AY_R3CHBP	.EQU	$03
AY_R7ENAB	.EQU	$07
AY_R8AVOL	.EQU	$08
;
;======================================================================
;
;	DRIVER FUNCTION TABLE AND INSTANCE DATA
;
AY_FNTBL:
	.DW	AY_RESET
	.DW	AY_VOLUME
	.DW	AY_PERIOD
	.DW	AY_NOTE
	.DW	AY_PLAY
	.DW	AY_QUERY
	.DW	AY_DURATION
	.DW	AY_DEVICE
;
#IF (($ - AY_FNTBL) != (SND_FNCNT * 2))
	.ECHO	"*** INVALID SND FUNCTION TABLE ***\n"
	!!!!!
#ENDIF
;
AY_IDAT	.EQU	0			; NO INSTANCE DATA ASSOCIATED WITH THIS DEVICE
;
;======================================================================
;
;	DEVICE CAPABILITIES AND CONFIGURATION
;
AY_TONECNT	.EQU	3		; COUNT NUMBER OF TONE CHANNELS
AY_NOISECNT	.EQU	1		; COUNT NUMBER OF NOISE CHANNELS
;
#IF (AY_CLK > 3579545)			; DEPENDING ON THE 
AY_SCALE	.EQU	2		; INPUT CLOCK FREQUENCY
#ELSE					; PRESCALE THE TONE PERIOD
AY_SCALE	.EQU	3		; DATA TO MAINTAIN MAXIMUM
#ENDIF					; RANGE AND ACCURACY
;
AY_RATIO	.EQU	(AY_CLK * 100) / (16 >> AY_SCALE)
;
#INCLUDE "audio.inc"
;
;======================================================================
;
;	DRIVER INITIALIZATION (THERE IS NO PRE-INITIALIZATION)
;
;	ANNOUNCE DEVICE ON CONSOLE. ACTIVATE DEVICE IF REQUIRED.
;	SETUP FUNCTION TABLES. SETUP THE DEVICE.
;	ANNOUNCE DEVICE WITH BEEP. SET VOLUME OFF.
;	RETURN INITIALIZATION STATUS
;
AY38910_INIT:
	CALL	NEWLINE			; ANNOUNCE
	PRTS("AY:$")
;
#IF (AYMODE == AYMODE_SCG)
	PRTS(" MODE=SCG$")
#ENDIF
;
#IF (AYMODE == AYMODE_N8)
	PRTS(" MODE=N8$")
#ENDIF
;
#IF (AYMODE == AYMODE_RCZ80)
	PRTS(" MODE=RCZ80$")
#ENDIF
;
#IF (AYMODE == AYMODE_RCZ180)
	PRTS(" MODE=RCZ180$")
#ENDIF
;
#IF (AYMODE == AYMODE_MSX)
	PRTS(" MODE=MSX$")
#ENDIF
;
#IF (AYMODE == AYMODE_MBC)
	PRTS(" MODE=MBC$")
#ENDIF
;
#IF (AYMODE == AYMODE_LINC)
	PRTS(" MODE=LINC$")
#ENDIF
;	
	PRTS(" IO=0x$")
	LD	A,AY_RSEL
	CALL	PRTHEXBYTE
;
#IF ((AYMODE == AYMODE_SCG) | (AYMODE == AYMODE_N8) | (AYMODE == AYMODE_MBC))
	LD	A,$FF			; ACTIVATE DEVICE BIT 4 IS AY RESET CONTROL, BIT 3 IS ACTIVE LED
	OUT	(AY_ACR),A		; SET INIT AUX CONTROL REG
#ENDIF
;
	LD	DE,(AY_R2CHBP*256)+$55	; SIMPLE HARDWARE PROBE
	CALL	AY_WRTPSG		; WRITE AND
	CALL	AY_RDPSG		; READ TO A
	LD	A,$55			; SOUND CHANNEL
	CP	E			; REGISTER
	JR	Z,AY_FND
;
	CALL	PRTSTRD \ .TEXT " NOT PRESENT$"
;
	LD	A,$FF			; UNSUCCESSFULL INIT
	RET
;
AY_FND:	LD	IY, AY_IDAT		; SETUP FUNCTION TABLE
	LD	BC, AY_FNTBL		; POINTER TO INSTANCE DATA
	LD	DE, AY_IDAT		; BC := FUNCTION TABLE ADDRESS
	CALL	SND_ADDENT		; DE := INSTANCE DATA PTR
;
	CALL	AY_INIT			; SET DEFAULT CHIP CONFIGURATION
;
	LD	E,$07			; SET VOLUME TO 50%
	CALL	AY_SETV			; ON ALL CHANNELS
;
;	LD	DE,(AY_R2CHBP*256)+$55	; BEEP ON CHANNEL B (CENTER)
;	CALL	AY_WRTPSG		; R02 = $55 = 01010101
	LD	DE,(AY_R3CHBP*256)+$00
	CALL	AY_WRTPSG		; R03 = $00 = XXXX0000
;
#IF (SYSTIM != TM_NONE)
	LD	A, TICKFREQ / 3		; SCHEDULE IN 1/3 SECOND TO TURN OFF SOUND
	LD	(AY_TIMTIK), A
;
	LD	HL, (VEC_TICK + 1)	; GET CUR TICKS VECTOR
	LD	(AY_TIMHOOK), HL	; SAVE IT INTERNALLY
	LD	HL, AY_TIMER		; INSTALL TIMER HOOK HANDLER
	LD	(VEC_TICK + 1), HL
;
	LD	A, $02			; NOT READY & IN INTERUPT HANDLER
	LD	(AY_READY), A
#ELSE
 	CALL	LDELAY			; HALF SECOND DELAY
 	LD	E,$00			; SET VOLUME OFF
	CALL	AY_SETV			; ON ALL CHANNELS
	LD	A, $01			; READY & NOT IN INTERUPT HANDLER
	LD	(AY_READY), A
#ENDIF
;
	XOR	A			; SUCCESSFULL INIT
	RET
;
#IF (SYSTIM != TM_NONE)
AY_TIMER:
	LD	A, (AY_TIMTIK)
	DEC	A
	LD	(AY_TIMTIK), A
	JR	NZ, AY_TIMER1
;
	LD	E,$00			; SET VOLUME OFF
	CALL	AY_SETV			; ON ALL CHANNELS
	LD	A, $01			; READY & NOT IN INTERUPT HANDLER
	LD	(AY_READY), A
;
	LD	DE, AY_TIMER		; MAKE AY_TIMER A NO_OP HANDLER
	LD	HL, AY_TIMER1
	LD	BC, 3
	LDIR
;
AY_TIMER1:
	JP	0			; OVERWRITTEN WITH NEXT HANDLER
AY_TIMHOOK:	.EQU	$ - 2

AY_TIMTIK	.DB	0		; COUNT DOWN TO FINISH BOOT BEEP
#ENDIF
;
;======================================================================
;	INITIALIZE DEVICE
;======================================================================
;
AY_INIT:
	LD	DE,(AY_R7ENAB*256)+$F8	; SET MIXER CONTROL / IO ENABLE.  $F8 - 11 111 000
	JP	AY_WRTPSG		; I/O PORTS = OUTPUT, NOISE CHANNEL C, B, A DISABLE, TONE CHANNEL C, B, A ENABLE
;
AY_CHKREDY:
	LD	A, (AY_READY)
	BIT	0, A
	RET	NZ

	POP	HL			; REMOVE LAST RETURN ADDRESS
	OR	$FF
	RET				; RETURN NZ
;
;======================================================================
;	SET VOLUME ALL CHANNELS
;======================================================================
;
AY_SETV:
	PUSH	BC
	LD	B,AY_TONECNT		; NUMBER OF CHANNELS
	LD	D,AY_R8AVOL		; BASE REGISTER FOR VOLUME
AY_SV:	CALL	AY_WRTPSG		; CYCLING THROUGH ALL CHANNELS
	INC	D
	DJNZ	AY_SV
	POP	BC
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - RESET
;
;	INITIALIZE DEVICE. SET VOLUME OFF. RESET VOLUME AND TONE VARIABLES.
;
;======================================================================
;
AY_RESET:
	AUDTRACE(AYT_INIT)
	CALL	AY_CHKREDY		; RETURNS TO OUR CALLER IF NOT READY
;
	PUSH	DE
	PUSH	HL
	CALL	AY_INIT			; SET DEFAULT CHIP CONFIGURATION
;
	AUDTRACE(AYT_VOLOFF)
	LD	E,0			; SET VOLUME OFF
	CALL	AY_SETV			; ON ALL CHANNELS
;
	XOR	A			; SIGNAL SUCCESS
	LD	(AY_PENDING_VOLUME),A	; SET VOLUME TO ZERO
	LD	H,A
	LD	L,A
	LD	(AY_PENDING_PERIOD),HL	; SET TONE PERIOD TO ZERO
;
	POP	HL
	POP	DE
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - VOLUME
;======================================================================
;
AY_VOLUME:
	AUDTRACE(AYT_VOL)
	AUDTRACE_L
	AUDTRACE_CR

	LD	A,L			; SAVE VOLUME
	LD	(AY_PENDING_VOLUME), A
;
	XOR	A			; SIGNAL SUCCESS
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - NOTE
;======================================================================
;
AY_NOTE:
	AUDTRACE(AYT_NOTE)
	AUDTRACE_HL
	AUDTRACE_CR
;
;	CALL	PRTHEXWORDHL
;	CALL	PC_COLON
;
	LD	DE, AY3NOTETBL		; ON ENTRY HL IS THE NOTE TO PLAY
	PUSH	DE			; AND DE IS THE START OF NOTE TABLE
	LD	DE, 48			; LOAD DE WITH NOTE TABLE SIZE
	CALL	DIV16			; AND CALCULATE OCTAVE COUNT IN BC
;			
	ADD	HL, HL			; HL IS THE REMAINDER FROM ABOVE DIVISION (0-47) AND THE NOTE 
	POP	DE			; TO PLAY IN THE OCTAVE. ADD IT TO THE START OF THE NOTE TABLE
	ADD	HL, DE			; TO POINT TO THE PERIOD FOR THE NOTE WE WANT TO PLAY.
;
	LD	A, (HL)			; HL POINT TO CURRENT PERIOD COUNT WE WANT TO PLAY
	INC	HL			; SO LOAD PERIOD COUNT FROM NOTE TABLE INTO HL
	LD	H, (HL)			; SO WE CAN UPDATE IT FOR THE REQUIRED OCTAVE
	LD	L, A
;
	LD	A,AY_SCALE-1		; THE NOTE TABLE PERIOD DATA HAS BEEN
	ADD	A,C			; PRESCALED TO MAINTAIN RANGE SO ALLOW
	LD	B,A			; FOR THIS WHEN CHANGING OCTAVE
AY_NOTE1:
	SRL	H			; ADJUST THE PERIOD DATA
  	RR	L			; FOR THE DESIRED OCTAVE
	DJNZ	AY_NOTE1		; FALL THROUGH TO SET PERIOD AND RANGE CHECK
;
;	CALL	PRTHEXWORDHL
;	CALL	NEWLINE
;
;======================================================================
;	SOUND DRIVER FUNCTION - PERIOD
;======================================================================
;
AY_PERIOD:
	AUDTRACE(AYT_PERIOD)
	AUDTRACE_HL
	AUDTRACE_CR

	LD	A, H			; IF ZERO - ERROR
	OR	L
	JR	Z, AY_PERIOD1
;
	LD	A, H			; MAXIMUM TONE PERIOD IS 12-BITS
	AND	11110000B		; ALLOWED RANGE IS 0001-0FFF (4095)
	JR	NZ, AY_PERIOD1		; RETURN NZ IF NUMBER TOO LARGE
	LD	(AY_PENDING_PERIOD), HL	; SAVE AND RETURN SUCCESSFUL
	RET
;
AY_PERIOD1:
	LD	A, $FF			; REQUESTED PERIOD IS LARGER
	LD	(AY_PENDING_PERIOD), A	; THAN THE DEVICE CAN SUPPORT
	LD	(AY_PENDING_PERIOD+1), A; SO SET PERIOD TO FFFF
	RET				; AND RETURN FAILURE
;
;======================================================================
;	SOUND DRIVER FUNCTION - PLAY
;	B = FUNCTION
;	C = AUDIO DEVICE
;	D = CHANNEL
;	A = EXIT STATUS
;======================================================================
;
AY_PLAY:
	AUDTRACE(AYT_PLAY)
	AUDTRACE_D
	AUDTRACE_CR
	CALL	AY_CHKREDY		; RETURNS TO OUR CALLER IF NOT READY
;
	LD	A, (AY_PENDING_PERIOD + 1)	; CHECK THE HIGH BYTE OF THE PERIOD
	INC	A
	JR	Z, AY_PLAY1		; PERIOD IS TOO LARGE, UNABLE TO PLAY
;
	PUSH	HL
	PUSH	DE
	LD	A,D			; LIMIT CHANNEL 0-2
	AND	$3			; AND INDEX TO THE
	ADD	A,A			; CHANNEL REGISTER
	LD	D,A			; FOR THE TONE PERIOD
;
	AUDTRACE(AYT_REGWR)
	AUDTRACE_A
	AUDTRACE_CR
;
	LD	HL,AY_PENDING_PERIOD	; WRITE THE LOWER
	ld	E,(HL)			; 8-BITS OF THE TONE PERIOD
	CALL	AY_WRTPSG
	INC	D			; NEXT REGISTER
	INC	HL			; NEXT BYTE
	LD	E,(HL)			; WRITE THE UPPER
	CALL	AY_WRTPSG       	; 8-BITS OF THE TONE PERIOD
;
	POP	DE			; RECALL CHANNEL
	PUSH	DE			; SAVE CHANNEL
;
	LD	A,D			; LIMIT CHANNEL 0-2
	AND	$3			; AND INDEX TO THE
	ADD	A,AY_R8AVOL		; CHANNEL VOLUME
	LD	D,A			; REGISTER
;
	AUDTRACE(AYT_REGWR)
	AUDTRACE_A
	AUDTRACE_CR
;
	INC	HL			; NEXT BYTE
	LD	A,(HL)			; PENDING VOLUME
	RRCA				; MAP THE VOLUME
	RRCA				; FROM 00-FF
	RRCA				; TO 00-0F
	RRCA
	AND	$0F
	LD	E,A
	CALL	AY_WRTPSG		; SET VOL (E) IN CHANNEL REG (D)
;
	POP	DE			; RECALL CHANNEL
	POP	HL
;
	XOR	A			; SIGNAL SUCCESS
	RET
;
AY_PLAY1:
	PUSH	DE			; TURN VOLUME OFF TO STOP PLAYING
	LD	A,D			; LIMIT CHANNEL 0-2
	AND	$3			; AND INDEX TO THE
	ADD	A,AY_R8AVOL		; CHANNEL VOLUME
	LD	D,A			; REGISTER
	LD	E,0
	CALL	AY_WRTPSG		; SET VOL (E) IN CHANNEL REG (D)
	POP	DE
	OR	$FF			; SIGNAL FAILURE
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - QUERY AND SUBFUNCTIONS
;======================================================================
;
AY_QUERY:
	LD	A, E
	CP	BF_SNDQ_CHCNT		; SUB FUNCTION 01
	JR	Z, AY_QUERY_CHCNT
;
	CP	BF_SNDQ_VOLUME		; SUB FUNCTION 02
	JR	Z, AY_QUERY_VOLUME
;
	CP	BF_SNDQ_PERIOD		; SUB FUNCTION 03
	JR	Z, AY_QUERY_PERIOD
;
	CP	BF_SNDQ_DEV		; SUB FUNCTION 04
	JR	Z, AY_QUERY_DEV
;
	OR	$FF			; SIGNAL FAILURE
	RET
;
AY_QUERY_CHCNT:
	LD	BC,(AY_TONECNT*256)+AY_NOISECNT		; RETURN NUMBER OF
	XOR	A					; TONE AND NOISE
	RET						; CHANNELS IN BC
;
AY_QUERY_PERIOD:
	LD	HL, (AY_PENDING_PERIOD)	; RETURN 16-BIT PERIOD
	XOR	A			; IN HL REGISTER
	RET
;
AY_QUERY_VOLUME:
	LD	A, (AY_PENDING_VOLUME)	; RETURN 8-BIT VOLUME
	LD	L, A			; IN L REGISTER
	XOR	A
;	LD	H, A
	RET
;
AY_QUERY_DEV:
	LD	B, SNDDEV_AY38910		; RETURN DEVICE IDENTIFIER
	LD	DE, (AY_RSEL*256)+AY_RDAT	; AND ADDRESS AND DATA PORT
	XOR	A
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - DURATION
;======================================================================
;
AY_DURATION:
	LD	(AY_PENDING_DURATION),HL	; SET TONE DURATION
	XOR	A
	RET
;
;======================================================================
;	SOUND DRIVER FUNCTION - DEVICE
;======================================================================
;
AY_DEVICE:
	LD	D,SNDDEV_AY38910	; D := DEVICE TYPE
	LD	E,0			; E := PHYSICAL UNIT
	LD	C,$00			; C := DEVICE TYPE
	LD	H,AYMODE		; H := MODE
	LD	L,AY_RSEL		; L := BASE I/O ADDRESS
	XOR	A
	RET
;
;======================================================================
;	NON-BLOCKING INTERRUPT CODE
;======================================================================
;
AY_DI:
	LD	A, (AY_READY)
	BIT	1, A
	RET	NZ
	HB_DI
	RET
;
AY_EI:
	LD	A, (AY_READY)
	BIT	1, A
	RET	NZ
	HB_EI
	RET
;
;======================================================================
;
; 	WRITE DATA IN E REGISTER TO DEVICE REGISTER D
;	INTERRUPTS DISABLE DURING WRITE. WRITE IN SLOW MODE IF Z180 CPU.
;
;======================================================================
;
AY_WRTPSG:
	CALL	AY_DI
#IFDEF SBCV2004
	LD	A,(HB_RTCVAL)		; GET CURRENT RTC LATCH VALUE
	OR	%00001000		; SBC-V2-004 CHANGE
	OUT	(RTCIO),A		; TO HALF CLOCK SPEED
#ENDIF
#IF (CPUFAM == CPU_Z180)
	IN0	A,(Z180_DCNTL)		; GET WAIT STATES
	PUSH	AF			; SAVE VALUE
	OR	%00110000		; FORCE SLOW OPERATION (I/O W/S=3)
	OUT0	(Z180_DCNTL),A		; AND UPDATE DCNTL
#ENDIF
	LD	A,D			; SELECT THE REGISTER WE
	OUT	(AY_RSEL),A		; WANT TO WRITE TO
	LD	A,E			; WRITE THE VALUE TO
	OUT	(AY_RDAT),A		; THE SELECTED REGISTER
#IF (CPUFAM == CPU_Z180)
	POP	AF			; GET SAVED DCNTL VALUE
	OUT0	(Z180_DCNTL),A		; AND RESTORE IT
#ENDIF
#IFDEF SBCV2004
	LD	A,(HB_RTCVAL)		; SBC-V2-004 CHANGE TO
	OUT	(RTCIO),A		; NORMAL CLOCK SPEED
#ENDIF
	JP	AY_EI
;
;======================================================================
;
;	READ FROM REGISTER D AND RETURN WITH RESULT IN E
;
AY_RDPSG:
	CALL	AY_DI
#IFDEF SBCV2004
	LD	A,(HB_RTCVAL)		; GET CURRENT RTC LATCH VALUE
	OR	%00001000		; SBC-V2-004 CHANGE
	OUT	(RTCIO),A		; TO HALF CLOCK SPEED
#ENDIF
#IF (CPUFAM == CPU_Z180)
	IN0	A,(Z180_DCNTL)		; GET WAIT STATES
	PUSH	AF			; SAVE VALUE
	OR	%00110000		; FORCE SLOW OPERATION (I/O W/S=3)
	OUT0	(Z180_DCNTL),A		; AND UPDATE DCNTL
#ENDIF
	LD	A,D			; SELECT THE REGISTER WE
	OUT	(AY_RSEL),A		; WANT TO READ
	IN	A,(AY_RIN)		; READ SELECTED REGISTER
	LD	E,A
#IF (CPUFAM == CPU_Z180)
	POP	AF			; GET SAVED DCNTL VALUE
	OUT0	(Z180_DCNTL),A		; AND RESTORE IT
#ENDIF
#IFDEF SBCV2004
	LD	A,(HB_RTCVAL)		; SBC-V2-004 CHANGE TO
	OUT	(RTCIO),A		; NORMAL CLOCK SPEED
#ENDIF
	JP	AY_EI
;
;======================================================================
;
AY_PENDING_PERIOD	.DW	0	; PENDING PERIOD (12 BITS)	; ORDER
AY_PENDING_VOLUME	.DB	0	; PENDING VOL (8 BITS)		; SIGNIFICANT
AY_PENDING_DURATION	.DW	0	; PENDING DURATION (16 BITS)
AY_READY		.DB	0	; BIT 0 -> NZ DRIVER IS READY TO RECEIVE PLAY COMMAND
					; BIT 1 -> NZ EXECUTING WITHIN TIMER HANDLER = DO NOT DIS/ENABLE INT
;
#IF AUDIOTRACE
AYT_INIT		.DB	"\r\nAY_INIT\r\n$"
AYT_VOLOFF		.DB	"\r\nAY_VOLUME OFF\r\n$"
AYT_VOL			.DB	"\r\nAY_VOLUME: $"
AYT_NOTE		.DB	"\r\nAY_NOTE: $"
AYT_PERIOD		.DB	"\r\nAY_PERIOD $"
AYT_PLAY		.DB	"\r\nAY_PLAY CH: $"
AYT_REGWR		.DB	"\r\nOUT AY-3-8910 $"
#ENDIF
;
;======================================================================
;	QUARTER TONE FREQUENCY TABLE
;======================================================================
;
; THE FREQUENCY BY QUARTER TONE STARTING AT A0# OCTAVE 0
; USED TO MAP EACH OCTAVE (DIV BY 2 TO JUMP AN OCTAVE UP)
; FIRST PLAYABLE NOTE WILL BE 0
; ASSUMING A CLOCK OF 1843200 THIS MAPS TO A0#
;
AY3NOTETBL:
	.DW	AY_RATIO / 2913
	.DW	AY_RATIO / 2956
	.DW	AY_RATIO / 2999
	.DW	AY_RATIO / 3042
	.DW	AY_RATIO / 3086
	.DW	AY_RATIO / 3131
	.DW	AY_RATIO / 3177
	.DW	AY_RATIO / 3223
	.DW	AY_RATIO / 3270
	.DW	AY_RATIO / 3318
	.DW	AY_RATIO / 3366
	.DW	AY_RATIO / 3415
	.DW	AY_RATIO / 3464
	.DW	AY_RATIO / 3515
	.DW	AY_RATIO / 3566
	.DW	AY_RATIO / 3618
	.DW	AY_RATIO / 3670
	.DW	AY_RATIO / 3724
	.DW	AY_RATIO / 3778
	.DW	AY_RATIO / 3833
	.DW	AY_RATIO / 3889
	.DW	AY_RATIO / 3945
	.DW	AY_RATIO / 4003
	.DW	AY_RATIO / 4061
	.DW	AY_RATIO / 4120
	.DW	AY_RATIO / 4180
	.DW	AY_RATIO / 4241
	.DW	AY_RATIO / 4302
	.DW	AY_RATIO / 4365
	.DW	AY_RATIO / 4428
	.DW	AY_RATIO / 4493
	.DW	AY_RATIO / 4558
	.DW	AY_RATIO / 4624
	.DW	AY_RATIO / 4692
	.DW	AY_RATIO / 4760
	.DW	AY_RATIO / 4829
	.DW	AY_RATIO / 4899
	.DW	AY_RATIO / 4971
	.DW	AY_RATIO / 5043
	.DW	AY_RATIO / 5116
	.DW	AY_RATIO / 5191
	.DW	AY_RATIO / 5266
	.DW	AY_RATIO / 5343
	.DW	AY_RATIO / 5421
	.DW	AY_RATIO / 5499
	.DW	AY_RATIO / 5579
	.DW	AY_RATIO / 5661
	.DW	AY_RATIO / 5743
