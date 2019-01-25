TITLE Elementary Arithmetic     (arithmetic.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				18 January 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 1             Due Date: 20 January 2019
; Description:	This program prompts the user for two integers, verifies that
; the second is less than the first, performs simple arithmetic, and reports 
; the results. The program repeats until the user chooses to quit.

INCLUDE Irvine32.inc

.data
num_1		DWORD	?				; integers to be entered by user
num_2		DWORD	?		
add_res		DWORD	?				; addition result
sub_res		DWORD	?				; subtraction result
mul_res		DWORD	?				; multiplication result
div_res		DWORD	?				; division result
rem_res		DWORD	?				; division remainder result
float_res	REAL4	?				; division result as floating point

intro		BYTE	"	Elementary Arithmetic	by Rebecca L. Taylor ", 0
instruct	BYTE	"Enter 2 numbers, and I'll show you the sum, difference, "
			BYTE	"product, quotient, and remainder." , 0
prompt_1	BYTE	"First number: ", 0
prompt_2	BYTE	"Second number: ", 0
error		BYTE	"The second number must be less than the first! ", 0
ask_quit	BYTE	"Enter 'q' to quit the program. Enter any other key to repeat. ", 0

plus		BYTE	" + ", 0
minus		BYTE	" - ", 0
times		BYTE	" x ", 0
div_by		BYTE	" ", 246, " ", 0	; ASCII 246 for obelus
remainder	BYTE	" remainder ", 0
equals		BYTE	" = ", 0

end_prog	BYTE	?					; User input to end program
goodbye		BYTE	"Impressed?  Bye! ", 0

.code
main PROC

;Introduce programmer and program			
repeat_prog:							; Allow program to repeat
	call	CrLf
	mov		edx, OFFSET intro			; Program title and programmer
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET instruct		; User instructions
	call	WriteString
	call	CrLf
	call	CrLf

;Get two numbers from user
	mov		edx, OFFSET prompt_1		; Get first number
	call	WriteString
	call	ReadInt
	mov		num_1, eax

	mov		edx, OFFSET prompt_2		; Get second number
	call	WriteString
	call	ReadInt
	mov		num_2, eax
	call	CrLf

	mov		eax, num_1					; Verify num_2 < num_1
	cmp		eax, num_2
	jl		err

;Calculate the required values
	mov		eax, num_1					; Calculate addition
	mov		ebx, num_2
	add		eax, ebx
	mov		add_res, eax

	mov		eax, num_1					; Calculate subtraction
	mov		ebx, num_2
	sub		eax, ebx
	mov		sub_res, eax

	mov		eax, num_1					; Calculate product
	mov		ebx, num_2
	mul		ebx
	mov		mul_res, eax

	mov		edx, 0						; Calculate quotient and remainder
	mov		eax, num_1					
	mov		ebx, num_2
	div		ebx
	mov		div_res, eax
	mov		rem_res, edx

	fild	num_1						; Calculate quotient as floating point
	fild	num_2
	fdiv	ST(1), ST(0)
	fstp	ST(0)						; Pop divisor at ST(0), ST(0) now holds result
	fstp	float_res
	call	CrLf

;Report results
	mov		eax, num_1					; Report addition result
	call	WriteDec
	mov		edx, OFFSET plus			
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, add_res
	call	WriteDec
	call	CrLf

	mov		eax, num_1					; Report subtraction result
	call	WriteDec
	mov		edx, OFFSET minus			
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, sub_res
	call	WriteDec
	call	CrLf

	mov		eax, num_1					; Report multiplication result
	call	WriteDec
	mov		edx, OFFSET times			
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, mul_res
	call	WriteDec
	call	CrLf

	mov		eax, num_1					; Report division result
	call	WriteDec
	mov		edx, OFFSET div_by			
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, div_res
	call	WriteDec
	mov		edx, OFFSET remainder
	call	WriteString
	mov		eax, rem_res
	call	WriteDec
	call	CrLf

	mov		eax, num_1					; Report floating point result
	call	WriteDec
	mov		edx, OFFSET div_by			
	call	WriteString
	mov		eax, num_2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	fld		float_res					
	call	WriteFloat					
	call	CrLf

	jmp		done						; Jump over error message

err:									; If num_2 not less than num_1
	mov		edx, OFFSET error
	call	WriteString
	call	CrLf

done:									; Ask user to repeat program
	call	CrLf
	mov		edx, OFFSET ask_quit
	call	WriteString
	call	ReadChar
	mov		end_prog, al				
	cmp		end_prog, "q"				; If end program set to q (quit)
	jne		repeat_prog

;Say "Goodbye"
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf

	exit								; exit to operating system
main ENDP

END main
