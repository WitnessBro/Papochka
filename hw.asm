extrn Main_hw:near
.model tiny
.code
org 100h
main: jmp start
helpmes	db  'Help Message',10,13
		db	10, 13, 9, 'Key for my program: ', 10, 13
		db	9, 218,8 dup (196),194,8 dup (196),194,43 dup (196),191,10, 13
		db	9, 179, 32, '  KEY  ', 179, '  NUM   ', 179, 20 dup (32),'VALUE',18 dup (32),179, 10, 13 
		db	9, 195,8 dup (196),197,8 dup (196),197,43 dup (196),180,10, 13
		db	9,  179,32,'-?     ',179,9,2 dup (32), 179, 15 dup (32), 'Print Help Message',10 dup (32),179, 10, 13
		db	9, 195,8 dup (196),197,8 dup (196),197,43 dup (196),180,10, 13
		db	 9,  179,32,'-c[Num]',179,  ' 0 or 1 ',179 ,'     0 - clean monitor, 1 - no clean',7 dup (32), 179, 10, 13
		db	9, 195,8 dup (196),197,8 dup (196),197,43 dup (196),180,10, 13
		db	 9,  179,32,'-l[Num]',179, ' 0 or 1 ',179,  '     0 - light, 1 - without light',10 dup (32), 179, 10, 13
		db	9, 195,8 dup (196),197,8 dup (196),197,43 dup (196),180,10, 13
		db	 9,  179,32,'-v[Num]',179, ' 0..3,7 ',179, 9, '        Active videoMode',14 dup (32), 179, 10, 13
		db	9, 195,8 dup (196),197,8 dup (196),197,43 dup (196),180,10, 13
		db	 9, 179,32,'-p[Num]',179, '  0..7  ',179, 9,'           Active page ',15 dup (32), 179, 10, 13
		db	9, 192,8 dup (196),193,8 dup (196),193,43 dup (196),217,10, 13
		db ' Use without [] !!!'
		db	10,9,9,9, 'Valid page in videomode:'
		db	10,13,9,9,9, '0 - (0..7)'
		db	10,13,9,9,9, '1 - (0..7)'
		db	10,13,9,9,9, '2 - (0..3)'
		db	10,13,9,9,9, '3 - (0..3)'
		db	10,13,9,9,9, '7 - (0..7)','$'
OldPage db 0
OldVideo db 0
check db 8,8,4,4,0,0,0,8,100 dup(0)	
centr db 10, 10, 46, 46, 0, 0, 0, 46
light db 1
clean db 0
VideoMode db 3
PageNumber db 0
errorMessage db 9,9,9,'Wrong Parametrs!!!',10,10,13,'$'
WrongPage db 9,9,9,'Wrong Page!!!',10,10,13,'$'
args	db 32 dup (15), 14, 12 dup (15), 9, 15, 15, 0,1,2,3,4,5,6,7, 7 dup(15), 8, 35 dup (15), 10, 8 dup (15),11,3 dup (15), 12, 5 dup (15),13, 100 dup (15)   ; слэш, цифры, вопрос, Clean, Light, Page, Video  
automat db  0, 11, 11, 11, 11, 11, 11, 11, 11, 16, 11, 11, 11, 11, 0, 11, \
		   11, 11, 11, 11, 11, 11, 11, 11, 10, 11, 32, 48, 64, 80, 11, 11,  \
			0, 1, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, \
			0, 1, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, \
			0, 1, 2, 3, 4, 5, 6, 7, 11, 11, 11, 11, 11, 11, 11, 11, \
			0, 1, 2, 3, 4, 5, 6, 7, 11, 11, 11, 11, 11, 11, 11, 11
metki dw 0,0, clean, light,  PageNumber, VideoMode
; trash  db 100 dup (0)
save_memory db 25*160d dup (0)
 ErrorMes: 
	lea dx, errorMessage
	mov ah, 9
	int 21h
HELP:
	mov ah, 9
	lea dx, helpmes
	int 21h
	int 20h
start:
	push es
	mov ax, 0
	mov es, ax
	mov al, es:[449h]
	mov bh, es:[462h]
	mov [OldPage], bh
	mov [OldVideo], al
	push bx
	push ax
	call SizeMode
	pop bx
	pop bx
	mov cx, 2000d
	lea si, save_memory
	mov bx, 0
saver:
	mov dx, es:[bx]
	mov [si], dx
	inc si
	add bx, 2
	loop saver
	pop es
	mov cx,  es:[80h]
	xor ch, ch
	cmp cx, 0
	je ENDloop
	mov si, 82h
	mov dx, 0
metka:
	lea bx, args
	mov al, es:[si]
	cmp al, 0dh
	je next2
	xlat
	lea bx, automat
	add bx, dx
	xlat
	cmp al, 10
	je HELP
	cmp al, 11
	je ErrorMes
	cmp dl, 32
	jl next
	push si
	lea bx, metki
	shr dx, 4
	mov si, dx
	add si, si
	mov di, [bx+si]
	mov [di], al
	xor dx, dx
	pop si
	jmp next2
next:	
	mov dl, al
next2:
	inc si
	loop metka
ENDLoop:
	lea si, VideoMode
	mov ax, [si]
	xor ah, ah
	lea bx, check
	xlat
	lea bx, PageNumber
	mov bx, [bx]
	cmp bl, al
	jl _
	jmp ErrorMes
_:
	lea si, VideoMode
	mov ax, [si]
	mov ah, 00h
	int 10h
	push ax
	push ax
	lea si, PageNumber
	mov ax, [si]
	mov ah, 05h
	int 10h
	xor ah, ah
	pop bx
	push ax
	mov ax, bx
	lea bx, centr
	xlat
	push ax
	mov bl, [light]
	mov ax, 1003h
	int 10h
	mov al, [VideoMode]
	mov bl, [PageNumber]
	push bx
	push ax
	call SizeMode
	pop bx
	pop ax
	push es
	call main_hw
	mov ah, 0
	int 16h
	mov ah ,00h
	mov al, [oldvideo]
	int 10h
	mov ah, 05h
	mov al, [oldpage]
	int 10h
	mov bl, [oldpage]
	mov al, [oldvideo]
	cmp [clean], 0
	je exit
	push bx
	push ax
	call SizeMode
	mov cx, 2000d
	mov bx, 0
	lea si, save_memory
	mov ax, 7
saver2:
	mov dx, [si]
	mov es:[bx], dl	
	mov es:[bx+1], ax
	inc si
	add bx, 2
	loop saver2
exit:
	int 20h
	ret
er:
mov ah, 9
lea dx, WrongPage
int 21h
jmp HELP

proc SizeMode
xor ch, ch
	mov bp, sp
	mov al, [bp+2]
	cmp al, 0
	je Video_0_or_1
	cmp al, 1
	je Video_0_or_1
	cmp al, 7
	jne Video_3_or_4
	mov ax, 0b000h
	mov cl, [bp+4]
	shl cx, 8
	jmp over
Video_0_or_1:
	mov cl, [bp+4]
	shl cx, 7
	mov ax, 47104
	jmp over
Video_3_or_4:	
	mov cl, [bp+4]
	shl cx, 8 
	mov ax, 0b800h
over:
	add ax, cx
	mov es, ax
	ret
endp SizeMode
end main