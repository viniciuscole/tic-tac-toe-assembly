segment code
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

	reset:
		cmp bx, 1
		je ..start
		jmp comandoInvalido
	
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
		je reset
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

	; pop dx
	; pop cx
	; pop bx
	; pop ax


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

	
	; pop dx
	; pop cx
	; pop bx
	; pop ax

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
	jmp jogo

jogadaInvalida:
	push bx
	push dx
	call limpaConsole
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
	pop	bx
	call limpaBuffer
	jmp jogo
comandoInvalido:
	push bx
	push dx
	call limpaConsole
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
	call limpaBuffer
	jmp jogo


limpaBuffer:
	apaga:
		cmp bx, 0
		je 	retorna
		dec dl
		call cursor
		mov	al, 0x00
		call caracter
		mov [buffer + bx], al
		dec bx
		jmp apaga
	retorna:
		ret

limpaConsole:
	push bx
	push dx
	mov	dh, 27
	mov	dl, 46
	mov cx, 40
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
		pop	bx
		ret

; FUNÇÕES ==========================================================================================================
; FUNÇÕES ==========================================================================================================
; FUNÇÕES ==========================================================================================================

vitoriaO:
	push bx
	push dx
	call limpaConsole
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
		loop vitoriaX2
	pop	dx
	pop	bx
	call limpaBuffer
	jmp continua
vitoriaX:
	push bx
	push dx
	call limpaConsole
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
	call limpaBuffer
	jmp continua

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
		call vitoriaX
	linha2:
		cmp byte [tabuleiro + 3], al
		jne linha3
		cmp byte [tabuleiro + 4], al
		jne linha3
		cmp byte [tabuleiro + 5], al
		jne linha3
		call vitoriaX
	linha3:
		cmp byte [tabuleiro + 6], al
		jne coluna1
		cmp byte [tabuleiro + 7], al
		jne coluna1
		cmp byte [tabuleiro + 8], al
		jne coluna1
		call vitoriaX
	coluna1:
		cmp byte [tabuleiro], al
		jne coluna2
		cmp byte [tabuleiro + 3], al
		jne coluna2
		cmp byte [tabuleiro + 6], al
		jne coluna2
		call vitoriaX
	coluna2:
		cmp byte [tabuleiro + 1], al
		jne coluna3
		cmp byte [tabuleiro + 4], al
		jne coluna3
		cmp byte [tabuleiro + 7], al
		jne coluna3
		call vitoriaX
	coluna3:
		cmp byte [tabuleiro + 2], al
		jne diagonal1
		cmp byte [tabuleiro + 5], al
		jne diagonal1
		cmp byte [tabuleiro + 8], al
		jne diagonal1
		call vitoriaX
	diagonal1:
		cmp byte [tabuleiro], al
		jne diagonal2
		cmp byte [tabuleiro + 4], al
		jne diagonal2
		cmp byte [tabuleiro + 8], al
		jne diagonal2
		call vitoriaX
	diagonal2:
		cmp byte [tabuleiro + 2], al
		jne fim
		cmp byte [tabuleiro + 4], al
		jne fim
		cmp byte [tabuleiro + 6], al
		jne fim
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
		call vitoriaO
	linha2c:
		cmp byte [tabuleiro + 3], al
		jne linha3c
		cmp byte [tabuleiro + 4], al
		jne linha3c
		cmp byte [tabuleiro + 5], al
		jne linha3c
		call vitoriaO
	linha3c:
		cmp byte [tabuleiro + 6], al
		jne coluna1c
		cmp byte [tabuleiro + 7], al
		jne coluna1c
		cmp byte [tabuleiro + 8], al
		jne coluna1c
		call vitoriaO
	coluna1c:
		cmp byte [tabuleiro], al
		jne coluna2c
		cmp byte [tabuleiro + 3], al
		jne coluna2c
		cmp byte [tabuleiro + 6], al
		jne coluna2c
		call vitoriaO
	coluna2c:
		cmp byte [tabuleiro + 1], al
		jne coluna3c
		cmp byte [tabuleiro + 4], al
		jne coluna3c
		cmp byte [tabuleiro + 7], al
		jne coluna3c
		call vitoriaO
	coluna3c:
		cmp byte [tabuleiro + 2], al
		jne diagonal1c
		cmp byte [tabuleiro + 5], al
		jne diagonal1c
		cmp byte [tabuleiro + 8], al
		jne diagonal1c
		call vitoriaO
	diagonal1c:
		cmp byte [tabuleiro], al
		jne diagonal2c
		cmp byte [tabuleiro + 4], al
		jne diagonal2c
		cmp byte [tabuleiro + 8], al
		jne diagonal2c
		call vitoriaO
	diagonal2c:
		cmp byte [tabuleiro + 2], al
		jne fimc
		cmp byte [tabuleiro + 4], al
		jne fimc
		cmp byte [tabuleiro + 6], al
		jne fimc
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
;***************************************************************************
;
;   fun��o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o caracter escrito na posi��o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
    		mov     	ah,9
    		mov     	bh,0
    		mov     	cx,1
   		mov     	bl,[cor]
    		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun��o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub		dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
;_____________________________________________________________________________
;    fun��o circle
;	 push xc; push yc; push r; call circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor
circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	
	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov 	dx,bx	
	add		dx,cx       ;ponto extremo superior
	push    ax			
	push	dx
	call plot_xy
	
	mov		dx,bx
	sub		dx,cx       ;ponto extremo inferior
	push    ax			
	push	dx
	call plot_xy
	
	mov 	dx,ax	
	add		dx,cx       ;ponto extremo direita
	push    dx			
	push	bx
	call plot_xy
	
	mov		dx,ax
	sub		dx,cx       ;ponto extremo esquerda
	push    dx			
	push	bx
	call plot_xy
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	
;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay:				;loop
	mov		si,di
	cmp		si,0
	jg		inf       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar
