; SwitchesPlusDemo.asm

ORG 0
	LOADI 0
	IN bit_def
WaitForChange:
	IN change_num
	JZERO WaitForChange
	
	IN bit_def
GenerateNumber:
	LOAD Goal
	ADDI 1
	STORE Goal
	IN change_num
	JZERO GenerateNumber
	
	;Make goal only 10 bits wide
	LOAD Goal
	AND LSB10Mask
	STORE Goal
	OUT Hex0

	LOAD Goal
	OUT LEDs
	OUT sim_softsave
	OUT password
	OUT Timer
Loop:
	IN password
	JZERO Loop
	LOADI &H00AA
	OUT Hex1
Finish:
	JUMP Finish



;Variables
Goal: DW 0
Score: DW 0

;Constants
LSB10Mask: DW &B1111111111

; IO address constants
Switches:  		EQU 000
LEDs:      		EQU 001
Timer:     		EQU 002
Hex0:      		EQU 004
Hex1:      		EQU 005
bit_def:   		EQU 096
bit_inv: 		EQU 097
pop_high:		EQU 098
pop_low:		EQU 099
change_mask:	EQU 100
change_num:		EQU 101
password:		EQU 102
sim_snapsave:	EQU 103
sim_softsave:	EQU 104
sim_status:		EQU 105

