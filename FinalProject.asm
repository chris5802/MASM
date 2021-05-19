INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

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


end main