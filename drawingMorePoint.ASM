;

format MZ
stack stk:256
entry codseg:main
VideoB_Seg EQU 0A000h; Okrelenie segmentu buforu Video
;------------------ Segment danych ---------------------------
segment sdat use16
kol db 09h
x  dw 50
y  dw 100
;dlugosc=10
;--------------- Koniec segmentu danych ***
;----------------- Segment stosu -----------------------------
segment stk use16
db 256 dup (?)
;----------------- Koniec segmentu stosu
;----------------- Segment programu -------------------------
segment codseg use16
main: push ds
push bx
mov bx,sdat
mov ds,bx
; Wywoanie funkcji BIOS'u w celu zmiany trybu pracy monitora na graficzny
mov ah,0
mov al,10h; Tryb 640 X 350 ilo kolorw 16
int 10h

;mov si,dlugosc
mov cx,50

petla:
push cx
mov cx,10
     petla1:
     call AA
     ;inc [x]
      add [x],2
     loop petla1
inc [y]
pop cx
loop petla


pop bx
pop ds
mov ah,1
int 21h
mov ax,0003h
int 10h
mov ah,1
int 21h
mov ax,4c00h
int 21h
ret
AA:


push bp ; Zachowanie wartoci rejestru BP na stosie
; okreœlenie wsprzdnych pixel'a i obliczenie jego adresu
push cx
push ax
push bx

	mov ax,[y]; okrelenie wsprzdnej Y pixel'a
	mov bx,[x]; okrelenie wsplrzdnej X pixel'a
	mov cl,bl ; mniej znaczcy bajt wsprzdnej X do BX
	push dx
	mov dx,80; wprowadznie do DX iloci blokw pixel'i w jednej linii
	mul dx; (dx,ax)<-dx*ax
	;przesunicie o AX 1-go bloku potrzebnej linii o wsprzdnej Y
	pop dx
	shr bx,1;
	shr bx,1;
	shr bx,1; przesunicie BX o trzy pozycje w prawo
	add bx,ax; w BX znajduje si przesunicie bloku,
	; który zawiera potrzebny pixel
	mov ax,VideoB_Seg; adowanie do AX adresu segmentu buforu Video
	mov es,ax; rejestr ES bdzie zawiera adres segmentu buforu Video
	and cl,7 ; wyodrbnienie numeru pixel'a w bloku
	xor cl,7 ; inwersja bitu
	mov ah,1 ; przygotowanie maski bitu
	shl ah,cl; przesunicie maski na odpowiedni pozycj
	; mov ah,0FFh
	; obsuga rejestrw kontrolera graficznego
	mov dx,3CEh; zadanie adresu portu kontrolera graficznego
	mov al,8 ; okrelenie numeru rejestru bitowej maski
	out dx,ax ; zmiana rejestru maski bitowej
	mov ax,0005h;
	out dx,ax ; zadanie wartoci rejestru trybu
	mov ah,0 ;
	mov al,3 ;
	out dx,ax ; zadanie wartoci rejestru cyklicznego przesunicia
       ; mov ax,0D00h;
	mov ah,[kol]
	mov al,0
	out dx,ax ; zadanie wartoci rejestru ustawi/resetowa
	mov ax,0F01h;
	out dx,ax ; zadanie wartoci rejestru ustawi/resetowa
	; zmiana wartoci pixel'a
	or [es:bx],al;
	;inc si
pop bp
pop bx
pop ax
pop cx
ret
