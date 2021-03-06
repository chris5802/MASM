INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib
INCLUDELIB Winmm.lib


GetKeyState PROTO, nVirtkey:DWORD ;判斷按鍵狀況
PlaySound PROTO, pszSound:PTR BYTE, hmod : DWORD, fdwSound : DWORD

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



arr byte 0,0,0,0,0,0,0,0,0,0				;地圖陣列
arr_y byte 0,3,6,9,12,15,18,21,24,27		;地圖陣列之y座標紀錄
arr_x byte 0,0,0,0,0,0,0,0,0,0				;地圖陣列之x座標紀錄
arr_type byte 0,0,0,0,0,0,0,0,0,0			;0:一般地板 1:Sham 2:尖刺 3:滾動
lg_type byte 0,0,0,0,0,0,0,0,0,0

top DWORD 0
bottom DWORD 9
FloorCount byte 2
CurrentFloor byte 2

DropSpeed EQU 200							;掉落速度
DropStartTime DWORD ?						;掉落起始時間
DropTimer DWORD ?							;Drop Timer

KeySpeed EQU 40								;鍵盤輸入速度
KeyStartTime DWORD ?						;鍵盤輸入起始時間
KeyTimer DWORD ?							;Key Timer

FloorSpeed EQU 500							;上升速度
FloorStartTime DWORD ?						;上升起始時間
FloorTimer DWORD ?							;Floor Timer

StateSpeed EQU 10							;player狀態刷新速度
StateStartTime DWORD ?						;狀態刷新起始時間
StateTimer DWORD ?							;State Timer

InitialPos_X1 EQU 50						;角色1起始位置X
InitialPos_Y1 EQU 1							;角色1起始位置Y
CurrentPos_X1 BYTE InitialPos_X1			;角色1當前位置X
CurrentPos_Y1 BYTE InitialPos_Y1			;角色1當前位置Y
Player1 EQU 'W'
Score1 DWORD 0								;角色1分數

InitialPos_X2 EQU 60						;角色2起始位置X
InitialPos_Y2 EQU 1 						;角色2起始位置Y
CurrentPos_X2 BYTE InitialPos_X2			;角色2當前位置X
CurrentPos_Y2 BYTE InitialPos_Y2			;角色2當前位置Y
Player2 EQU 'U'
Score2 DWORD 0								;角色2分數

Wall EQU ' '				;牆壁
Floor EQU 'TTTTTTTTTT'		;■■■■
Sham  EQU 'HHHHHHHHHH'		;踩到一秒後掉落
Spike EQU 'AAAAAAAAAA'		;踩到後死亡
RollRight_1 EQU '->->->->->'
RollRight_2 EQU '>->->->->-'
RollLeft_1 EQU '-<-<-<-<-<'
RollLeft_2 EQU '<-<-<-<-<-'
RollState Byte 0
decision Byte 0

Empty EQU '          '		

Min_X EQU 30			
Max_X EQU 91			;地圖寬
Min_Y EQU 0	
Max_Y EQU 30			;地圖高

flag DWORD 0
State1 BYTE 0          ; 0:不在樓梯上，1:在樓梯上，2:死掉，3:跌在其他人身上
State2 BYTE 0
Floor_type1 byte ?		;0:一般地板 1:sham 2:spikes 3:roll
Floor_type2 byte ?

SND_ALIAS    DWORD 00010000h
SND_RESOURCE DWORD 00040005h
SND_FILENAME DWORD 00020001h    ;同步: 20001h, 不同步: 20000h


FILE_GAME BYTE "3.wav",0 ;音樂檔名 
FILE BYTE "12.wav",0 

Win_P1 EQU '00000000 '
Win_P2 EQU '00     00'
Win_P3 EQU '00     00'
Win_P4 EQU '00000000 '
Win_P5 EQU '00       '
Win_P6 EQU '00       '
Win_P7 EQU '00       '

Win_L1 EQU '00        '
Win_L2 EQU '00        '
Win_L3 EQU '00        '
Win_L4 EQU '00	      '
Win_L5 EQU '00	      '
Win_L6 EQU '00        '
Win_L7 EQU '0000000000'

Win_A1 EQU '      00' 
Win_A2 EQU '     0000'
Win_A3 EQU '    00  00'
Win_A4 EQU '   00    00'
Win_A5 EQU '  0000000000'
Win_A6 EQU ' 00        00'
Win_A7 EQU '00          00'

