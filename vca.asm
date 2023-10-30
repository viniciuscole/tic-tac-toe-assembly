; Vinicius Cole de Amorim
segment code
extern cursor
extern caracter
extern circle
extern line
extern modo_anterior
extern cor

..start:
        mov ax,data
        mov ds,ax
        mov ax,stack
        mov ss,ax
        mov sp,stacktop
        ; salvar modo corrente de vídeo
        mov ah,0Fh
        int 10h
        mov [modo_anterior],al
        ; alterar modo de video para gráfico 640x480 16 cores
        mov al,12h
        mov ah,0
        int 10h

inicializa_jogo:
	campos_escrita:
		mov	byte[cor], branco
		;comandos
		mov	bx, 40			
		mov	cx, 24			
		mov	dx, 600			
		mov	si, 56
		call desenha_retangulo		

		;erros
		mov	bx, 40			
		mov	cx, 72			
		mov	dx, 600			
		mov	si, 104
		call desenha_retangulo		
		
	jogo_da_velha:
		call escreve_horizontais
		call escreve_verticais

	escrita_posicoes:
		mov	cx, 3
		mov	bx, 0
		mov dh, 2			
		call escreve_colunas
jogo:	
		mov	bx, 0
		mov dh, 24			
		mov dl, 6	

	continua:
		mov ah, 07H ;Ler caracter da STDIN
		int 21H
		cmp al, 0x0d ;Verifica se foi 'enter'
		je 	enterL
		cmp al, 0x08 ;Verifica se foi 'backspace'
		je 	backspace
	
	escreve:
		cmp bx, 68
		je 	continua
		mov [buffer + bx], al
		call cursor
		call caracter
		inc	bx
		inc dl			;deixa o cursor na proxima coluna
		jmp continua
	reset0:
		jmp reset
	enterL:
		cmp bx, 0
		je	continua
		cmp byte [buffer], 'X'
		je X
		cmp byte [buffer], 'C'
		je	C
		cmp byte [buffer], 's'
		je sai1
		cmp byte [buffer], 'c'
		je reset0
		jmp comandoInvalido

	backspace:
		cmp bx, 0
		je continua
		dec dl
		call cursor
		mov	al, 0x00
		call caracter
		dec	bx
		mov	[buffer + bx], al
		jmp continua
sai:
	mov ah,0 ; set video mode
	mov al,[modo_anterior] ; recupera o modo anterior
	int 10h
	mov ax,4c00h
	int 21h
	
sai1:
	cmp bx, 1
	je	sai
	jmp comandoInvalido
X:	
	cmp byte [lastPLayer], 'X'
	je jogadaRepetidaX
	cmp byte [buffer + 1], '1'
	je  X2
	cmp byte [buffer + 1], '2'
	je  X2
	cmp byte [buffer + 1], '3'
	je  X2
	jmp jogadaInvalida
C:	
	cmp byte [lastPLayer], 'O'
	je jogadaRepetidaC
	cmp byte [buffer + 1], '1'
	je  C2
	cmp byte [buffer + 1], '2'
	je  C2
	cmp byte [buffer + 1], '3'
	je  C2
	jmp jogadaInvalida

jogadaRepetidaX:
	push bx
	push dx
	call limpaConsole
	mov cx, 8			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	msgX:
		call cursor
		mov al,[bx+erroX]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop msgX
	pop	dx
	pop	bx
	call limpaBuffer
	jmp jogo
		
jogadaRepetidaC:
	push bx
	push dx
	call limpaConsole
	mov cx, 8			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	msgC:
		call cursor
		mov al,[bx+erroO]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop msgC
	pop	dx
	pop	bx
	call limpaBuffer
	jmp jogo

X2:
	cmp byte [buffer + 2], '1'
	je	X3
	cmp byte [buffer + 2], '2'
	je	X3
	cmp byte [buffer + 2], '3'
	je	X3
	jmp jogadaInvalida

