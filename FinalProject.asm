INCLUDE Irvine32.inc

mGoTo MACRO indexX:REQ, indexY:REQ		;���ʴ��			
	PUSH edx
	MOV dl, indexX
	MOV dh, indexY
	call Gotoxy
	POP edx
ENDM

mWrite MACRO drawText:REQ			;���X�Ϲ�
	LOCAL string
	.data
		string BYTE drawText, 0
	.code
		PUSH edx
		MOV edx, OFFSET string
		call WriteString
		POP edx
ENDM

.data		;this is the data area

InitialPos_X EQU 30
InitialPos_Y EQU 0
CurrentPos_X BYTE InitialPOS_X 
CurrentPos_Y BYTE InitialPOS_Y
Role EQU 'P'

Left_Wall EQU '|'		;���-�����
Right_Wall EQU '|'		;���-�k���

Min_X EQU 0				
Max_X EQU 60			;�a�ϼe
Min_Y EQU 0	
Max_Y EQU 100			;�a�ϰ�




.code	;this is the code area


main proc
	
	call ShowRole
	

	Invoke ExitProcess,0	
main endp

ShowRole PROC	USES eax

	mov al,CurrentPos_Y
	Drop:
		
		cmp al,Max_Y		;eax < Max_Y?
		jnl EndDrop				;���X�j��

		mGoTo CurrentPos_X,al
		mWrite Role
		push eax
		mov eax,500

		call Delay
		pop eax
		mGoTo CurrentPos_X,al
		mWrite ' '
		inc eax
		jmp Drop
		

	EndDrop:
		mov CurrentPos_Y,al
		
	ret
ShowRole ENDP

	


end main