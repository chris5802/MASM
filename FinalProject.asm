INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

mGoTo MACRO indexX:REQ, indexY:REQ		;移動游標			
	PUSH edx
	MOV dl, indexX
	MOV dh, indexY
	call Gotoxy
	POP edx
ENDM

mWrite MACRO drawText:REQ			;劃出圖像
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

InitialPos_X1 EQU 50								;角色1起始位置X
InitialPos_Y1 EQU 0								;角色1起始位置Y
CurrentPos_X1 BYTE InitialPos_X1			;角色1當前位置X
CurrentPos_Y1 BYTE InitialPos_Y1			;角色1當前位置Y
Player1 EQU 'A'

InitialPos_X2 EQU 60								;角色2起始位置X
InitialPos_Y2 EQU 0								;角色2起始位置Y
CurrentPos_X2 BYTE InitialPos_X2			;角色2當前位置X
CurrentPos_Y2 BYTE InitialPos_Y2			;角色2當前位置Y
Player2 EQU 'B'

Wall EQU '|'				;牆壁

Min_X EQU 30			
Max_X EQU 90			;地圖寬
Min_Y EQU 0	
Max_Y EQU 30			;地圖高




.code	;this is the code area


main proc

	call ShowWall
	call ShowRole
	

	Invoke ExitProcess,0	
main endp

;----------------------------------------
;					畫出人物						
;----------------------------------------
ShowRole  PROC	
	
	

	Drop:

		
		
		.IF CurrentPos_Y1 > Max_Y && CurrentPos_Y2 >Max_Y
			jnl EndDrop				;跳出迴圈
		 .ENDIF

		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite Player1

		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite Player2

		Invoke Sleep,500
		

		;擦除上一個位置

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
;					畫出牆壁						
;----------------------------------------
ShowWall PROC	USES eax
	
	mov al,Min_Y
	WallLoop:
		
		cmp al,Max_Y		;eax < Max_Y?
		jnl EndWall				;跳出迴圈

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