Win_Y1 EQU '00      00'
Win_Y2 EQU ' 00    00'
Win_Y3 EQU '  00  00'
Win_Y4 EQU '   0000'
Win_Y5 EQU '    00'
Win_Y6 EQU '    00'
Win_Y7 EQU '    00'

Win_E1 EQU '000000000'
Win_E2 EQU '00        '
Win_E3 EQU '00        '
Win_E4 EQU '000000000'
Win_E5 EQU '00        '
Win_E6 EQU '00        '
Win_E7 EQU '000000000'

Win_R1 EQU '00000000'
Win_R2 EQU '00     00'
Win_R3 EQU '00     00'
Win_R4 EQU '00000000'
Win_R5 EQU '00   00 '
Win_R6 EQU '00    00'
Win_R7 EQU '00     00'

Win_11 EQU '  0000    '
Win_12 EQU ' 00 00    '
Win_13 EQU '00  00    '
Win_14 EQU '    00    '
Win_15 EQU '    00     '
Win_16 EQU '    00    '
Win_17 EQU '0000000000'

Win_21 EQU '0000000000'
Win_22 EQU '        00'
Win_23 EQU '        00'
Win_24 EQU '0000000000'
Win_25 EQU '00        '
Win_26 EQU '00        '
Win_27 EQU '0000000000'

Win_W1 EQU '00      00      00'
Win_W2 EQU '00      00      00'
Win_W3 EQU '00     0000     00'
Win_W4 EQU '00    00  00    00' 
Win_W5 EQU ' 00  00    00  00'
Win_W6 EQU '  0000      0000'
Win_W7 EQU '   00        00' 

Win_I1 EQU ' 00000000'
Win_I2 EQU '    00   '
Win_I3 EQU '    00   '
Win_I4 EQU '    00   '
Win_I5 EQU '    00   '
Win_I6 EQU '    00   '
Win_I7 EQU '0000000000'

Win_N1 EQU '000     00'
Win_N2 EQU '0000    00'
Win_N3 EQU '00 00   00'
Win_N4 EQU '00  00  00'
Win_N5 EQU '00   00 00'
Win_N6 EQU '00    0000'
Win_N7 EQU '00     000'

Win_T1 EQU '0000000000'
Win_T2 EQU '    00    '
Win_T3 EQU '    00    '
Win_T4 EQU '    00    '
Win_T5 EQU '    00    '
Win_T6 EQU '    00    '
Win_T7 EQU '    00    '

.code	;this is the code area


