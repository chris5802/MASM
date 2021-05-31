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

Remainder byte ?							;餘數
Quotient byte ?								;商

arr byte 0,0,0,0,0,0,0,0,0,0				;地圖陣列
arr_y byte 0,3,6,9,12,15,18,21,24,27		;地圖陣列之y座標紀錄
arr_x byte 0,0,0,0,0,0,0,0,0,0				;地圖陣列之x座標紀錄

top DWORD 0
bottom DWORD 9
FloorCount byte 2
CurrentFloor byte 2

DropSpeed EQU 100							;掉落速度
DropStartTime DWORD ?						;掉落起始時間
DropTimer DWORD ?							;Drop Timer

KeySpeed EQU 20								;鍵盤輸入速度
KeyStartTime DWORD ?						;鍵盤輸入起始時間
KeyTimer DWORD ?							;Key Timer

FloorSpeed EQU 1000							;上升速度
FloorStartTime DWORD ?						;上升起始時間
FloorTimer DWORD ?							;Floor Timer



InitialPos_X1 EQU 50						;角色1起始位置X
InitialPos_Y1 EQU 1							;角色1起始位置Y
CurrentPos_X1 BYTE InitialPos_X1			;角色1當前位置X
CurrentPos_Y1 BYTE InitialPos_Y1			;角色1當前位置Y
Player1 EQU 'A'
Score1 DWORD 0								;角色1分數

InitialPos_X2 EQU 60						;角色2起始位置X
InitialPos_Y2 EQU 1 						;角色2起始位置Y
CurrentPos_X2 BYTE InitialPos_X2			;角色2當前位置X
CurrentPos_Y2 BYTE InitialPos_Y2			;角色2當前位置Y
Player2 EQU 'B'
Score2 DWORD 0								;角色2分數

Wall EQU '|'				;牆壁
Floor EQU 'TTTTTTTTTT'
Empty EQU '          '		

Min_X EQU 30			
Max_X EQU 91			;地圖寬
Min_Y EQU 0	
Max_Y EQU 30			;地圖高

flag DWORD 0


.code	;this is the code area


main proc
	
	mov esi,0
	mov ecx,10
	call Randomize
	FloorInitial:
		mov eax , 6
        call RandomRange
        mov arr[esi] , al
		inc esi
		
	loop FloorInitial

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
	mov FloorStartTime,eax


	Drop:
		
		call ShowScore
		;計算掉落的timer
		INVOKE GetTickCount        ; get new tick count
		sub    eax,DropstartTime        ; get elapsed milliseconds
		mov DropTimer,eax		
		;計算鍵盤輸入的timer
		INVOKE GetTickCount        ; get new tick count
		sub eax,KeyStartTime
		mov KeyTimer,eax
		;計算地板輸入的timer
		INVOKE GetTickCount        ; get new tick count
		sub eax,FloorStartTime
		mov FloorTimer,eax


		.IF CurrentPos_Y1 > Max_Y && CurrentPos_Y2 >Max_Y
			jnl EndDrop				;跳出迴圈
		 .ENDIF
		.IF DropTimer>DropSpeed
			call ShowDrop
			INVOKE GetTickCount        ; get starting tick count
			mov    DropStartTime,eax        ; save it
		.ENDIF
		.IF KeyTimer>KeySpeed
			call key
			INVOKE GetTickCount        ; get starting tick count
			mov KeyStartTime,eax
		.ENDIF
		.IF FloorTimer>FloorSpeed
			call ShowFloor
			INVOKE GetTickCount        ; get starting tick count
			mov FloorStartTime,eax
		.ENDIF

		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite Player1
		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite Player2
		

		
		
		jmp Drop
		

	EndDrop:	
	
	call ShowEnd
	Invoke sleep,5000

	ret
ShowRole ENDP


;----------------------------------------
;					Floor						
;----------------------------------------
ShowFloor PROC USES eax
	
	mov esi,0
	mov eax,0
	mov al,FloorCount
	mov CurrentFloor,al
	
	EmptyLoop:							;擦去上一次樓梯的迴圈
		mov al,arr[esi]
		mov bl,10
		mul bl
		add al,31
		.IF FloorCount!=0 || esi !=0
			mGoto al,CurrentFloor
			mWrite Empty
		.ENDIF		
		add CurrentFloor,3
		inc esi
		
	.IF esi<10
		JMP EmptyLoop
	.ENDIF
	

	.IF FloorCount==0					;最上層的地板要超過天花板，陣列需要更新
		mov FloorCount,2	
		mov esi,0
		mov ecx,9
		L1:
			mov al,arr[esi+1]
			mov arr[esi],al
			inc esi
		Loop L1
		mov eax , 6 
        call RandomRange
		mov arr[9],al
        
	.ELSEIF
		dec FloorCount
	.ENDIF
	
	
	mov esi,0
	mov eax,0
	mov al,FloorCount
	mov CurrentFloor,al

	
	FloorLoop:							;畫樓梯的迴圈
		mov al,arr[esi]
		mov bl,10
		mul bl
		add al,31

		mov arr_x[esi],al
		mov ah,CurrentFloor
		mov arr_y[esi],ah

		.IF FloorCount!=0 || esi !=0
			mGoto al,CurrentFloor
			mWrite Floor
		.ENDIF
		add CurrentFloor,3
		inc esi

	.IF esi<10
		JMP FloorLoop
	.ENDIF

		ret
	ShowFloor EndP
