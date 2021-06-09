INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib
;
GetKeyState PROTO, nVirtkey:DWORD ;�P�_���䪬�p

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

VK_LEFT EQU 000000025h   ;����V��
VK_RIGHT EQU 000000027h  ;�k��V��

.data		;this is the data area

InitialPos_X1 EQU 50								;����1�_�l��mX
InitialPos_Y1 EQU 0								;����1�_�l��mY
CurrentPos_X1 BYTE InitialPos_X1			;����1��e��mX
CurrentPos_Y1 BYTE InitialPos_Y1			;����1��e��mY
Player1 EQU 'A'

InitialPos_X2 EQU 60								;����2�_�l��mX
InitialPos_Y2 EQU 0								;����2�_�l��mY
CurrentPos_X2 BYTE InitialPos_X2			;����2��e��mX
CurrentPos_Y2 BYTE InitialPos_Y2			;����2��e��mY
Player2 EQU 'B'

Wall EQU '|'				;���

Min_X EQU 30			
Max_X EQU 90			;�a�ϼe
Min_Y EQU 0	
Max_Y EQU 30			;�a�ϰ�




.code	;this is the code area


main proc

	call ShowWall
	call ShowRole
		
	Invoke ExitProcess,0	
main endp

;----------------------------------------
;					�e�X�H��						
;----------------------------------------
ShowRole  PROC	
	
	Drop:
				
		.IF CurrentPos_Y1 > Max_Y && CurrentPos_Y2 >Max_Y
			jnl EndDrop				;���X�j��
		 .ENDIF
		
		call key

		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite Player1

		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite Player2

		Invoke Sleep,500
		

		;�����W�@�Ӧ�m

		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite ' '	
		
		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite ' '	
		
		inc CurrentPos_Y1
		inc CurrentPos_Y2
		
		jmp Drop
		
	EndDrop:	
		
	ret
ShowRole ENDP

;----------------------------------------
;					�e�X���						
;----------------------------------------
ShowWall PROC	USES eax
	
	mov al,Min_Y
	WallLoop:
		
		cmp al,Max_Y		;eax < Max_Y?
		jnl EndWall				;���X�j��

		mGoTo Min_X,al
		mWrite Wall
		mGoTo Max_X,al
		mWrite Wall
		inc eax
		jmp WallLoop
	
	EndWall:
		
	ret
ShowWall ENDP

;----------------------------------------
;					��J
;----------------------------------------
key proc
	mov ah,0

	INVOKE GetKeyState, 'A'   ;����1����
	mov bl, CurrentPos_X2
	inc bl
	.IF ah && CurrentPos_X1 > 31 && CurrentPos_X1 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X1,CurrentPos_Y1    
		mov  al,' '     
		call WriteChar
		dec CurrentPos_X1
	.ENDIF

	INVOKE GetKeyState, 'D'    ;����1�k��
	mov bl, CurrentPos_X2
	dec bl
	.IF ah && CurrentPos_X1 < 89 && CurrentPos_X1 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X1,CurrentPos_Y1    
		mov  al,' '     
		call WriteChar
		inc CurrentPos_X1
	.ENDIF

  INVOKE GetKeyState, VK_LEFT	;����2����
	mov bl, CurrentPos_X1
	inc bl
	.IF ah && CurrentPos_X2 > 31 && CurrentPos_X2 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X2, CurrentPos_Y2       
		mov  al,' '     
		call WriteChar
		dec CurrentPos_X2
	.ENDIF

  INVOKE GetKeyState, VK_RIGHT	;����2�k��
	mov bl, CurrentPos_X1
	dec bl
	.IF ah && CurrentPos_X2 < 89 && CurrentPos_X2 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X2, CurrentPos_Y2      
		mov  al,' '     
		call WriteChar
		inc CurrentPos_X2
	.ENDIF 
	
	ret
key endp

end main