C2:
	cmp byte [buffer + 2], '1'
	je  C3
	cmp byte [buffer + 2], '2'
	je  C3
	cmp byte [buffer + 2], '3'
	je  C3
	jmp jogadaInvalida

X3:
	cmp bx, 3
	je	jogaX
	jmp jogadaInvalida

C3:
	cmp bx, 3
	je	jogaO
	jmp jogadaInvalida

jogaX:
	push ax
	push bx
	push cx
	push dx

	;calculando a posicao no tabuleiro
	mov  ax, [buffer + 1]
	sub ax, 48
	dec ax
	xor ah, ah
	mov bx, 3
	mul bx
	mov bx, [buffer + 2]
	sub bx, 48
	xor bh, bh
	add ax, bx
	mov bx, ax
	dec bx

	cmp byte [tabuleiro + bx], 'X'
	je jogadaInvalida
	cmp byte [tabuleiro + bx], 'O'
	je jogadaInvalida

	mov byte [lastPLayer], 'X'
	mov byte [tabuleiro + bx], 'X' 

	pop dx
	pop cx
	pop bx
	pop ax

	call desenha_x
	call limpaBuffer
	call limpaConsole
	call checaVitoriaX
	call checaEmpate
	jmp jogo
jogaO:
	push ax
	push bx
	push cx
	push dx

	;calculando a posicao no tabuleiro
	mov ax, [buffer + 1]
	sub ax, 48
	dec ax
	xor ah, ah
	mov bx, 3
	mul bx
	mov bx, [buffer + 2]
	sub bx, 48
	xor bh, bh
	add ax, bx
	mov bx, ax
	dec bx

	cmp byte [tabuleiro + bx], 'X'
	je jogadaInvalida
	cmp byte [tabuleiro + bx], 'O'
	je jogadaInvalida


	mov byte [lastPLayer], 'O'
	mov byte [tabuleiro + bx], 'O' 
	
	pop dx
	pop cx
	pop bx
	pop ax

	call desenha_o
	call limpaBuffer
	call limpaConsole
	call checaVitoriaO
	call checaEmpate
	jmp jogo

jogadaInvalida:
	push bx
	push cx
	push dx
	call limpaConsole
	call limpaBuffer
	mov cx, 15			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	msg2:
		call cursor
		mov al,[bx+erro2]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop msg2
	pop	dx
	pop cx
	pop	bx
	jmp jogo
comandoInvalido:
	push bx
	push dx
	call limpaConsole
	call limpaBuffer
	mov cx, 16			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	msg1:
		call cursor
		mov al,[bx+erro1]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop msg1
	pop	dx
	pop	bx
	jmp jogo


limpaBuffer:
	push bx
	push cx
	push dx
	mov	dh, 24
	mov	dl, 74
	mov cx, 68
	apaga:
		cmp cx, 0
		je 	retorna
		dec dl
		call cursor
		mov	al, 0x00
		call caracter
		mov bx, cx
		mov [buffer + bx], al
		dec cx
		jmp apaga
	retorna:
		pop	dx
		pop cx
		pop bx
		ret

limpaConsole:
	push bx
	push cx
	push dx
	mov	dh, 27
	mov	dl, 74
	mov cx, 68
	apaga2:
		cmp cx, 0
		je 	retorna2
		dec dl
		call cursor
		mov	al, 0x00
		call caracter
		dec cx
		jmp apaga2
	retorna2:
		pop	dx
		pop cx
		pop	bx
		ret

fimdejogo:
	mov dh, 24
	mov dl, 6
	mov cx, 64
	mov bx, 0
	escrevemsgfim:
		call cursor
		mov al,[bx+msgfim]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop escrevemsgfim
	esperainput:
		mov ah, 07H ;Ler caracter da STDIN
		int 21H
		cmp al, 'c'
		je resetfim
		cmp al, 's'
		je saifim	
		jmp esperainput

	saifim:
		jmp sai
	resetfim:
		jmp reset

