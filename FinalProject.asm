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

KeySpeed EQU 50								;鍵盤輸入速度
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

.code	;this is the code area


main proc
	
	mov esi,0
	mov ecx,10
	call Randomize
	FloorInitial:
		mov eax , 6
        call RandomRange
        mov arr[esi] , al
		mov eax , 4
        call RandomRange
        mov arr_type[esi] , al
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

		

		.IF CurrentPos_Y1 <= 0 || CurrentPos_Y1 >= 31  ;player1超出範圍
			mov State1,2					
		.ENDIF

		.IF CurrentPos_Y2 <= 0 || CurrentPos_Y2 >= 31  ;player2超出範圍
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
		mov eax , 4 
        call RandomRange
		mov arr_type[9],al
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
			.ELSEIF arr_type[esi]==2
				mWrite Spike
			.ELSEIF arr_type[esi]==3 && lg_type[esi]==1
				.IF RollState==0
					mWrite RollRight_1
				.ELSE 
					mWrite RollRight_2
				.ENDIF
			.ELSEIF arr_type[esi]==4 && lg_type[esi]==1
				.IF RollState==0
					mWrite RollLeft_1
				.ELSE 
					mWrite RollLeft_2
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

		

		.IF arr_type[esi]==0
			mWrite Floor
		.ELSEIF arr_type[esi]==1
			mWrite Sham
		.ELSEIF arr_type[esi]==2
			mWrite Spike
		.ELSEIF arr_type[esi]==3 && lg_type[esi]==1
			.IF RollState==0
				mWrite RollRight_1
			.ELSE 
				mWrite RollRight_2
			.ENDIF
		.ELSEIF arr_type[esi]==4 && lg_type[esi]==1
			.IF RollState==0
				mWrite RollLeft_1
			.ELSE 
				mWrite RollLeft_2
			.ENDIF
		.ENDIF
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
					.IF CurrentPos_X1 >= ah && CurrentPos_X1 <= al 
						mov State1,1
						sub bl,2
						.IF CurrentPos_X2 == bh && CurrentPos_Y2 == bl
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
					.IF CurrentPos_X2 >= ah && CurrentPos_X2 <= al 
						mov State2,1
						sub bl,2
						.IF CurrentPos_X1 == bh && CurrentPos_Y1 == bl
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
		.IF arr_type[esi]==3 || arr_type[esi]==4
			mov al,arr_type[esi]
			mov Floor_type1,al
			jmp EndL1
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
		.IF arr_type[esi]==3 || arr_type[esi]==4
			mov al,arr_type[esi]
			mov Floor_type2,al
			jmp EndL2
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