;----------------------------------------
;					Drop						
;----------------------------------------
ShowDrop PROC USES eax
		;擦除上一個位置
		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite ' '	
		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite ' '	

		;--------------判斷player1掉落---------------
		
		
		

		
		
		;--------------判斷結束---------------

		inc CurrentPos_Y1
		inc CurrentPos_Y2
		
		
		mov eax,0
		mov flag,eax

		ret
	ShowDrop EndP
;----------------------------------------
;					畫出記分板						
;----------------------------------------
ShowScore PROC USES eax
		mGoTo 20,1
		mov eax,score1
		call WriteDec
		mGoTo 111,1
		mov eax,score2
		call WriteDec
		ret
	ShowScore EndP
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

	mov esi,0
	mov al,FloorCount
	mov CurrentFloor,al
	FloorLoop:
		mov al,arr[esi]
		mov bl,10
		mul bl
		add al,31
		mov arr_x[esi],al
		mov ah,CurrentFloor
		mov arr_y[esi],ah
		mGoto al,CurrentFloor
		mWrite Floor
		add CurrentFloor,3
		inc esi
	.IF esi<10
		JMP FloorLoop
	.ENDIF
	
	mov ecx,60
	mov al,31
	SpikeLoop:
		mGoTo al,0
		mWrite'V'
		inc al
	Loop SpikeLoop

	mGoTo 1,1
	mWrite 'player1 score:'
	mGoTo 93,1
	mWrite 'player2 score:'

		
	ret
ShowWall ENDP
;----------------------------------------
;					結束畫面						
;----------------------------------------
ShowEnd PROC	USES eax
	
	call Clrscr
	mov eax,score2
	mGoTo 55,15
	.IF score1>eax
		mWrite 'player1 WIN'
	.ELSEIF	score1<eax
		mWrite 'player1 WIN'
	.ELSEIF
		mWrite 'TIE'
	.ENDIF
		
	ret
ShowEnd ENDP

;----------------------------------------
;					輸入
;----------------------------------------
key proc
	mov ah,0
	
	INVOKE GetKeyState, 'A'   ;角色1左鍵
	mov bh, CurrentPos_Y2
	mov bl, CurrentPos_X2
	inc bl
	.IF ah && CurrentPos_X1 > 31 
		.IF CurrentPos_X1 == bl && CurrentPos_Y1 == bh && CurrentPos_X1>32
			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1新位置	
			mGoto CurrentPos_X2,CurrentPos_Y2						;消去player2本來的位置
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2
		.ELSEIF	CurrentPos_X1 != bl || CurrentPos_Y1 != bh
			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1新位置	
		.ENDIF
		
	.ENDIF

	INVOKE GetKeyState, 'D'    ;角色1右鍵
	mov bh, CurrentPos_Y2
	mov bl, CurrentPos_X2
	dec bl
	.IF ah && CurrentPos_X1 < 90 
		.IF CurrentPos_X1 == bl && CurrentPos_Y1 == bh && CurrentPos_X1<89
			mGoto CurrentPos_X1,CurrentPos_Y1    
			mWrite ' '
			inc CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1
			mGoto CurrentPos_X2,CurrentPos_Y2   
			mWrite ' '
			inc CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2
		.ELSEIF CurrentPos_X1 != bl || CurrentPos_Y1 != bh
			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			inc CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1
		.ENDIF
	.ENDIF

  INVOKE GetKeyState, VK_LEFT	;角色2左鍵
	mov bh, CurrentPos_Y1
	mov bl, CurrentPos_X1
	inc bl
	.IF ah && CurrentPos_X2 > 31
		.IF CurrentPos_X2 == bl && CurrentPos_Y2 == bh && CurrentPos_X2>32
			mGoto CurrentPos_X2, CurrentPos_Y2						;消去player2本來的位置
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2											;player2新位置
			mGoto CurrentPos_X1, CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1新位置
		.ELSEIF	CurrentPos_X2 != bl || CurrentPos_Y2 != bh
			mGoto CurrentPos_X2,CurrentPos_Y2						;消去player2本來的位置
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2											;player2新位置	
		.ENDIF

	.ENDIF

  INVOKE GetKeyState, VK_RIGHT	;角色2右鍵
	mov bl, CurrentPos_X1
	dec bl
	.IF ah && CurrentPos_X2 < 90 
		.IF CurrentPos_X2 == bl && CurrentPos_Y2 == bh && CurrentPos_X2<89
			mGoto CurrentPos_X2, CurrentPos_Y2      
			mWrite ' '
			inc CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2
			mGoto CurrentPos_X1, CurrentPos_Y1      
			mWrite ' '
			inc CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1
		.ELSEIF CurrentPos_X2 != bl || CurrentPos_Y2 != bh
			mGoto CurrentPos_X2, CurrentPos_Y2      
			mWrite ' '
			inc CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2
		.ENDIF
	.ENDIF 
	
	
	ret
key endp

end main