reset:
	call limpaBuffer
	call limpaTabuleiro
	mov byte [lastPLayer], 0
	jmp ..start
	
	
; FUNÇÕES ==========================================================================================================
; FUNÇÕES ==========================================================================================================
; FUNÇÕES ==========================================================================================================

;recebe os 3 pontos como parametro
desenha_linha:
	mov	byte[cor], vermelho
	push bp
	mov	 bp,sp
	pushf                        ;coloca os flags na pilha
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	;mov		cx,[bp+4]    ; resgata p3
	
	mov	ax,[bp+8]   ; resgata p1
	dec ax
	mov bl, 3
	div	bl
	xor ah, ah
	mov cx, ax
	mov bx, ax
	inc bx, 		;linha de p1

	mov ax, [bp+8]
	subtrai:			; cx vezes = linha - 1 vezes
		cmp cx, 0
		je paraSubtracao
		sub ax, 3
		loop subtrai
	;ax = coluna de p1
	
	paraSubtracao:
	dec ax
	dec bx
	mov cl, 104
	mul cl
	mov cx, 164				;x base
	add cx, ax
	add cx, 52				;centro do X

	mov dx, cx  			;salvando para fazer a prox linha
	push cx
	
	mov ax, bx
	
	mov cl, 104
	mul cl
	mov cx, 458			;y base
	sub cx, ax
	sub cx, 52			;centro do Y

	push cx				;ponto 1 completo

	;;ponto2

	mov ax,[bp+6]    ; resgata p2
	dec ax
	mov bl, 3
	div	bl
	xor ah, ah
	mov cx, ax
	mov bx, ax
	inc bx, 		;linha de p2

	mov ax, [bp+6]
	subtrai2:
		cmp cx, 0
		je paraSubtracao2	
		sub ax, 3
		loop subtrai2
	;ax = coluna de p2
	paraSubtracao2:
	dec ax
	dec bx
	mov cl, 104
	mul cl
	mov cx, 164				
	add cx, ax
	add cx, 52		
	
	mov dx, cx  ;salvando para fazer a prox linha
	push cx
	
	mov ax, bx
	
	mov cl, 104
	mul cl
	mov cx, 458			
	sub cx, ax
	sub cx, 52			

	push cx				;ponto 2 completo

	call line

	push dx
	push cx        ;ponto 2

	;;ponto3

	mov ax,[bp+4]    ; resgata p2
	dec ax
	mov bl, 3
	div	bl
	xor ah, ah
	mov cx, ax
	mov bx, ax
	inc bx, 		;linha de p2

	mov ax, [bp+4]
	subtrai3:
		cmp cx, 0
		je paraSubtracao3	
		sub ax, 3
		loop subtrai3
	;ax = coluna de p2
	paraSubtracao3:
	dec ax
	dec bx
	mov cl, 104
	mul cl
	mov cx, 164				
	add cx, ax
	add cx, 52		
	
	push cx
	
	mov ax, bx
	
	mov cl, 104
	mul cl
	mov cx, 458			
	sub cx, ax
	sub cx, 52			

	push cx				;ponto 2 completo

	call line

fim_desenha:
	mov	byte[cor], branco
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6



limpaTabuleiro:
	mov byte [tabuleiro], ' '
	mov byte [tabuleiro + 1], ' '
	mov byte [tabuleiro + 2], ' '
	mov byte [tabuleiro + 3], ' '
	mov byte [tabuleiro + 4], ' '
	mov byte [tabuleiro + 5], ' '
	mov byte [tabuleiro + 6], ' '
	mov byte [tabuleiro + 7], ' '
	mov byte [tabuleiro + 8], ' '
	ret

empatou:
	push bx
	push dx
	call limpaConsole
	call limpaBuffer
	mov cx, 6			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	empatou2:
		call cursor
		mov al,[bx+empate]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop empatou2
	pop	dx
	pop	bx
	jmp fimdejogo

