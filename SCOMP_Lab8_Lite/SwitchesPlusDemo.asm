; SwitchesPlusDemo.asm

ORG 0
	LOADI 0
	IN bit_def
	OUT LEDs
Finish:
	JUMP Finish

; Variables
Pattern:   DW 0

; Useful values
Bit0:      DW &B0000000001
Bit9:      DW &B1000000000

; IO address constants
Switches:  	EQU 000
LEDs:      	EQU 001
Timer:     	EQU 002
Hex0:      	EQU 004
Hex1:      	EQU 005
bit_def:   	EQU 060
bit_inv: 	EQU 061
pop_high:	EQU 062
pop_low:	EQU 063