main proc
	Again:
		INVOKE PlaySound, OFFSET FILE_GAME, NULL, SND_FILENAME   ;play song
		call clrscr
		mGoto InitialPos_X1,InitialPos_Y1
		mov CurrentPos_X1,InitialPos_X1
		mov CurrentPos_Y1,InitialPos_Y1
		mWrite PLAYER1
		mGoto InitialPos_X2,InitialPos_Y2
		mov CurrentPos_X2,InitialPos_X2
		mov CurrentPos_Y2,InitialPos_Y2
		mWrite PLAYER2
		mov State1,0
		mov State2,0
		mov Score1,0
		mov Score2,0
		mov esi,0
		mov ecx,10
		call Randomize
		FloorInitial:
			mov eax , 6
			call RandomRange
			mov arr[esi] , al
			mov eax , 10
			call RandomRange
			.IF al<4
				mov arr_type[esi],0
			.ELSEIF al>=4 && al<6
				mov arr_type[esi],1
			.ELSEIF al>=6 && al<8
				mov arr_type[esi],2
			.ELSE
				mov arr_type[esi],3
			.ENDIF
			inc esi
		loop FloorInitial

		call ShowWall
		call ShowRole
		call clrscr
		INVOKE PlaySound, NULL, NULL, 0
		mGoto 50,15
		mWrite "Play again? yes(1)/no(0) > "
		mov eax,0
		call ReadDec
		cmp al,1
		je Again
		jmp EndAgain
	EndAgain:
		

	
	
	
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
	mov StateStartTime, eax

	Drop:

		.IF State1==2 && State2==2
			jnl EndDrop				;跳出迴圈
		 .ENDIF
		
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
		INVOKE GetTickCount	
		sub eax,StateStartTime
		mov StateTimer,eax

		
		.IF DropTimer>DropSpeed
			call ShowDrop
			call ChangeState
			INVOKE GetTickCount        ; get starting tick count
			mov    DropStartTime,eax        ; save it
		.ENDIF
		.IF StateTimer>StateSpeed
			call ChangeState
			INVOKE GetTickCount        ; get starting tick count
			mov StateStartTime,eax
		.ENDIF
		.IF KeyTimer>KeySpeed
			call key
			INVOKE GetTickCount        ; get starting tick count
			mov KeyStartTime,eax
		.ENDIF
		.IF FloorTimer>FloorSpeed
			.IF State1!=2
				inc Score1
			.ENDIF
			.IF State2!=2
				inc Score2
			.ENDIF
			call Left_Right
			call ShowFloor
			call ChangeState
			INVOKE GetTickCount        ; get starting tick count
			mov FloorStartTime,eax
		.ENDIF

		

		.IF CurrentPos_Y1 <= 0 || CurrentPos_Y1 >= 30  ;player1超出範圍
			mov State1,2					
		.ENDIF

		.IF CurrentPos_Y2 <= 0 || CurrentPos_Y2 >= 30  ;player2超出範圍
			mov State2,2					
		.ENDIF

		.IF State1 != 2								;player1死亡
			mGoTo CurrentPos_X1,CurrentPos_Y1
			mWrite Player1
		.ENDIF

		.IF State2 != 2								;player2死亡
			mGoTo CurrentPos_X2,CurrentPos_Y2
			mWrite Player2
		.ENDIF		
		
		jmp Drop
		

	EndDrop:	
	INVOKE PlaySound, NULL, NULL, 0    ;關閉前一個音樂
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
			mov al,arr_type[esi+1]
			mov arr_type[esi],al
			mov al,lg_type[esi+1]
			mov lg_type[esi],al
			inc esi
		Loop L1
		mov eax , 6 
        call RandomRange
		mov arr[9],al
		mov eax , 10
		call RandomRange
		.IF al<4
			mov arr_type[9],0
		.ELSEIF al>=4 && al<6
			mov arr_type[9],1
		.ELSEIF al>=6 && al<8
			mov arr_type[9],2
		.ELSE
			mov arr_type[9],3
		.ENDIF
		mov eax, 2
		call RandomRange
		mov lg_type[9],al
        
	.ELSEIF
		dec FloorCount
	.ENDIF
	
	
	mov esi,0
	mov eax,0
	mov al,FloorCount
	mov CurrentFloor,al
	

	.IF State1 == 1 || State1 == 3		;on the stair
		mGoto CurrentPos_X1, CurrentPos_Y1
		mWrite ' '
		dec CurrentPos_Y1
	.ENDIF

	.IF State2 == 1 || State2 == 3
		mGoto CurrentPos_X2, CurrentPos_Y2
		mWrite ' '
		dec CurrentPos_Y2
	.ENDIF
	
	

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
		.IF arr_type[esi]==0
			mWrite Floor
		.ELSEIF arr_type[esi]==1
			mWrite Sham
			dec CurrentFloor	
			mov al,CurrentFloor
			.IF CurrentPos_Y1==al&&State1==1
				mov arr_type[esi],4  ;下次不印東西
				mGoto arr_x[esi],arr_y[esi]
				mWrite empty
			.ENDIF
			.IF CurrentPos_Y2==al&&State2==1
				mov arr_type[esi],4  ;下次不印東西
				mGoto arr_x[esi],arr_y[esi]
				mWrite empty
			.ENDIF
			inc CurrentFloor
		.ELSEIF arr_type[esi]==2
			mWrite Spike
		.ELSEIF arr_type[esi]==3 
			.IF lg_type[esi]==1
				 .IF RollState==0
					mWrite RollRight_1
			     .ELSE 
				    mWrite RollRight_2
			     .ENDIF
			 .ELSEIF lg_type[esi]==0
			     .IF RollState==0
				    mWrite RollLeft_1
			    .ELSE 
				    mWrite RollLeft_2
			        .ENDIF
		        .ENDIF
			.ENDIF
		.ENDIF
		add CurrentFloor,3
		inc esi

	.IF esi<10
		JMP FloorLoop
	.ENDIF

	.IF RollState==0
		mov RollState,1
	.ELSE 
		mov RollState,0
	.ENDIF

		ret
	ShowFloor EndP
