TITLE Random Integer Sort     (Prog5.asm)

; Author:						Rebecca L. Taylor
; Last Modified:				3 March 2019
; OSU email address:			tayloreb@oregonstate.edu
; Course number/section:		CS271-400
; Project Number: 5             Due Date: 3 March 2019
; Description:	This program gets and validates a user request for number of 
;	random numbers to generate (from 10 to 200). An array is generated, filled 
;	with the requested number of random integers from 100 to 999, and sorted in
;	descdending order (greatest to least). The median and sorted array are displayed.

INCLUDE Irvine32.inc

MIN = 10											; Range of allowed user input
MAX = 200
LO = 100											; Range of random nums generated
HI = 999

TAB = 9												; ASCII tab character
NUM_COLS = 10										; Number of columns

.data
request		SDWORD	?								; Number entered by user	
array		DWORD	200	DUP(?)						; Empty array of MAX capacity

intro		BYTE	"Sorting Random Integers		Programmed by Rebecca L. Taylor", 0
instruct	BYTE	"This program generates random numbers in the range [100..999], "
			BYTE	"displays the original list, sorts the list, and calculates the median value. " 
			BYTE	"Finally, it displays the list sorted in descending order. ", 0
ask_num		BYTE	"How many numbers should be generated? [10..200]: ", 0
err_msg		BYTE	"Invalid input ", 0
unsorted	BYTE	"The unsorted random numbers: ", 0
sorted		BYTE	"The sorted list: ", 0
median		BYTE	"The median is ", 0

.code
main PROC
	call	Randomize						; Seed random function

	push	OFFSET intro					; Introduce the program
	push	OFFSET instruct					
	call	introduction					

	push	OFFSET err_msg					; Get and validate user request
	push	OFFSET ask_num					
	push	OFFSET request					
	call	getData							

	push	OFFSET array					; Generate requested random ints
	push	request							
	call	fillArray						

	push	OFFSET array					; Display unsorted array
	push	request							
	push	OFFSET unsorted					
	call	displayList						

	push	OFFSET array					; Sort the array
	push	request							
	call	sortList						

	push	OFFSET median					; Calculate and dispaly median
	push	OFFSET array					
	push	request							
	call	displayMedian					

	push	OFFSET array					; Display sorted array
	push	request							
	push	OFFSET sorted					
	call	displayList						

	exit									; exit to operating system
main ENDP

;------------------------------------------------------------------------------
;Procedure to introduce the program
;receives: intro and instruct messages
;returns: none
;preconditions: none
;registers changed: ebp, edx
;------------------------------------------------------------------------------
introduction PROC	
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		edx, [ebp+12]					; Intro w/ title and program info
	call	WriteString
	call	CrLf

	mov		edx, [ebp+8]					; User instructions
	call	WriteString
	call	CrLf
	call	CrLf

	pop		ebp
	ret		8								; Clean 2 params from stack

introduction ENDP

;------------------------------------------------------------------------------
;Procedure to get user data and validate range (Resource: demo5.asm)
;receives: user prompt msg, err msg, request variable passed by reference
;returns: user input in address of request variable
;preconditions: none
;registers changed: ebp, edx, eax, ebx
;------------------------------------------------------------------------------
getData PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp
	
get_num:
	mov		edx, [ebp+12]					; Msg to get int from user		
	call	WriteString
	
	call	ReadInt							; Check entered value in range
	cmp		eax, MAX						
	jg		range_error
	cmp		eax, MIN
	jl		range_error
	
	mov		ebx, [ebp+8]					; If in range move int to address of request var
	mov		[ebx], eax	
	jmp		valid_num

range_error:								; Get new int if out of range
	mov		edx, [ebp+16];
	call	WriteString
	call	CrLf
	jmp		get_num
	
valid_num:
	pop		ebp
	ret		12								; Clean up 3 params from stack

getData ENDP