vitoriaO:
	push bx
	push dx
	call limpaConsole
	call limpaBuffer
	mov cx, 8			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	vitoriaO2:
		call cursor
		mov al,[bx+vencedorO]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop vitoriaO2
	pop	dx
	pop	bx
	jmp fimdejogo
vitoriaX:
	push bx
	push dx
	call limpaConsole
	call limpaBuffer
	mov cx, 8			;n�mero de caracteres
	mov bx, 0
	mov dh, 27			;linha 0-29
	mov dl, 6			;coluna 0-79
	vitoriaX2:
		call cursor
		mov al,[bx+vencedorX]
		call caracter
		inc bx			;proximo caracter
		inc dl			;avanca a coluna
		loop vitoriaX2
	pop	dx
	pop	bx
	jmp fimdejogo

checaEmpate:
	cmp byte [tabuleiro], ' '
	je existeJogada
	cmp byte [tabuleiro + 1], ' '
	je existeJogada
	cmp byte [tabuleiro + 2], ' '
	je existeJogada
	cmp byte [tabuleiro + 3], ' '
	je existeJogada
	cmp byte [tabuleiro + 4], ' '
	je existeJogada
	cmp byte [tabuleiro + 5], ' '
	je existeJogada
	cmp byte [tabuleiro + 6], ' '
	je existeJogada
	cmp byte [tabuleiro + 7], ' '
	je existeJogada
	cmp byte [tabuleiro + 8], ' '
	je existeJogada
	jmp empatou
	existeJogada:
		ret

checaVitoriaX:
	push ax
	push bx
	push cx
	mov al, 'X'
	linha1:
		cmp byte [tabuleiro], al
		jne linha2
		cmp byte [tabuleiro + 1], al
		jne linha2
		cmp byte [tabuleiro + 2], al
		jne linha2
		mov bx, 1
		push bx
		mov bx, 2
		push bx
		mov bx, 3
		push bx
		call desenha_linha
		call vitoriaX
	linha2:
		cmp byte [tabuleiro + 3], al
		jne linha3
		cmp byte [tabuleiro + 4], al
		jne linha3
		cmp byte [tabuleiro + 5], al
		jne linha3
		mov bx, 4
		push bx
		mov bx, 5
		push bx
		mov bx, 6
		push bx
		call desenha_linha
		call vitoriaX
	linha3:
		cmp byte [tabuleiro + 6], al
		jne coluna1
		cmp byte [tabuleiro + 7], al
		jne coluna1
		cmp byte [tabuleiro + 8], al
		jne coluna1
		mov bx, 7
		push bx
		mov bx, 8
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaX
	coluna1:
		cmp byte [tabuleiro], al
		jne coluna2
		cmp byte [tabuleiro + 3], al
		jne coluna2
		cmp byte [tabuleiro + 6], al
		jne coluna2
		mov bx, 1
		push bx
		mov bx, 4
		push bx
		mov bx, 7
		push bx
		call desenha_linha
		call vitoriaX
	coluna2:
		cmp byte [tabuleiro + 1], al
		jne coluna3
		cmp byte [tabuleiro + 4], al
		jne coluna3
		cmp byte [tabuleiro + 7], al
		jne coluna3
		mov bx, 2
		push bx
		mov bx, 5
		push bx
		mov bx, 8
		push bx
		call desenha_linha
		call vitoriaX
	coluna3:
		cmp byte [tabuleiro + 2], al
		jne diagonal1
		cmp byte [tabuleiro + 5], al
		jne diagonal1
		cmp byte [tabuleiro + 8], al
		jne diagonal1
		mov bx, 3
		push bx
		mov bx, 6
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaX
	diagonal1:
		cmp byte [tabuleiro], al
		jne diagonal2
		cmp byte [tabuleiro + 4], al
		jne diagonal2
		cmp byte [tabuleiro + 8], al
		jne diagonal2
		mov bx, 1
		push bx
		mov bx, 5
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaX
	diagonal2:
		cmp byte [tabuleiro + 2], al
		jne fim
		cmp byte [tabuleiro + 4], al
		jne fim
		cmp byte [tabuleiro + 6], al
		jne fim
		mov bx, 3
		push bx
		mov bx, 5
		push bx
		mov bx, 7
		push bx
		call desenha_linha
		call vitoriaX
	fim:
		pop cx
		pop bx
		pop ax
		ret