;----------------------------------------
;					Drop						
;----------------------------------------
ShowDrop PROC USES eax 
		;擦除上一個位置
		.IF State1 != 2
			mGoTo CurrentPos_X1,CurrentPos_Y1
			mWrite ' '
		.ENDIF

		.IF State2 != 2
			mGoTo CurrentPos_X2,CurrentPos_Y2
			mWrite ' '
		.ENDIF

		.IF State1 == 0
			inc CurrentPos_Y1
		.ENDIF
		.IF State2 == 0
			inc CurrentPos_Y2
		.ENDIF		
		
		
		
		
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
		push eax
		mov eax,15*16
		call setTextColor
		pop eax
		mWrite Wall
		mGoTo Max_X,al
		mWrite Wall
		inc eax
		jmp WallLoop
	
	EndWall:
		push eax
		mov eax,15
		call setTextColor
		pop eax
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
		
		.IF arr_type[esi]==0
			
			mWrite Floor	
		.ELSEIF arr_type[esi]==1
			mWrite Sham
		.ELSEIF arr_type[esi]==2
			mWrite Spike
		.ELSEIF arr_type[esi]==3 
		    .IF lg_type[esi]==1
			    .IF RollState==0
				    mWrite RollRight_1
			    .ELSE 
				    mWrite RollRight_2
			    .ENDIF
		    .ELSEIF  lg_type[esi]==0
			    .IF RollState==0
				    mWrite RollLeft_1
			    .ELSE 
				    mWrite RollLeft_2
			    .ENDIF
		    .ENDIF
			
		.ENDIF
		add CurrentFloor,3
		inc esi
		push eax
		mov eax,15
		call setTextColor
		pop eax

	.IF esi<10
		JMP FloorLoop
	.ENDIF
	
	mov ecx,60
	mov al,31
	SpikeLoop:
		mGoTo al,0
		
		mWrite 'V'
		inc al
	Loop SpikeLoop

	mov RollState,1

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
	INVOKE PlaySound, OFFSET FILE, NULL, SND_FILENAME  ;播放結束音樂
	mov eax,score2
	
	
	mov bh,15
	mov bl,7
	.IF score1>eax

		mGoTo bh,bl
		mWrite Win_P1
		inc bl
		mGoTo bh,bl
		mWrite Win_P2
		inc bl
		mGoTo bh,bl
		mWrite Win_P3
		inc bl
		mGoTo bh,bl
		mWrite Win_P4
		inc bl
		mGoTo bh,bl
		mWrite Win_P5
		inc bl
		mGoTo bh,bl
		mWrite Win_P6
		inc bl
		mGoTo bh,bl
		mWrite Win_P7
		inc bl

		add bh,10
		mov bl,7
		mGoTo bh,bl
		mWrite Win_L1
		inc bl
		mGoTo bh,bl
		mWrite Win_L2
		inc bl
		mGoTo bh,bl
		mWrite Win_L3
		inc bl
		mGoTo bh,bl
		mWrite Win_L4
		inc bl
		mGoTo bh,bl
		mWrite Win_L5
		inc bl
		mGoTo bh,bl
		mWrite Win_L6
		inc bl
		mGoTo bh,bl
		mWrite Win_L7
		inc bl

		add bh,11
		mov bl,7
		mGoTo bh,bl
		mWrite Win_A1
		inc bl
		mGoTo bh,bl
		mWrite Win_A2
		inc bl
		mGoTo bh,bl
		mWrite Win_A3
		inc bl
		mGoTo bh,bl
		mWrite Win_A4
		inc bl
		mGoTo bh,bl
		mWrite Win_A5
		inc bl
		mGoTo bh,bl
		mWrite Win_A6
		inc bl
		mGoTo bh,bl
		mWrite Win_A7
		inc bl

		add bh,14
		mov bl,7
		mGoTo bh,bl
		mWrite Win_Y1
		inc bl
		mGoTo bh,bl
		mWrite Win_Y2
		inc bl
		mGoTo bh,bl
		mWrite Win_Y3
		inc bl
		mGoTo bh,bl
		mWrite Win_Y4
		inc bl
		mGoTo bh,bl
		mWrite Win_Y5
		inc bl
		mGoTo bh,bl
		mWrite Win_Y6
		inc bl
		mGoTo bh,bl
		mWrite Win_Y7
		inc bl

		add bh,11
		mov bl,7
		mGoTo bh,bl
		mWrite Win_E1
		inc bl
		mGoTo bh,bl
		mWrite Win_E2
		inc bl
		mGoTo bh,bl
		mWrite Win_E3
		inc bl
		mGoTo bh,bl
		mWrite Win_E4
		inc bl
		mGoTo bh,bl
		mWrite Win_E5
		inc bl
		mGoTo bh,bl
		mWrite Win_E6
		inc bl
		mGoTo bh,bl
		mWrite Win_E7
		inc bl

		add bh,10
		mov bl,7
		mGoTo bh,bl
		mWrite Win_R1
		inc bl
		mGoTo bh,bl
		mWrite Win_R2
		inc bl
		mGoTo bh,bl
		mWrite Win_R3
		inc bl
		mGoTo bh,bl
		mWrite Win_R4
		inc bl
		mGoTo bh,bl
		mWrite Win_R5
		inc bl
		mGoTo bh,bl
		mWrite Win_R6
		inc bl
		mGoTo bh,bl
		mWrite Win_R7
		inc bl

		add bh,20
		mov bl,7
		mGoTo bh,bl
		mWrite Win_11
		inc bl
		mGoTo bh,bl
		mWrite Win_12
		inc bl
		mGoTo bh,bl
		mWrite Win_13
		inc bl
		mGoTo bh,bl
		mWrite Win_14
		inc bl
		mGoTo bh,bl
		mWrite Win_15
		inc bl
		mGoTo bh,bl
		mWrite Win_16
		inc bl
		mGoTo bh,bl
		mWrite Win_17
		inc bl
		
		mov bh,30
		mov bl,20
		mGoTo bh,bl
		mWrite Win_W1
		inc bl
		mGoTo bh,bl
		mWrite Win_W2
		inc bl
		mGoTo bh,bl
		mWrite Win_W3
		inc bl
		mGoTo bh,bl
		mWrite Win_W4
		inc bl
		mGoTo bh,bl
		mWrite Win_W5
		inc bl
		mGoTo bh,bl
		mWrite Win_W6
		inc bl
		mGoTo bh,bl
		mWrite Win_W7
		inc bl

		add bh,20
		mov bl,20
		mGoTo bh,bl
		mWrite Win_I1
		inc bl
		mGoTo bh,bl
		mWrite Win_I2
		inc bl
		mGoTo bh,bl
		mWrite Win_I3
		inc bl
		mGoTo bh,bl
		mWrite Win_I4
		inc bl
		mGoTo bh,bl
		mWrite Win_I5
		inc bl
		mGoTo bh,bl
		mWrite Win_I6
		inc bl
		mGoTo bh,bl
		mWrite Win_I7
		inc bl
		
		add bh,11
		mov bl,20
		mGoTo bh,bl
		mWrite Win_N1
		inc bl
		mGoTo bh,bl
		mWrite Win_N2
		inc bl
		mGoTo bh,bl
		mWrite Win_N3
		inc bl
		mGoTo bh,bl
		mWrite Win_N4
		inc bl
		mGoTo bh,bl
		mWrite Win_N5
		inc bl
		mGoTo bh,bl
		mWrite Win_N6
		inc bl
		mGoTo bh,bl
		mWrite Win_N7
		inc bl

		
	
	.ELSEIF	score1<eax
		mGoTo bh,bl
		mWrite Win_P1
		inc bl
		mGoTo bh,bl
		mWrite Win_P2
		inc bl
		mGoTo bh,bl
		mWrite Win_P3
		inc bl
		mGoTo bh,bl
		mWrite Win_P4
		inc bl
		mGoTo bh,bl
		mWrite Win_P5
		inc bl
		mGoTo bh,bl
		mWrite Win_P6
		inc bl
		mGoTo bh,bl
		mWrite Win_P7
		inc bl

		add bh,10
		mov bl,7
		mGoTo bh,bl
		mWrite Win_L1
		inc bl
		mGoTo bh,bl
		mWrite Win_L2
		inc bl
		mGoTo bh,bl
		mWrite Win_L3
		inc bl
		mGoTo bh,bl
		mWrite Win_L4
		inc bl
		mGoTo bh,bl
		mWrite Win_L5
		inc bl
		mGoTo bh,bl
		mWrite Win_L6
		inc bl
		mGoTo bh,bl
		mWrite Win_L7
		inc bl

		add bh,11
		mov bl,7
		mGoTo bh,bl
		mWrite Win_A1
		inc bl
		mGoTo bh,bl
		mWrite Win_A2
		inc bl
		mGoTo bh,bl
		mWrite Win_A3
		inc bl
		mGoTo bh,bl
		mWrite Win_A4
		inc bl
		mGoTo bh,bl
		mWrite Win_A5
		inc bl
		mGoTo bh,bl
		mWrite Win_A6
		inc bl
		mGoTo bh,bl
		mWrite Win_A7
		inc bl

		add bh,14
		mov bl,7
		mGoTo bh,bl
		mWrite Win_Y1
		inc bl
		mGoTo bh,bl
		mWrite Win_Y2
		inc bl
		mGoTo bh,bl
		mWrite Win_Y3
		inc bl
		mGoTo bh,bl
		mWrite Win_Y4
		inc bl
		mGoTo bh,bl
		mWrite Win_Y5
		inc bl
		mGoTo bh,bl
		mWrite Win_Y6
		inc bl
		mGoTo bh,bl
		mWrite Win_Y7
		inc bl

		add bh,11
		mov bl,7
		mGoTo bh,bl
		mWrite Win_E1
		inc bl
		mGoTo bh,bl
		mWrite Win_E2
		inc bl
		mGoTo bh,bl
		mWrite Win_E3
		inc bl
		mGoTo bh,bl
		mWrite Win_E4
		inc bl
		mGoTo bh,bl
		mWrite Win_E5
		inc bl
		mGoTo bh,bl
		mWrite Win_E6
		inc bl
		mGoTo bh,bl
		mWrite Win_E7
		inc bl

		add bh,10
		mov bl,7
		mGoTo bh,bl
		mWrite Win_R1
		inc bl
		mGoTo bh,bl
		mWrite Win_R2
		inc bl
		mGoTo bh,bl
		mWrite Win_R3
		inc bl
		mGoTo bh,bl
		mWrite Win_R4
		inc bl
		mGoTo bh,bl
		mWrite Win_R5
		inc bl
		mGoTo bh,bl
		mWrite Win_R6
		inc bl
		mGoTo bh,bl
		mWrite Win_R7
		inc bl

		add bh,20
		mov bl,7
		mGoTo bh,bl
		mWrite Win_21
		inc bl
		mGoTo bh,bl
		mWrite Win_22
		inc bl
		mGoTo bh,bl
		mWrite Win_23
		inc bl
		mGoTo bh,bl
		mWrite Win_24
		inc bl
		mGoTo bh,bl
		mWrite Win_25
		inc bl
		mGoTo bh,bl
		mWrite Win_26
		inc bl
		mGoTo bh,bl
		mWrite Win_27
		inc bl
		
		mov bh,30
		mov bl,20
		mGoTo bh,bl
		mWrite Win_W1
		inc bl
		mGoTo bh,bl
		mWrite Win_W2
		inc bl
		mGoTo bh,bl
		mWrite Win_W3
		inc bl
		mGoTo bh,bl
		mWrite Win_W4
		inc bl
		mGoTo bh,bl
		mWrite Win_W5
		inc bl
		mGoTo bh,bl
		mWrite Win_W6
		inc bl
		mGoTo bh,bl
		mWrite Win_W7
		inc bl

		add bh,20
		mov bl,20
		mGoTo bh,bl
		mWrite Win_I1
		inc bl
		mGoTo bh,bl
		mWrite Win_I2
		inc bl
		mGoTo bh,bl
		mWrite Win_I3
		inc bl
		mGoTo bh,bl
		mWrite Win_I4
		inc bl
		mGoTo bh,bl
		mWrite Win_I5
		inc bl
		mGoTo bh,bl
		mWrite Win_I6
		inc bl
		mGoTo bh,bl
		mWrite Win_I7
		inc bl
		
		add bh,11
		mov bl,20
		mGoTo bh,bl
		mWrite Win_N1
		inc bl
		mGoTo bh,bl
		mWrite Win_N2
		inc bl
		mGoTo bh,bl
		mWrite Win_N3
		inc bl
		mGoTo bh,bl
		mWrite Win_N4
		inc bl
		mGoTo bh,bl
		mWrite Win_N5
		inc bl
		mGoTo bh,bl
		mWrite Win_N6
		inc bl
		mGoTo bh,bl
		mWrite Win_N7
		inc bl

	.ELSEIF
		mov bh,40
		mov bl,12
		mGoTo bh,bl
		mWrite Win_T1
		inc bl
		mGoTo bh,bl
		mWrite Win_T2
		inc bl
		mGoTo bh,bl
		mWrite Win_T3
		inc bl
		mGoTo bh,bl
		mWrite Win_T4
		inc bl
		mGoTo bh,bl
		mWrite Win_T5
		inc bl
		mGoTo bh,bl
		mWrite Win_T6
		inc bl
		mGoTo bh,bl
		mWrite Win_T7
		inc bl
		
		add bh,12
		mov bl,12
		mGoTo bh,bl
		mWrite Win_L1
		inc bl
		mGoTo bh,bl
		mWrite Win_L2
		inc bl
		mGoTo bh,bl
		mWrite Win_L3
		inc bl
		mGoTo bh,bl
		mWrite Win_L4
		inc bl
		mGoTo bh,bl
		mWrite Win_L5
		inc bl
		mGoTo bh,bl
		mWrite Win_L6
		inc bl
		mGoTo bh,bl
		mWrite Win_L7
		inc bl

		add bh,12
		mov bl,12
		mGoTo bh,bl
		mWrite Win_E1
		inc bl
		mGoTo bh,bl
		mWrite Win_E2
		inc bl
		mGoTo bh,bl
		mWrite Win_E3
		inc bl
		mGoTo bh,bl
		mWrite Win_E4
		inc bl
		mGoTo bh,bl
		mWrite Win_E5
		inc bl
		mGoTo bh,bl
		mWrite Win_E6
		inc bl
		mGoTo bh,bl
		mWrite Win_E7
		inc bl
		
		
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
	.IF ah && CurrentPos_X1 > 31 && State1 != 2
		
		.IF CurrentPos_X1 == bl && CurrentPos_Y1 == bh && CurrentPos_X1>32
			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X2,CurrentPos_Y2						;消去player2本來的位置
			mWrite ' '
			dec CurrentPos_X2
			
		.ELSEIF	CurrentPos_X1 != bl || CurrentPos_Y1 != bh
			
			;-----------------判斷player1左邊有沒有樓梯----------------------;
			mov ecx,10
			mov ah, CurrentPos_Y1
			mov al, CurrentPos_X1
			dec al
			LeftLoop1:
				.IF ah == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					add ah,9
					.IF al==ah
						jmp Left1
					.ENDIF
				.ENDIF
			loop LeftLoop1

			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
				
			Left1:
		

		.ENDIF
		
		

	.ENDIF
	

	INVOKE GetKeyState, 'D'    ;角色1右鍵
	mov bh, CurrentPos_Y2
	mov bl, CurrentPos_X2
	dec bl
	.IF ah && CurrentPos_X1 < 90 && State1 != 2
		.IF CurrentPos_X1 == bl && CurrentPos_Y1 == bh && CurrentPos_X1<89
			mGoto CurrentPos_X1,CurrentPos_Y1    
			mWrite ' '
			inc CurrentPos_X1
			mGoto CurrentPos_X2,CurrentPos_Y2   
			mWrite ' '
			inc CurrentPos_X2
		.ELSEIF CurrentPos_X1 != bl || CurrentPos_Y1 != bh
			;-----------------判斷player1右邊有沒有樓梯----------------------;
			mov ecx,10
			mov ah, CurrentPos_Y1
			mov al, CurrentPos_X1
			inc al
			RightLoop1:
				.IF ah == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					.IF al==ah
						jmp Right1
					.ENDIF
				.ENDIF
			loop RightLoop1
			mGoto CurrentPos_X1,CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			inc CurrentPos_X1
				
			Right1:
			

		.ENDIF
	.ENDIF

  INVOKE GetKeyState, VK_LEFT	;角色2左鍵
	mov bh, CurrentPos_Y1
	mov bl, CurrentPos_X1
	inc bl
	.IF ah && CurrentPos_X2 > 31 && State2 != 2
		.IF CurrentPos_X2 == bl && CurrentPos_Y2 == bh && CurrentPos_X2>32
			mGoto CurrentPos_X2, CurrentPos_Y2						;消去player2本來的位置
			mWrite ' '
			dec CurrentPos_X2
														
			mGoto CurrentPos_X1, CurrentPos_Y1						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X1
														
		.ELSEIF	CurrentPos_X2 != bl || CurrentPos_Y2 != bh

			;-----------------判斷player2左邊有沒有樓梯----------------------;
			mov ecx,10
			mov ah, CurrentPos_Y2
			mov al, CurrentPos_X2
			dec al
			LeftLoop2:
				.IF ah == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					add ah,9
					.IF al==ah
						jmp Left2
					.ENDIF
				.ENDIF
			loop LeftLoop2

			mGoto CurrentPos_X2,CurrentPos_Y2						;消去player1本來的位置
			mWrite ' '
			dec CurrentPos_X2
				
			Left2:
		.ENDIF

	.ENDIF

  INVOKE GetKeyState, VK_RIGHT	;角色2右鍵
	mov bl, CurrentPos_X1
	dec bl
	.IF ah && CurrentPos_X2 < 90 && State2 != 2
		.IF CurrentPos_X2 == bl && CurrentPos_Y2 == bh && CurrentPos_X2<89
			mGoto CurrentPos_X2, CurrentPos_Y2      
			mWrite ' '
			inc CurrentPos_X2
			mGoto CurrentPos_X1, CurrentPos_Y1      
			mWrite ' '
			inc CurrentPos_X1
		.ELSEIF CurrentPos_X2 != bl || CurrentPos_Y2 != bh

			;-----------------判斷player2右邊有沒有樓梯----------------------;
			mov ecx,10
			mov ah, CurrentPos_Y2
			mov al, CurrentPos_X2
			inc al
			RightLoop2:
				.IF ah == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					.IF al==ah
						jmp Right2
					.ENDIF
				.ENDIF
			loop RightLoop2
			mGoto CurrentPos_X2,CurrentPos_Y2						;消去player1本來的位置
			mWrite ' '
			inc CurrentPos_X2
				
			Right2:

		.ENDIF
	.ENDIF 
	
	
	ret
