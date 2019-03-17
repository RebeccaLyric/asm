TITLE Low-level I/O	Procedures (lowLevel-IO.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				17 March 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 6A            Due Date: 17 March 2019
; Description:	This program get 10 unsigned 32-bit integers from the user, 
;	stores the values in an array, then displays the integers, their sum,
;	and average. It demonstrates low-level conversion of string input to 
;	numeric values and vice-versa.

INCLUDE Irvine32.inc

NUM_INPUT = 10										; Number of user-provided ints
DIGIT_CONVERT = 10									; Convert between decimal places
DIGIT_MIN = 48										; Digits 0..9 are ASCII 48..57
DIGIT_MAX = 57

displayString MACRO string_offset					; Macro to print a string						
	push	edx
	mov		edx, string_offset
	call	WriteString
	pop		edx
ENDM

getString MACRO storage, length						; Macro to store user input
	push	ecx
	push	edx										
	
	mov		edx, storage
	mov		ecx, length
	call	ReadString								
	
	pop		edx
	pop		ecx
ENDM

.data	
array		DWORD	10 DUP(?)						; Empty array of 10 elements
string		BYTE	255 DUP(0)						; Reserve (2^8)-1 bytes for string storage
sum_res		DWORD	?								; Sum calculation result

intro		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures ", 0Ah, 0Dh
			BYTE	"Written by: Rebecca L. Taylor", 0Ah, 0Dh, 0Ah, 0Dh 
			BYTE	"Please provide 10 unsigned decimal integers. ", 0Ah, 0Dh
			BYTE	"Each number needs to be small enough to fit inside a 32-bit register. ", 0Ah, 0Dh 
			BYTE	"After you have finished inputting the raw numbers I will display a list ", 0Ah, 0Dh
			BYTE	"of the integers, their sum, and their average value.", 0Ah, 0Dh, 0
ask_num		BYTE	"Please enter an unsigned number: ", 0
err_msg		BYTE	"ERROR: You did not enter an unsigned integer or your number was too big. ", 0Ah, 0Dh
			BYTE	"Please try again: ", 0
display		BYTE	"You entered the following numbers: ", 0
sum_msg		BYTE	"The sum of these numbers is: ", 0
avg_msg		BYTE	"The average is: ", 0
goodbye		BYTE	0Ah, 0Dh, "Thanks for playing! ", 0

.code
main PROC
	
	displayString OFFSET intro				; Introduce program				
	call	CrLf
	
	push	OFFSET array					; Get user inputs
	push	OFFSET ask_num
	push	OFFSET err_msg
	push	OFFSET string
	push	SIZEOF string
	call	getNums

	push	OFFSET string					; Display array of user nums
	push	OFFSET array												
	push	OFFSET display					
	call	displayList		

	push	OFFSET sum_msg					; Calculate and display sum
	push	OFFSET array
	push	OFFSET sum_res
	push	OFFSET string
	call	calculateSum
				
	push	OFFSET avg_msg					; Calculate and display average
	push	sum_res
	push	OFFSET string
	call	calculateAvg

	displayString OFFSET goodbye			; Display farewell
	call	CrLf

	exit									; exit to operating system
main ENDP

;------------------------------------------------------------------------------
;Procedure to get 10 unsigned 32-bit numbers from user
;receives: Message strings passed by reference (ask_num and err_msg)
;		   String storage passed by reference, array index passed by reference
;		   Size of string buffer passed by value
;returns:  Array filled with values entered by user
;preconditions: None
;registers changed: ebp, eax, ecx, edi
;------------------------------------------------------------------------------
getNums PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp					

	mov		ecx, NUM_INPUT					; Num inputs as loop counter
	mov		edi, [ebp+24]					; array[0] 

get_next:						
	displayString [ebp+20]					; Ask num message		

	push	[ebp+16]						; Error message
	push	[ebp+12]						; String storage 				
	push	[ebp+8]							; SIZEOF string
	call	ReadVal
	
	mov		[edi], eax						; Fill array with values returned in eax
	add		edi, 4							
	loop	get_next

have_nums:
	pop		ebp
	ret		20								; Clean up 5 params from stack

getNums ENDP

;------------------------------------------------------------------------------
;Procedure to display the elements of an array
;receives: String storage passed by reference, array index passed by reference
;		   Message stating the array will be displayed
;returns: none
;preconditions: Array created and filled exists in memory
;registers changed: ebp, eax (incl. al), ecx, esi
;------------------------------------------------------------------------------
displayList PROC							
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	call	CrLf
	displayString [ebp+8]					; Display message
	call	CrLf

	mov		ecx, NUM_INPUT					; Number of ints as loop counter
	mov		esi, [ebp+12]					; array[0] as source index

print_num:									
	mov		eax, [esi]						
	
	push	[ebp+16]						; String storage 
	push	eax				
	call	WriteVal

	cmp		ecx, 1							; If last number don't print comma
	je		end_display
	mov		al, ','							; Else print comma and space			
	call	WriteChar
	mov		al, ' '					
	call	WriteChar

next_num:
	add		esi, 4							; Move to next index
	loop	print_num
	jmp		end_display

end_display:
	call	CrLf
	pop		ebp
	ret		12								; Clean up 3 params from stack

displayList ENDP

;------------------------------------------------------------------------------
;Procedure to sum an array
;receives: Message string stating the sum will be displayed
;		   String storage passed by reference, array index passed by reference
;		   Sum result variable passed by reference
;returns:  Sum result passed in sum result variable
;preconditions: Array created and filled exists in memory
;registers changed: ebp, eax, ebx, ecx, esi
;------------------------------------------------------------------------------
calculateSum PROC	
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		esi, [ebp+16]					; array[0]
	mov		ecx, NUM_INPUT					; Array length - 1 as loop counter
	dec		ecx

	displayString [ebp+20]					; Sum message
	mov		eax, [esi]

add_sum:									; Accumulate sum in eax					
	add		eax, [esi+4]
	add		esi, 4
	loop	add_sum

	mov		ebx, [ebp+12]					; Move result to sum result var
	mov		[ebx], eax	
						
print_sum:
	push	[ebp+8]							; String offset
	push	eax
	call	WriteVal
	
finish_calc:
	call	CrLf
	pop		ebp
	ret		16								; Clean 4 params from stack

calculateSum ENDP

;------------------------------------------------------------------------------
;Procedure to find the truncated average for the given number of array elements
;receives: Message string stating the average will be displayed
;		   String storage passed by reference, sum result passed by value
;returns:  None
;preconditions: Array created and filled exists in memory
;registers changed: ebp, eax, ebx, ecx, esi
;------------------------------------------------------------------------------
calculateAvg PROC	
	push	ebp								; Initialize stack frame
	mov		ebp, esp

get_avg:
	displayString [ebp+16]					; Average message 
	mov		edx, 0
	mov		eax, [ebp+12]															
	mov		ebx, NUM_INPUT
	div		ebx

print_avg:
	push	[ebp+8]							; String offset
	push	eax
	call	WriteVal
	call	CrLf
	
finish_calc:
	pop		ebp
	ret		12								; Clean 3 params from stack

calculateAvg ENDP

;------------------------------------------------------------------------------
;Procedure to convert a string to unsigned integer, including validation
;receives: Message string stating the input contained an error
;		   String storage passed by reference, string size passed by value
;returns: Converted unsigned integer in eax
;preconditions: None
;registers changed: ebp, eax (incl. al), ebx, ecx, edx, esi
;------------------------------------------------------------------------------
readVal PROC
	LOCAL	result:DWORD, ten:DWORD
	mov		ten, DIGIT_CONVERT
	pushad

get_string:									
	mov			edx, [ebp+12]				; String storage
	mov			ecx, [ebp+8]				; Size of string
	getString	edx, ecx					; Set user input in edx as source index
	mov			esi, edx					

	mov		result, 0						; Set local result accumulator to 0
	mov		eax, 0							; Accumulate converted val of each digit
	mov		ebx, 1							; Multipler for each digit position 
	mov		ecx, 0							; Loop counter for each char (digit) input by user

find_length:								; Set length of user input as ecx loop counter
	cld
	lodsb									
	cmp		al, 0							; If reach null terminator begin read string
	je		read_string
	inc		ecx
	jmp		find_length

read_string:								; Point to last char of string and read backwards
	mov		esi, [ebp+12]					 
	add		esi, ecx						 
	dec		esi
	std										

read_byte:
	lodsb									
	cmp		al, DIGIT_MIN					; Check if digit 0..9
	jb		not_valid
	cmp		al, DIGIT_MAX
	ja		not_valid
	jmp		is_digit

not_valid:
	displayString [ebp+16]					; Error message 
	jmp		get_string
		
is_digit:
	sub		al, DIGIT_MIN					; Convert ASCII char to int and multiply by digit position 
	movzx	eax, al							
	mul		ebx								 
	add		result, eax
	jc		not_valid						; Check for carry out of 32-bit range

	mov		eax, ebx						; Multiply ebx * 10 for next digit
	mul		ten
	mov		ebx, eax

	loop	read_byte						; Read next byte of string
	
end_convert:
	popad
	mov		eax, result						; Return converted int in EAX
	ret		12								; Clean up 3 params from stack

readVal ENDP

;------------------------------------------------------------------------------
;Procedure to convert an unsigned integer to a string and print to the screen
;receives: Unsigned int in eax
;		   String storage passed by reference
;returns: None
;preconditions: None
;registers changed: ebp, eax, ebx, edx, edi
;------------------------------------------------------------------------------
writeVal PROC							
	push	ebp								; Initialize stack frame
	mov		ebp, esp
	pushad

	mov		eax, [ebp+8]					; Passed-in int 
	mov		edi, [ebp+12]					; String storage
	mov		ebx, DIGIT_CONVERT				; Set 10 as divisor
	push	0								; Null terminate string

read_digits:								; Push each digit onto stack
	mov		edx, 0										
	div		ebx
	add		edx, DIGIT_MIN					; Remainder in EDX is next digit, convert to ASCII
	push	edx								
	cmp		eax, 0							; Check for null terminator
	jne		read_digits

save_string:								; Move each digit to edi
	pop		[edi]							
	mov		eax, [edi]						 
	inc		edi								
	cmp		eax, 0							; Check for null terminator
	jne		save_string

print_string:
	displayString [ebp+12]

val_written:
	popad
	pop		ebp
	ret		8								; Clean up 2 params from stack

writeVal ENDP

END main
