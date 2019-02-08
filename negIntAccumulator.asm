TITLE Negative Integer Accumulator     (negIntAccumulator.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				8 February 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 3             Due Date: 10 February 2019
; Description:	This program prompts the user for their name and negative
;	integers from -100 to -1. The sum and average of all entered integers
;	is displayed.

INCLUDE Irvine32.inc

PGMR_NAME	EQU		<"Rebecca L. Taylor ", 0>		; Programmer name
INT_MIN = -100										; Lower limit

.data
user_num	SDWORD	?						; Number entered by user
count		SDWORD	0						; Count of nums entered by user
sum			SDWORD	0						; Sum of nums entered by user
avg			SDWORD	0						; Average of nums entered by user
line_num	DWORD	1						; To number lines during user input

auth_name	BYTE	PGMR_NAME				; Program author
user_name	BYTE	33 DUP(0)				; String to be entered by user

intro		BYTE	"Welcome to the Integer Accumulator by ", 0
ec_msg		BYTE	"**EC: Program numbers lines during user input ", 0
ask_name	BYTE	"What is your name? ", 0
greet		BYTE	"Hello, ", 0
instruct	BYTE	"Please enter numbers in  [-100, -1]. ", 0dh, 0ah
			BYTE	"Enter a non-negative number when you are finished to see results. ", 0
colon		BYTE	": ", 0
ask_num		BYTE	"Enter number: ", 0
err_msg		BYTE	"Number must be between -100 and -1.", 0
no_neg		BYTE	"You did not enter any negative numbers. ", 0
result_1	BYTE	"You entered ", 0
result_2	BYTE	" valid numbers. ", 0
sum_res		BYTE	"The sum of your valid numbers is ", 0
avg_res		BYTE	"The rounded average is ", 0
goodbye		BYTE	"Thank you for playing Integer Accumulator!  "
			BYTE	"It's been a pleasure to meet you, ", 0

.code
main PROC

;Introduction	
	mov		edx, OFFSET intro				; Title and programmer
	call	WriteString
	mov		edx, OFFSET auth_name
	call	WriteString
	call	CrLf

	mov		edx, OFFSET ec_msg				; Extra credit message
	call	WriteString
	call	CrLf
	call	CrLf

;User name and instructions
	mov		edx, OFFSET ask_name			; Get user name			
	call	WriteString
	mov		edx, OFFSET user_name
	mov		ecx, 32
	call	ReadString

	mov		edx, OFFSET greet				; Greet user
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET instruct			; Display instructions
	call	WriteString
	call	CrLf

;Get negative integers from user	
	get_num:
		mov		eax, line_num				; Number user input
		call	WriteDec
		inc		line_num
		mov		edx, OFFSET	colon
		call	WriteString

		mov		edx, OFFSET ask_num			; Get integer from user		
		call	WriteString
		call	ReadInt
		mov		user_num, eax
		jns		print_result				; Jump if sign flag not set
		
		mov		eax, INT_MIN				; Validate num <= -100
		cmp		eax, user_num
		jg		err
		
		jmp		accumulate					; If valid, accumulate nums

;Calculate sum and average
	accumulate:						
		inc		count						; Increment count of numbers

		mov		eax, sum					; Get sum of numbers
		add		eax, user_num
		mov		sum, eax
		
		mov		eax, sum					; Get average of numbers
		cdq
		mov		ebx, count
		idiv	ebx

		neg		edx							; Convert remainder to positive number
		add		edx, edx					; Check for rounding 
		cmp		edx, count
		jg		round_up
		mov		avg, eax
		jmp		get_num

	round_up:								; Round to next integer
		dec		eax
		mov		avg, eax
		jmp		get_num						

;Display results
	print_result:
		mov		eax, count					; Check if zero numbers
		cmp		eax, 0
		je		none
		
		mov		edx, OFFSET	result_1		; Else print number of integers
		call	WriteString
		mov		eax, count
		call	WriteDec
		mov		edx, OFFSET	result_2
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	sum_res			; Print sum result
		call	WriteString
		mov		eax, sum
		call	WriteInt
		call	CrLf

		mov		edx, OFFSET avg_res			; Print average result
		call	WriteString
		mov		eax, avg
		call	WriteInt
		call	CrLf

		jmp		done

;Exceptions messages
	err:									; If num not from -100..-1
		call	CrLf
		mov		edx, OFFSET err_msg
		call	WriteString
		call	CrLf
		jmp		get_num

	none:									; If no negative numbers entered
		call	CrLf
		mov		edx, OFFSET no_neg
		call	WriteString
		call	CrLf
		jmp		done

;Farewell
	done:									; Print goodbye message
		call	CrLf
		mov		edx, OFFSET goodbye
		call	WriteString
		mov		edx, OFFSET	user_name
		call	WriteString
		mov		al, '.'
		call	WriteChar
		call	CrLf

	exit									; exit to operating system
main ENDP

END main
