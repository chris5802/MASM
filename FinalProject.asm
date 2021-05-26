INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

GetKeyState PROTO, nVirtkey:DWORD ;判斷按鍵狀況

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

VK_LEFT EQU 000000025h   ;左方向鍵
VK_RIGHT EQU 000000027h  ;右方向鍵

.data		;this is the data area

DropSpeed EQU 300							;掉落速度
DropStartTime DWORD ?						;掉落起始時間
DropTimer DWORD ?								;Drop Timer

KeySpeed EQU 20								;鍵盤輸入速度
KeyStartTime DWORD ?							;鍵盤輸入起始時間
KeyTimer DWORD ?									;Key Timer

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

flag DWORD 0


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
	
	INVOKE GetTickCount       
    mov DropstartTime,eax       
	mov KeyStartTime,eax
	
   

	Drop:

		;計算掉落的timer
		INVOKE GetTickCount        ; get new tick count
		sub    eax,DropstartTime        ; get elapsed milliseconds
		mov DropTimer,eax		
		;計算鍵盤輸入的timer
		INVOKE GetTickCount        ; get new tick count
		sub eax,KeyStartTime
		mov KeyTimer,eax


		.IF CurrentPos_Y1 > Max_Y && CurrentPos_Y2 >Max_Y
			jnl EndDrop				;跳出迴圈
		 .ENDIF
		
		

		.IF KeyTimer>KeySpeed
			call key
			INVOKE GetTickCount        ; get starting tick count
			mov KeyStartTime,eax
		 .ENDIF

		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite Player1

		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite Player2
		

		.IF DropTimer>DropSpeed
			call ShowDrop
			INVOKE GetTickCount        ; get starting tick count
			mov    DropStartTime,eax        ; save it
		.ENDIF
		
		jmp Drop
		

	EndDrop:	
		
	ret
ShowRole ENDP
	
ShowDrop PROC USES eax
		;擦除上一個位置
		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite ' '	
		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite ' '	
		inc CurrentPos_Y1
		inc CurrentPos_Y2
		mov eax,0
		mov flag,eax

		ret
	ShowDrop EndP

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

;----------------------------------------
;					輸入
;----------------------------------------
key proc
	mov ah,0
	
	INVOKE GetKeyState, 'A'   ;角色1左鍵
	mov bh,CurrentPos_Y2
	mov bl, CurrentPos_X2
	inc bl
	.IF ah && CurrentPos_X1 > 31 && CurrentPos_X1 != bl
		;invoke Sleep, 15
		mGoto CurrentPos_X1,CurrentPos_Y1    
		mWrite ' '
		dec CurrentPos_X1
		mGoto CurrentPos_X1, CurrentPos_Y1
		mWrite Player1
	.ENDIF

	INVOKE GetKeyState, 'D'    ;角色1右鍵
	mov bl, CurrentPos_X2
	dec bl
	.IF ah && CurrentPos_X1 < 89 && CurrentPos_X1 != bl
		;invoke Sleep, 15
		mGoto CurrentPos_X1,CurrentPos_Y1    
		mWrite ' '
		inc CurrentPos_X1
		mGoto CurrentPos_X1, CurrentPos_Y1
		mWrite Player1
	.ENDIF

  INVOKE GetKeyState, VK_LEFT	;角色2左鍵
	mov bl, CurrentPos_X1
	inc bl
	.IF ah && CurrentPos_X2 > 31 && CurrentPos_X2 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X2, CurrentPos_Y2       
		mWrite ' '
		dec CurrentPos_X2
		mGoto CurrentPos_X2, CurrentPos_Y2
		mWrite Player2
	.ENDIF

  INVOKE GetKeyState, VK_RIGHT	;角色2右鍵
	mov bl, CurrentPos_X1
	dec bl
	.IF ah && CurrentPos_X2 < 89 && CurrentPos_X2 != bl
		invoke Sleep, 15
		mGoto CurrentPos_X2, CurrentPos_Y2      
		mWrite ' '
		inc CurrentPos_X2
		mGoto CurrentPos_X2, CurrentPos_Y2
		mWrite Player2
	.ENDIF 
	
	
	ret
key endp

end main