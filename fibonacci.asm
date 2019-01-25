TITLE Fibonacci Numbers     (fibonacci.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				21 January 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 2             Due Date: 27 January 2019
; Description:	This program prompts the user for their name and number of
; Fibonacci terms to display. The requested Fibonacci sequence is printed 


INCLUDE Irvine32.inc

PROG_NAME	EQU		<"Rebecca L. Taylor ", 0>	; Programmer name
INT_MIN = 1
INT_MAX = 46

.data
user_num	DWORD	?						; Number entered by user
prev_fib	DWORD	1						; Initialize Fibonacci sequence	
curr_fib	DWORD	0
term_cnt	DWORD	1						; Counter for terms per line
line_cnt	DWORD	1						; Counter for number of lines

auth_name	BYTE	PROG_NAME				; Program author
user_name	BYTE	33 DUP(0)				; String to be entered by user

intro		BYTE	"Fibonacci Numbers ", 0dh, 0ah
			BYTE	"Programmed by ", 0
ec_msg		BYTE	"**EC: Program displays the numbers in aligned columns. ", 0
ask_name	BYTE	"What's your name? ", 0
greet		BYTE	"Hello, ", 0
instruct	BYTE	"Enter the number of Fibonacci numbers to be displayed. ", 0dh, 0ah 
			BYTE	"Give the number as an integer in the range [1..46]. ", 0
ask_num		BYTE	"How many Fibonacci terms do you want? ", 0
err_msg		BYTE	"Out of range. Enter a number in [1..46] ", 0
cert_by		BYTE	"Results certified by ", 0
goodbye		BYTE	"Goodbye, ", 0

.code
main PROC

;Introduction	
	mov		edx, OFFSET intro
	call	WriteString
	mov		edx, OFFSET auth_name
	call	WriteString
	call	CrLf

	mov		edx, OFFSET ec_msg
	call	WriteString
	call	CrLf
	call	CrLf

;userInstructions
	mov		edx, OFFSET ask_name
	call	WriteString
	mov		edx, OFFSET user_name
	mov		ecx, 32
	call	ReadString

	mov		edx, OFFSET greet
	call	WriteString
	mov		edx, OFFSET	user_name
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instruct
	call	WriteString
	call	CrLf
	call	CrLf

;getUserData	
	get_num:
		mov		edx, OFFSET ask_num			; Get num of Fib nums from user
		call	WriteString
		call	ReadInt
		mov		user_num, eax
		call	CrLf

		mov		eax, INT_MAX				; Validate num 1..46
		cmp		eax, user_num
		jl		err
		mov		eax, INT_MIN
		cmp		eax, user_num
		jg		err
		jmp		fib_sequence

	err:									; If num not from 1..46
		mov		edx, OFFSET err_msg
		call	WriteString
		jmp		get_num

;displayFibs 
	fib_sequence:
		mov		ecx, user_num				; Loop counter
	
	display_fibs:
		mov		eax, curr_fib				; Calculate next Fib 
		mov		ebx, curr_fib				
		add		eax, prev_fib				
		mov		curr_fib, eax				
		mov		prev_fib, ebx				
		
		call	WriteDec					; Print next Fib 
		mov		al, 9						; ASCII tab code
		call	WriteChar
		cmp		line_cnt, 7					
		jg		count_terms

	add_tab:								; Align first seven columns
		mov		al, 9						
		call	WriteChar

	count_terms:							; Print five terms per line
		cmp		term_cnt, 5
		jge		print_line
		inc		term_cnt					
		loop	display_fibs				
		jmp		done						

	print_line:								; Print new line after five terms
		mov		term_cnt, 1					
		call	CrLf
		inc		line_cnt
		loop	display_fibs

;farewell
	done:
		call	CrLf
		call	CrLf
		mov		edx, OFFSET cert_by
		call	WriteString
		mov		edx, OFFSET auth_name
		call	WriteString
		call	CrLf

		mov		edx, OFFSET goodbye
		call	WriteString
		mov		edx, OFFSET	user_name
		call	WriteString
		call	CrLf

	exit									; exit to operating system
main ENDP

END main