key endp

;---------------------------------------------
;					ChangeState
;---------------------------------------------
ChangeState proc USES eax ecx edx ebx
	.IF State1 != 2
			mov State1,0
			mov dl,State2
			mov bl, CurrentPos_Y1
			mov bh, CurrentPos_X1
			inc bl
			
			
			mov ecx,10
			CheckState1:
				.IF bl == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					mov al,ah
					add al,9
					.IF CurrentPos_X1 >= ah && CurrentPos_X1 <= al && arr_type[ecx-1]!=4 
						mov State1,1
						sub bl,2
						.IF arr_type[ecx-1]==2
						    mov State1,2
						.ELSEIF CurrentPos_X2 == bh && CurrentPos_Y2 == bl
							mov State2,3
							jmp E1
						.ENDIF
					.ELSE
						mov State1,0
					.ENDIF
					jmp S2
				.ELSE
					mov State1,0
				.ENDIF
			loop CheckState1
		.ENDIF
S2:
		
		.IF State2 != 2
			mov bl, CurrentPos_Y2
			mov bh, CurrentPos_X2
			inc bl
			
			mov ecx,10
			CheckState2:
				.IF bl == arr_y[ecx-1]
					mov ah,arr_x[ecx-1]
					mov al,ah
					add al,9
					.IF CurrentPos_X2 >= ah && CurrentPos_X2 <= al && arr_type[ecx-1]!=4 
						mov State2,1
						sub bl,2
						.IF arr_type[ecx-1]==2
						    mov State2,2
						.ELSEIF CurrentPos_X1 == bh && CurrentPos_Y1 == bl
							mov State1,3
							jmp E1
						.ENDIF
					.ELSE
						mov State2,0
					.ENDIF
					jmp E1
				.ELSE
					mov State2,0
				.ENDIF
			loop CheckState2
		.ENDIF
		
