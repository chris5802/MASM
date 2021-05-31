INCLUDE Irvine32.inc
INCLUDE Macros.inc
INCLUDELIB user32.lib

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

Remainder byte ?							;�l��
Quotient byte ?								;��

arr byte 0,0,0,0,0,0,0,0,0,0				;�a�ϰ}�C
arr_y byte 0,3,6,9,12,15,18,21,24,27		;�a�ϰ}�C��y�y�Ь���
arr_x byte 0,0,0,0,0,0,0,0,0,0				;�a�ϰ}�C��x�y�Ь���

top DWORD 0
bottom DWORD 9
FloorCount byte 2
CurrentFloor byte 2

DropSpeed EQU 100							;�����t��
DropStartTime DWORD ?						;�����_�l�ɶ�
DropTimer DWORD ?							;Drop Timer

KeySpeed EQU 20								;��L��J�t��
KeyStartTime DWORD ?						;��L��J�_�l�ɶ�
KeyTimer DWORD ?							;Key Timer

FloorSpeed EQU 1000							;�W�ɳt��
FloorStartTime DWORD ?						;�W�ɰ_�l�ɶ�
FloorTimer DWORD ?							;Floor Timer



InitialPos_X1 EQU 50						;����1�_�l��mX
InitialPos_Y1 EQU 1							;����1�_�l��mY
CurrentPos_X1 BYTE InitialPos_X1			;����1��e��mX
CurrentPos_Y1 BYTE InitialPos_Y1			;����1��e��mY
Player1 EQU 'A'
Score1 DWORD 0								;����1����

InitialPos_X2 EQU 60						;����2�_�l��mX
InitialPos_Y2 EQU 1 						;����2�_�l��mY
CurrentPos_X2 BYTE InitialPos_X2			;����2��e��mX
CurrentPos_Y2 BYTE InitialPos_Y2			;����2��e��mY
Player2 EQU 'B'
Score2 DWORD 0								;����2����

Wall EQU '|'				;���
Floor EQU 'TTTTTTTTTT'
Empty EQU '          '		

Min_X EQU 30			
Max_X EQU 91			;�a�ϼe
Min_Y EQU 0	
Max_Y EQU 30			;�a�ϰ�

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
;					�e�X�H��						
;----------------------------------------
ShowRole  PROC	
	
	INVOKE GetTickCount       
    mov DropstartTime,eax       
	mov KeyStartTime,eax
	mov FloorStartTime,eax


	Drop:
		
		call ShowScore
		;�p�ⱼ����timer
		INVOKE GetTickCount        ; get new tick count
		sub    eax,DropstartTime        ; get elapsed milliseconds
		mov DropTimer,eax		
		;�p����L��J��timer
		INVOKE GetTickCount        ; get new tick count
		sub eax,KeyStartTime
		mov KeyTimer,eax
		;�p��a�O��J��timer
		INVOKE GetTickCount        ; get new tick count
		sub eax,FloorStartTime
		mov FloorTimer,eax


		.IF CurrentPos_Y1 > Max_Y && CurrentPos_Y2 >Max_Y
			jnl EndDrop				;���X�j��
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
	
	EmptyLoop:							;���h�W�@���ӱ誺�j��
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
	

	.IF FloorCount==0					;�̤W�h���a�O�n�W�L�Ѫ�O�A�}�C�ݭn��s
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

	
	FloorLoop:							;�e�ӱ誺�j��
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
		;�����W�@�Ӧ�m
		mGoTo CurrentPos_X1,CurrentPos_Y1
		mWrite ' '	
		mGoTo CurrentPos_X2,CurrentPos_Y2
		mWrite ' '	

		;--------------�P�_player1����---------------
		
		
		

		
		
		;--------------�P�_����---------------

		inc CurrentPos_Y1
		inc CurrentPos_Y2
		
		
		mov eax,0
		mov flag,eax

		ret
	ShowDrop EndP
;----------------------------------------
;					�e�X�O���O						
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
;					�����e��						
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
;					��J
;----------------------------------------
key proc
	mov ah,0
	
	INVOKE GetKeyState, 'A'   ;����1����
	mov bh, CurrentPos_Y2
	mov bl, CurrentPos_X2
	inc bl
	.IF ah && CurrentPos_X1 > 31 
		.IF CurrentPos_X1 == bl && CurrentPos_Y1 == bh && CurrentPos_X1>32
			mGoto CurrentPos_X1,CurrentPos_Y1						;���hplayer1���Ӫ���m
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1�s��m	
			mGoto CurrentPos_X2,CurrentPos_Y2						;���hplayer2���Ӫ���m
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2
		.ELSEIF	CurrentPos_X1 != bl || CurrentPos_Y1 != bh
			mGoto CurrentPos_X1,CurrentPos_Y1						;���hplayer1���Ӫ���m
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1�s��m	
		.ENDIF
		
	.ENDIF

	INVOKE GetKeyState, 'D'    ;����1�k��
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
			mGoto CurrentPos_X1,CurrentPos_Y1						;���hplayer1���Ӫ���m
			mWrite ' '
			inc CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1
		.ENDIF
	.ENDIF

  INVOKE GetKeyState, VK_LEFT	;����2����
	mov bh, CurrentPos_Y1
	mov bl, CurrentPos_X1
	inc bl
	.IF ah && CurrentPos_X2 > 31
		.IF CurrentPos_X2 == bl && CurrentPos_Y2 == bh && CurrentPos_X2>32
			mGoto CurrentPos_X2, CurrentPos_Y2						;���hplayer2���Ӫ���m
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2											;player2�s��m
			mGoto CurrentPos_X1, CurrentPos_Y1						;���hplayer1���Ӫ���m
			mWrite ' '
			dec CurrentPos_X1
			mGoto CurrentPos_X1, CurrentPos_Y1
			mWrite Player1											;player1�s��m
		.ELSEIF	CurrentPos_X2 != bl || CurrentPos_Y2 != bh
			mGoto CurrentPos_X2,CurrentPos_Y2						;���hplayer2���Ӫ���m
			mWrite ' '
			dec CurrentPos_X2
			mGoto CurrentPos_X2, CurrentPos_Y2
			mWrite Player2											;player2�s��m	
		.ENDIF

	.ENDIF

  INVOKE GetKeyState, VK_RIGHT	;����2�k��
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