inf:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar:	
	mov		si,dx
	add		si,ax
	push    si			;coloca a abcisa x+xc na pilha
	mov		si,cx
	add		si,bx
	push    si			;coloca a ordenada y+yc na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,dx
	push    si			;coloca a abcisa xc+x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do s�timo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc+x na pilha
	call plot_xy		;toma conta do segundo octante
	mov		si,ax
	add		si,cx
	push    si			;coloca a abcisa xc+y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do oitavo octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	add		si,cx
	push    si			;coloca a ordenada yc+y na pilha
	call plot_xy		;toma conta do terceiro octante
	mov		si,ax
	sub		si,dx
	push    si			;coloca a abcisa xc-x na pilha
	mov		si,bx
	sub		si,cx
	push    si			;coloca a ordenada yc-y na pilha
	call plot_xy		;toma conta do sexto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	sub		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quinto octante
	mov		si,ax
	sub		si,cx
	push    si			;coloca a abcisa xc-y na pilha
	mov		si,bx
	add		si,dx
	push    si			;coloca a ordenada yc-x na pilha
	call plot_xy		;toma conta do quarto octante
	
	cmp		cx,dx
	jb		fim_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;    fun��o full_circle
;	 push xc; push yc; push r; call full_circle;  (xc+r<639,yc+r<479)e(xc-r>0,yc-r>0)
; cor definida na variavel cor					  
full_circle:
	push 	bp
	mov	 	bp,sp
	pushf                        ;coloca os flags na pilha
	push 	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di

	mov		ax,[bp+8]    ; resgata xc
	mov		bx,[bp+6]    ; resgata yc
	mov		cx,[bp+4]    ; resgata r
	
	mov		si,bx
	sub		si,cx
	push    ax			;coloca xc na pilha			
	push	si			;coloca yc-r na pilha
	mov		si,bx
	add		si,cx
	push	ax		;coloca xc na pilha
	push	si		;coloca yc+r na pilha
	call line
	
		
	mov		di,cx
	sub		di,1	 ;di=r-1
	mov		dx,0  	;dx ser� a vari�vel x. cx � a variavel y
	

;aqui em cima a l�gica foi invertida, 1-r => r-1
;e as compara��es passaram a ser jl => jg, assim garante 
;valores positivos para d

stay_full:				;loop
	mov		si,di
	cmp		si,0
	jg		inf_full       ;caso d for menor que 0, seleciona pixel superior (n�o  salta)
	mov		si,dx		;o jl � importante porque trata-se de conta com sinal
	sal		si,1		;multiplica por doi (shift arithmetic left)
	add		si,3
	add		di,si     ;nesse ponto d=d+2*dx+3
	inc		dx		;incrementa dx
	jmp		plotar_full
inf_full:	
	mov		si,dx
	sub		si,cx  		;faz x - y (dx-cx), e salva em di 
	sal		si,1
	add		si,5
	add		di,si		;nesse ponto d=d+2*(dx-cx)+5
	inc		dx		;incrementa x (dx)
	dec		cx		;decrementa y (cx)
	
plotar_full:	
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	add		si,cx
	push	si		;coloca a abcisa y+xc na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call 	line
	
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	add		si,dx
	push	si		;coloca a abcisa xc+x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha			
	mov		si,bx
	sub		si,cx
	push    si		;coloca a ordenada yc-y na pilha
	mov		si,ax
	sub		si,dx
	push	si		;coloca a abcisa xc-x na pilha	
	mov		si,bx
	add		si,cx
	push    si		;coloca a ordenada yc+y na pilha	
	call	line
	
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha			
	mov		si,bx
	sub		si,dx
	push    si		;coloca a ordenada yc-x na pilha
	mov		si,ax
	sub		si,cx
	push	si		;coloca a abcisa xc-y na pilha	
	mov		si,bx
	add		si,dx
	push    si		;coloca a ordenada yc+x na pilha	
	call	line
	
	cmp		cx,dx
	jb		fim_full_circle  ;se cx (y) est� abaixo de dx (x), termina     
	jmp		stay_full		;se cx (y) est� acima de dx (x), continua no loop
	
	
fim_full_circle:
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
	pop		bp
	ret		6
;-----------------------------------------------------------------------------
;
;   fun��o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m�dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx
		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8

segment data

cor				db		branco_intenso
preto			equ		0
azul			equ		1
verde			equ		2
cyan			equ		3
vermelho		equ		4
magenta			equ		5
marrom			equ		6
branco			equ		7
cinza			equ		8
azul_claro		equ		9
verde_claro		equ		10
cyan_claro		equ		11
rosa			equ		12
magenta_claro	equ		13
amarelo			equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   		dw  	0
coluna  		dw  	0
deltax			dw		0
deltay			dw		0	
mens    		db  	'111213212223313233'
erro1			db		'Comando Invalido'
erro2			db		'Jogada Invalida'
erroO			db		'Vez do X'
erroX			db		'Vez do O'
lastPLayer		db		0
tabuleiro		db		'        X'
vencedorX		db		'X Venceu'
vencedorO		db		'O Venceu'
buffer      	resb	80  		
segment stack stack
    		resb 		512
stacktop:
