; SwitchesPlusDemo.asm

ORG 0
	LOADI 0
	IN pop_high
	OUT LEDs
Finish:
	JUMP Finish


; IO address constants
Switches:  	EQU 000
LEDs:      	EQU 001
Timer:     	EQU 002
Hex0:      	EQU 004
Hex1:      	EQU 005
bit_def:   	EQU 096
bit_inv: 	EQU 097
pop_high:	EQU 098
pop_low:	EQU 099