;------------------------------------------------------------------------------
;Procedure to fill array with user-specified number of random integers
;(Resources: Irvine Chapter 8.2.6, demo5.asm, Lecture #20)
;receives: array index 0 passed by reference, request var passed by value
;returns: filled array starting at index passed by reference 
;preconditions: verified user request, existing array
;registers changed: ebp, ecx, edi, eax
;------------------------------------------------------------------------------
fillArray PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		ecx, [ebp+8]					; User request as loop counter
	mov		edi, [ebp+12]					; array[0] as starting destination index

fill_index:
	mov		eax, HI							; Get random int between HI and LO
	sub		eax, LO
	inc		eax
	call	RandomRange
	add		eax, LO							

	mov		[edi], eax						; Move rand int to array index
	add		edi, 4							; Increment array index
	loop	fill_index

end_fill:
	pop		ebp
	ret		8								; Clean up 2 params from stack
fillArray ENDP

;------------------------------------------------------------------------------
;Procedure to sort an array of integers in descending order
;(Resource: Irvine Chapter 9.5.1 Bubble Sort)
;receives: array index 0 passed by reference, request var passed by value
;returns: sorted array with values changed by reference
;preconditions: verified user request, existing array with unsorted values
;registers changed: ebp, eax, ecx, edx, edi, esi
;------------------------------------------------------------------------------
sortList PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		ecx, [ebp + 8]					; User request-1 as loop counter
	dec		ecx								

outer_loop:
	push	ecx								; Save outer loop count
	mov		esi, [ebp + 12]					; Array index 0
	mov		edx, 0							; Index address counter 

inner_loop:									
	mov		eax, [esi]						; Compare pair of elements
	cmp		[esi + 4], eax					
	jle		next_element
				
	exchange_elements:
	pushad									
	mov		esi, [ebp+12]					; Get array[i]
	add		esi, edx			

	mov		edi, [ebp+12]					; Get array[i+1]
	add		edi, edx			
	add		edi, 4
	
	push	esi								; Exchange array[i] and array[i+1]
	push	edi								
	call	exchangeElems
	popad									

	next_element:
	add		esi, 4							
	add		edx, 4			
	loop	inner_loop

	pop		ecx								; Restore outer loop count
	loop	outer_loop

end_sort:
	pop		ebp
	ret		8								; Clean up 2 params from stack

sortList ENDP

;------------------------------------------------------------------------------
;Procedure to swap two array elements
;receives: array[i] (passed by reference), array[j] (passed by reference)
;returns: exchanged values in array[i] and array[j]
;preconditions: addresses of two values passed by reference
;registers changed: ebp, eax, ebx, esi, edi
;------------------------------------------------------------------------------
exchangeElems PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		esi, [ebp + 12]					; Address of array[i]
	mov		edi, [ebp + 8]					; Address of array[j]

	mov		eax, [esi]						; Value of array[i]
	mov		ebx, [edi]						; Value of array[j]
	
	mov		[edi], eax						; Swap values
	mov		[esi], ebx
	
end_exchange:
	pop		ebp
	ret		8								; Clean up 2 params from stack

exchangeElems ENDP

;------------------------------------------------------------------------------
;Procedure to display the median (middle) value of an array
;receives: array index 0 passed by reference, request var passed by value,
;		   msg indicating median will be displayed
;returns: none
;preconditions: array must be sorted 
;registers changed: ebp, eax (including al), ebx, edx, esi
;------------------------------------------------------------------------------
displayMedian PROC
	push	ebp								; Initialize stack frame
	mov		ebp, esp

	mov		edx, [ebp+16]					; Median message
	call	CrLf
	call	CrLf
	call	WriteString

	mov		esi, [ebp+12]					; Starting array index
	mov		eax, [ebp + 8]					; User request
	cdq										; Modulus 2 to check even or odd
	mov		ebx, 2							
	div		ebx
	cmp		edx, 0							; If remainder is 0
	je		calculate_even

calculate_odd:								; Median at middle array index
	mov		ebx, [esi + eax * 4]			
	mov		eax, ebx
	call	WriteDec
	jmp		end_display

calculate_even:								; Median is average of two middle indices
	dec		eax								; Get lower middle index
	mov		ebx, [esi + eax * 4]
	inc		eax								; Get higher middle index
	mov		ecx, [esi + eax * 4]
	
	mov		eax, ebx						; Get rounded average
	add		eax, ecx
	mov		ebx, 2
	div		ebx
	call	WriteDec

end_display:
	mov		al, '.'
	call	WriteChar

	pop		ebp
	ret		12								; Clean up 3 params from stack

displayMedian ENDP

;------------------------------------------------------------------------------
;Procedure to display the elements of an array
;receives: array index 0 passed by reference, msg to display if array sorted or unsorted
;returns: none
;preconditions: array created and filled in memory
;registers changed: ebp, esp, eax (incl. al), ecx, edx, esi
;------------------------------------------------------------------------------
displayList PROC							; Initialize stack frame
	push	ebp
	mov		ebp, esp
	
	sub		esp, 4							; Create local var for column count
	mov		DWORD PTR [ebp-4], 0

	mov		edx, [ebp+8]					; Title string (sorted or unsorted)
	call	CrLf
	call	CrLf
	call	WriteString
	call	CrLf

	mov		ecx, [ebp+12]					; User request as loop counter
	mov		esi, [ebp+16]					; Index 0 to source index

print_num:
	mov		eax, [esi]						; Print element at current index
	call	WriteDec
	mov		al, TAB						
	call	WriteChar

	inc		DWORD PTR [ebp-4]				; Inc column count and check for new row
	mov		eax, DWORD PTR [ebp-4]
	cmp		eax, NUM_COLS
	jge		new_row

next_num:
	add		esi, 4							; Move to next index
	loop	print_num
	jmp		end_display

new_row:									; Print new line and inc col count
	call	CrLf							
	mov		DWORD PTR [ebp-4], 0
	jmp		next_num

end_display:
	mov		esp, ebp						; Remove local var from stack
	pop		ebp
	ret		12								; Clean up 3 params from stack

displayList ENDP

END main
