TITLE Integer Accumulator     (Prog4.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				16 February 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 4             Due Date: 17 February 2019
; Description:	This program prompts the user for their name and an integer
;	from 1 to 400. It then calculates and displays the user-specified number
;	of composite numbers (i.e., non-prime numbers) with 10 numbers per line.

INCLUDE Irvine32.inc

PGMR_NAME	EQU		<"Rebecca L. Taylor", 0>		; Programmer name
INT_MIN = 1											; Range of allowed user input
INT_MAX = 400
MIN_COMPOSITE = 4									; First composite number
NUM_COLS = 10										; Number to display per row
TAB = 9												; ASCII tab character

.data
user_num	SDWORD	?						; Number entered by user	
comp_num	DWORD	4						; Store current composite number
div_num		DWORD	3						; Number to divide by to test composite 
num_count	DWORD	?						; Count how many numbers printed
col_count	DWORD	10						; Maintain number of columns
			
intro		BYTE	"Composite Numbers", TAB, "Programmed by ", PGMR_NAME, 0
instruct	BYTE	"Enter the number of composite numbers you would like to see. ", 0dh, 0ah
			BYTE	"I'll accept orders for up to 400 composites. ", 0
ec_msg		BYTE	"**EC: Output columns are aligned ", 0
ask_num		BYTE	"Enter the number of composites to display [1 .. 400]: ", 0
err_msg		BYTE	"Out of range.  Try again. ", 0
cert_by		BYTE	"Results certified by ", PGMR_NAME, ".  Goodbye. ", 0

.code
main PROC
	call	introduction					; introduce the program
	call	getUserData						; get num of composites to display
	call	showComposites					; show composites in user range
	call	farewell						; display goodbye message

	exit									; exit to operating system
main ENDP

;------------------------------------------------------------------------------
;Procedure to introduce the program
;receives: none
;returns: none
;preconditions: none
;registers changed: edx
;------------------------------------------------------------------------------
introduction PROC	
	mov		edx, OFFSET intro				; Title and programmer
	call	WriteString
	call	CrLf

	mov		edx, OFFSET ec_msg
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET instruct			; User instructions
	call	WriteString
	call	CrLf
	call	CrLf

	ret
introduction ENDP

;------------------------------------------------------------------------------
;Procedure to get user data
;receives: none
;returns: user integer for the number of composites to display
;preconditions: none
;registers changed: edx, eax
;------------------------------------------------------------------------------
getUserData PROC
	mov		edx, OFFSET ask_num				; Get integer from user		
	call	WriteString
	call	ReadDec
	mov		user_num, eax

	call	validate						; Check input within range

	ret
getUserData ENDP

;------------------------------------------------------------------------------
;Procedure to validate user data
;receives: user integer passed in from getUserData PROC in eax register
;returns: none
;preconditions: none
;registers changed: eax
;------------------------------------------------------------------------------
validate PROC								; Validate num >= 1 and <= 400
	mov		eax, INT_MIN					
	cmp		eax, user_num
	jg		err

	mov		eax, INT_MAX				
	cmp		eax, user_num
	jl		err

	jmp		done_validating

err:										; If user num out of range
	mov		edx, OFFSET err_msg
	call	WriteString
	call	CrLf
	call	getUserData

done_validating:
	ret
validate ENDP

;------------------------------------------------------------------------------
;Procedure to display composites
;receives: for this assignment user_num, comp_num, and count used as globals
;returns: none
;preconditions: user_num entered and validated
;registers changed: eax (including al)
;------------------------------------------------------------------------------
showComposites PROC
	call	CrLf
	mov		comp_num, MIN_COMPOSITE			; First composite num is 4

	mov		ecx, user_num
	display:									
		mov		eax, comp_num				; Check if isComposite returns 1 (T)	
		call	isComposite
		cmp		eax, 1				
		je		print_num
		inc		ecx							; Else do not count as printed num
		jmp		next_num

	print_num:								
		mov		eax, col_count				; Check num columns printed
		cmp		eax, 0
		je		new_row
		
		mov		eax, comp_num				; Print composite
		call	WriteDec
		mov		al, TAB
		call	WriteChar

		dec		col_count

	next_num:								; Get next composite num
		inc		comp_num
		loop	display
		jmp		stop_display

	new_row:								; New row and reset column counter
		call	CrLf
		mov		col_count, NUM_COLS
		jmp		print_num

	stop_display:
		call	CrLf
		call	CrLf

		ret
showComposites ENDP

;------------------------------------------------------------------------------
;Procedure to determine if number is composite
;receives: eax and ecx (loop counter) from showComposites procedure
;returns: eax (1 if is composite, else 0)
;preconditions: none
;registers changed: eax, ebx, ecx, edx
;------------------------------------------------------------------------------
isComposite PROC							
	push	ecx								; Save loop counter
	
	mov		eax, comp_num
	cmp		eax, MIN_COMPOSITE
	je		is_composite

	mov		div_num, 3					
	
division_test:								; Check in comp_num evenly divisible 
	mov		eax, comp_num		
	xor		edx, edx
	mov		ebx, div_num
	div		ebx

	cmp		edx, 0							; If no remainder, is composite
	je		is_composite				
	inc		div_num							; Else try dividing by next int
	
	mov		ecx, div_num					; If next int is num, is prime
	cmp		ecx, comp_num				
	je		is_prime
	
	jmp		division_test					; Else repeat division

is_composite:
	mov		eax, 1						
	jmp		finish_calc

is_prime:
	mov		eax, 0						

finish_calc:
	pop		ecx								; Restore loop counter
	ret									
isComposite ENDP

;------------------------------------------------------------------------------
;Procedure to display goodbye message
;receives: none
;returns: none
;preconditions: none
;registers changed: edx
;------------------------------------------------------------------------------
farewell PROC
	mov		edx, OFFSET cert_by				; Results certified by
	call	WriteString
	call	CrLf

	ret
farewell ENDP

END main
