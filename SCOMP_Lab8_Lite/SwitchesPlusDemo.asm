; SwitchesPlusDemo.asm
;This is a Airplane Pilot Computer Aid with the purpose of showcasing the features of the new switches peripheral


ORG 0
MAIN:
; MODE 0- System calibration 
; Features used: bit_def, sim_softsave, sim_snapsave

;1. Injects the software with a simulation pattern
;2. Verifies that sim_status returns 1
;3. Checks to make sure bit_inv works
;4. Ensures it was using simulated switches
;5. Displays 'd' if passed and 'E' if failed
Mode0_Init:
	LOAD    TestSimPattern
	OUT     sim_softsave

Mode0_CheckStatus:
	IN      sim_status
	AND     Bit0Mask
	JZERO   Mode0_Fail

Mode0_VerifyPattern:
	IN      bit_def
	SUB     TestSimPattern
	JNZ     Mode0_Fail
    
Mode0_VerifyInvertedPattern:
	LOAD    TestSimPattern
	OUT     sim_softsave
	IN      bit_inv
	AND     TestSimPattern
	JNZ     Mode0_Fail

Mode0_Pass:
	LOAD    HexD
	OUT     Hex1
	IN      Switches
	OUT     sim_snapsave
	JUMP    Mode1

Mode0_Fail:
	LOAD    HexE
	OUT     Hex1
	JUMP    Mode0_Fail
    
    
; Mode 1- Pre-Flight Checklist 
; Features used: pop_low
;1. Waits until all switches are flipped down and displays how many switches are left
;2. Displays 'C' (standing for Complete) when done
Mode1: 
	LOAD    Zero
	OUT     LEDs              

Mode1_Loop:
	IN      PopLow
	STORE   TempPop
	LOAD    Ten
	SUB     TempPop
	OUT     Hex0 
    JZERO   Mode1_Pass
	JUMP    Mode1_Loop
       
Mode1_Pass:

	LOAD    HexC                
	OUT     Hex1
	LOAD    TenBitMask
	OUT     LEDs 
	JUMP    Mode2_Loop

;Mode 2- Turbulence Bump Detection Mode
;Features used: change_num, change_mask
;If two switches are switched in this mode, display 'b' (for Bump) and light up the LEDs of the changed switches
Mode2_Loop:

    
	IN      ChangeNum
	STORE   TempChange
	
	LOAD    TempChange
	SUB     One
	JPOS    Mode2_Bump

    JUMP	Mode2_Loop



Mode2_Bump:
	LOAD    HexB               
	OUT     Hex1                
	IN      ChangeMask          
	OUT     LEDs
    JUMP	Mode3_Init
 
;Mode 3- Autopilot Override Mode
; Features used: pop_high, sim_softsave, password
;1. Waits until all switches are down
;2. Waits until switch inputs match pre-set password
;3. Loop back to mode 1 and display 'A' (For Autopilot)
Mode3_Init:
    
    LOAD    PasscodeKey
    OUT     sim_softsave        
    OUT     Password            
    IN      bit_def

Mode3_Pre_Loop:
	IN		PopHigh
    JNZ		Mode3_Pre_Loop

Mode3_Loop:
    OUT		LEDs
    IN      Password
    AND     Bit0Mask
    JNZ     Mode3_Match
    
    JUMP    Mode3_Loop

Mode3_Match:
    LOAD    HexA
    OUT     Hex1
    
    LOAD    Bit0Mask
    OUT     LEDs
    
    JUMP    Mode1
    





; VARIABLES & CONSTANTS

ORG 120

TempPop:        DW 0
TempChange:     DW 0

Zero:           DW 0
One:            DW 1
Ten:            DW 10
Bit0Mask:       DW &B0000000001
Key1Mask:       DW &B0000000010
TenBitMask:     DW &B1111111111


PasscodeKey:    DW &B1100110011       ; Preset Autopilot key
TestSimPattern: DW &B1010101010

Hex0Val:        DW &H0000
HexB:           DW &H000B
HexC:           DW &H000C
HexE:           DW &H000E
HexA:           DW &H000A
HexD:           DW &H000D

Switches:  		EQU 000
LEDs:      		EQU 001
Timer			EQU	002
Hex0:      		EQU 004
Hex1:      		EQU 005
bit_def:   		EQU 096
bit_inv: 		EQU 097
PopHigh:		EQU 098
PopLow:			EQU 099
ChangeMask:		EQU 100
ChangeNum:		EQU 101
Password:		EQU 102
sim_snapsave:	EQU 103
sim_softsave:	EQU 104
sim_status:		EQU 105
