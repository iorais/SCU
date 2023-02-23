;******************** (C) Andrew Wolfe *******************************************
; @file    HW8 Problem 1
; @author  Andrew Wolfe
; @date    Nov 3, 2019

; @edited by Isaac Orais
; @date Nov 13, 2022
;*******************************************************************************

	
			AREA    main, CODE, READONLY
			EXPORT	__main				
			ENTRY			
				
__main	PROC
	
			ldr		r0, =array	; Pointer to array of string pointers
			ldr		r1, =10			; Number of items in array
			bl		mysort			; Call sorting routine
endless		b		endless

		ENDP

			
	

									;r0 = i, r1 = j
mysort		PROC
			;Put your code here
			
			push	{lr, r4}

			mov		r2, r0		; Pointer to array of string pointers
			mov		r0, #4
			mul		r3, r1, r0	; Address of the end of the array
			sub		r4, r3, #4	; Address of last string in array
			
			eor		r0, r0
			
loop1		add		r1, r0, #4
			
loop2		push	{r0, r1, r2, r3}
			add		r0, r2
			add		r1, r2
			bl		compare_and_swap
			pop		{r0, r1, r2, r3}
			
			add		r1, #4
			cmp		r1, r3
			blt		loop2

			add		r0, #4
			cmp		r0, r4
			bne		loop1 
			
			pop		{lr, r4}
			bx		lr
			ENDP

compare_and_swap	PROC			;r0 = address array[i], r1 = address array[j]
			;Put your code here
			push	{lr}
			
			ldr		r2, [r0]		;r2 = array[i]
			ldr		r3, [r1]		;r3 = array[j]

			cmp		r2, r3			;if array[i] > array [j]
			ble		ifend
			str		r3, [r0]		;swap(array[i], array[j])
			str		r2, [r1]

ifend	
			pop		{lr}
			bx		lr
			ENDP
						
			ALIGN
			AREA mydata, DATA, READONLY

				
array DCD 1,2,3,4,5,6,7,8,9,10
	

		END