checaVitoriaO:
	push ax
	push bx
	push cx
	mov al, 'O'
	linha1c:
		cmp byte [tabuleiro], al
		jne linha2c
		cmp byte [tabuleiro + 1], al
		jne linha2c
		cmp byte [tabuleiro + 2], al
		jne linha2c
		mov bx, 1
		push bx
		mov bx, 2
		push bx
		mov bx, 3
		push bx
		call desenha_linha
		call vitoriaO
	linha2c:
		cmp byte [tabuleiro + 3], al
		jne linha3c
		cmp byte [tabuleiro + 4], al
		jne linha3c
		cmp byte [tabuleiro + 5], al
		jne linha3c
		mov bx, 4
		push bx
		mov bx, 5
		push bx
		mov bx, 6
		push bx
		call desenha_linha
		call vitoriaO
	linha3c:
		cmp byte [tabuleiro + 6], al
		jne coluna1c
		cmp byte [tabuleiro + 7], al
		jne coluna1c
		cmp byte [tabuleiro + 8], al
		jne coluna1c
		mov bx, 7
		push bx
		mov bx, 8
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaO
	coluna1c:
		cmp byte [tabuleiro], al
		jne coluna2c
		cmp byte [tabuleiro + 3], al
		jne coluna2c
		cmp byte [tabuleiro + 6], al
		jne coluna2c
		mov bx, 1
		push bx
		mov bx, 4
		push bx
		mov bx, 7
		push bx
		call desenha_linha
		call vitoriaO
	coluna2c:
		cmp byte [tabuleiro + 1], al
		jne coluna3c
		cmp byte [tabuleiro + 4], al
		jne coluna3c
		cmp byte [tabuleiro + 7], al
		jne coluna3c
		mov bx, 2
		push bx
		mov bx, 5
		push bx
		mov bx, 8
		push bx
		call desenha_linha
		call vitoriaO
	coluna3c:
		cmp byte [tabuleiro + 2], al
		jne diagonal1c
		cmp byte [tabuleiro + 5], al
		jne diagonal1c
		cmp byte [tabuleiro + 8], al
		jne diagonal1c
		mov bx, 3
		push bx
		mov bx, 6
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaO
	diagonal1c:
		cmp byte [tabuleiro], al
		jne diagonal2c
		cmp byte [tabuleiro + 4], al
		jne diagonal2c
		cmp byte [tabuleiro + 8], al
		jne diagonal2c
		mov bx, 1
		push bx
		mov bx, 5
		push bx
		mov bx, 9
		push bx
		call desenha_linha
		call vitoriaO
	diagonal2c:
		cmp byte [tabuleiro + 2], al
		jne fimc
		cmp byte [tabuleiro + 4], al
		jne fimc
		cmp byte [tabuleiro + 6], al
		jne fimc
		mov bx, 3
		push bx
		mov bx, 5
		push bx
		mov bx, 7
		push bx
		call desenha_linha
		call vitoriaO
	fimc:
		pop cx
		pop bx
		pop ax
		ret

;ax = linha, bx = coluna
desenha_x:
	push ax
	push bx
	push cx

	mov ax, [buffer + 2]	;coluna
	sub ax, 48				;converte para num
	dec ax
	xor ah, ah
	
	mov bl, 104
	mul bl

	mov bx, 164				;x base

	add bx, ax
	add bx, 52				;centro do X
	
	mov ax, [buffer + 1]	;linha
	sub ax, 48				;converte para num
	dec ax
	xor ah, ah
	
	mov cl, 104
	mul cl

	mov cx, 458			;y base

	sub cx, ax
	sub cx, 52			;centro do Y
	
	;(bx, cx) = centro do X
	
	add bx, 40
	add cx, 40
	push bx
	push cx
	sub bx, 80
	sub cx, 80
	push bx
	push cx

	call line

	add cx, 80
	push bx
	push cx
	add bx, 80
	sub cx, 80
	push bx
	push cx

	call line


	pop cx
	pop bx
	pop ax
	ret

