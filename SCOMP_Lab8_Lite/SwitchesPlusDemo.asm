; SwitchesPlusDemo.asm

ORG 0
	LOADI 0
	IN bit_def
Loop:
	IN change_mask
	OUT LEDs
	IN change_num
	OUT Hex0
	JUMP Loop


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