E1:	
	;-------------更新腳下地板狀態
	mov Floor_type1,0
	mov bl, CurrentPos_Y1
	mov bh, CurrentPos_X1
	inc bl
	mov esi, 0
	L1:
	.IF bl == arr_y[esi] || esi>9
		.IF arr_type[esi]==3 
		    .IF lg_type[esi] == 1
			    mov Floor_type1,3
				jmp EndL1
			.ELSEIF lg_type[esi]==0
			    mov Floor_type1,4
			    jmp EndL1
			.ENDIF
		.ENDIF	
	.ELSE
		inc esi
		jmp L1
	.ENDIF
	EndL1:

	mov Floor_type2,0
	mov bl, CurrentPos_Y2
	mov bh, CurrentPos_X2
	inc bl
	mov esi, 0
	L2:
	.IF bl == arr_y[esi] || esi>9
		.IF arr_type[esi]==3 
		    .IF lg_type[esi]==1
			    mov Floor_type2,3
				jmp EndL2
			.ELSEIF lg_type[esi]==0
			    mov Floor_type2, 4
			    jmp EndL2
			.ENDIF
		.ENDIF	
	.ELSE
		inc esi
		jmp L2
	.ENDIF
	EndL2:

	 
	ret
ChangeState endp
;---------------------------------------------
;					left or right
;---------------------------------------------

Left_Right proc  

 

 .IF State1 == 1 
     .IF Floor_type1 == 3
	    .IF CurrentPos_X1 <90
			inc CurrentPos_X1
		.ENDIF
	 .ELSEIF Floor_type1 == 4
	     .IF CurrentPos_X1 > 31
			dec CurrentPos_X1
		.ENDIF
	 .ENDIF
	 
 .ENDIF
 .IF State2 == 1 
     .IF Floor_type2 == 3
		.IF CurrentPos_X2<90
			inc CurrentPos_X2
		.ENDIF
	 .ELSEIF Floor_type2 == 4
		.IF CurrentPos_X2>31
			dec CurrentPos_X2
		.ENDIF
	 .ENDIF
	 
 .ENDIF
	ret
Left_Right endp
end main