;ax = linha, bx = coluna
desenha_o:
	push ax
	push bx

	mov ax, [buffer + 2]	;coluna
	sub ax, 48				;converte para num
	dec ax
	xor ah, ah
	
	mov bl, 104
	mul bl

	mov bx, 164				;x base

	add bx, ax
	add bx, 52
	
	push bx

	
	mov ax, [buffer + 1]	;linha
	sub ax, 48				;converte para num
	dec ax
	xor ah, ah
	
	mov bl, 104
	mul bl

	mov bx, 458			;y base

	sub bx, ax
	sub bx, 52
	
	push bx

	mov bx, 40
	push bx
	call circle

	pop bx
	pop ax
	ret

;[(x1, y1), (x2, y2)] == [(bx, cx), (dx, si)]
desenha_retangulo:
		mov		ax, bx
		push		ax
		mov		ax, cx
		push		ax
		mov		ax, dx
		push		ax
		mov		ax, cx
		push		ax
		call	line

		mov		ax, bx
		push		ax
		mov		ax, si
		push		ax
		mov		ax, dx
		push		ax
		mov		ax, si
		push		ax
		call	line

		mov		ax, bx
		push		ax
		mov		ax, cx
		push		ax
		mov		ax, bx
		push		ax
		mov		ax, si
		push		ax
		call	line

		mov		ax, dx
		push		ax
		mov		ax, si
		push		ax
		mov		ax, dx
		push		ax
		mov		ax, cx
		push		ax
		call	line
		ret

escreve_horizontais:
		mov		ax, 164
		push		ax
		mov		ax, 256
		push		ax
		mov		ax, 476
		push		ax
		mov		ax, 256
		push		ax
		call	line

		mov		ax, 164
		push		ax
		mov		ax, 352
		push		ax
		mov		ax, 476
		push		ax
		mov		ax, 352
		push		ax
		call	line
		ret

escreve_verticais:
		mov		ax, 268
		push		ax
		mov		ax, 152
		push		ax
		mov		ax, 268
		push		ax
		mov		ax, 448
		push		ax
		call	line

		mov		ax, 372
		push		ax
		mov		ax, 152
		push		ax
		mov		ax, 372
		push		ax
		mov		ax, 448
		push		ax
		call	line
		ret


escreve_colunas:
		push 	cx
		mov 	cx,	3
		mov     dl, 21			;coluna 0-79
		call 	escreve_linha
		pop 	cx
		add 	dh, 6
		loop 	escreve_colunas
		ret

escreve_linha:
		call	escreve_quadrado
		add	 	dl, 12
		loop 	escreve_linha
		ret

escreve_quadrado:
		call	cursor
    	mov     al,[bx+mens]
		call	caracter
		inc     bx
    	inc 	dl
		call	cursor
    	mov     al,[bx+mens]
		call	caracter
		inc    	bx
		ret


segment data
vermelho		equ		4
branco			equ		7	
mens    		db  	'111213212223313233'
erro1			db		'Comando Invalido'
erro2			db		'Jogada Invalida'
erroO			db		'Vez do X'
erroX			db		'Vez do O'
lastPLayer		db		0
tabuleiro		db		'         '
vencedorX		db		'X Venceu'
vencedorO		db		'O Venceu'
empate   		db  	'Empate'
msgfim			db		'Fim de Jogo. Pressione "c" para jogar novamente ou "s" para sair'
buffer      	resb	80  		
segment stack stack
    		resb 		512
stacktop:
