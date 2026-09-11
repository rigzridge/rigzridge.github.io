mem 0x40 0x1
mem $in 0x6

% set stack pointer
mem 0xff 0xff

nop

lcd 0x38
lcd 0x0f

.start
cpu 0x1
psh $in
jmp .fact

hlt

%==========
.fact
%==========

mem $OUT 0x0
mem $data 0x0
mem $dumadd 0x0
mem $nextadd 0x0

pek $data % Get input

ldf $data
mem $one 0x1
cwf $one 
jmp 0x3 .return1

% else call itself 

% push input-1 to stack
fde
saf $data

% recursive call
cpu 0x1
psh $data
jmp .fact

% fact(A) = A * fact(A-1)

% get previous from stack
pop $data

% call mult
cpu 0x2
pud $OUT
pud $data
jmp .mult

ldf $out
saf $OUT
lcd 0x1
sri 0x66
jmp .mem2char
cpo

.return1
mem $one 0x1
ldf $one
saf $OUT
pop $dumadd
cpo
%==========

%----------
.mult
%----------
mem $a 0x0
mem $b 0x0
mem $out 0x0

pod $b
pod $a

ldf $b
mem $zero 0x0
cwf $zero 
jmp 0x3 .return

% else call itself
fde
saf $b
cpu 0x2
pud $a
pud $b
jmp .mult

% mult(a,b) = a + mult(a,b-1)
ldf $a
fad $out
saf $out
cpo

.return
clr $out
cpo
%----------

% Print memory location data as hex character on LCD
%=========
.mem2char
%=========

% Third byte
ldf $OUT
ghf
for $lcdPnt
lfp 

% Second byte
ldf $OUT
mem $mask 0xF
gmf $mask
for $lcdPnt
lfp 

% First byte
ldf $OUT
fan $mask
for $lcdPnt
lfp 

% jump out 
sro 0x66
%=========

%-------------
% Hex to ascii
%-------------
.h2a
mem 0x90 0x230
mem 0x91 0x231
mem 0x92 0x232
mem 0x93 0x233
mem 0x94 0x234
mem 0x95 0x235
mem 0x96 0x236
mem 0x97 0x237
mem 0x98 0x238
mem 0x99 0x239
mem 0x9a 0x241
mem 0x9b 0x242
mem 0x9c 0x243
mem 0x9d 0x244
mem 0x9e 0x245
mem 0x9f 0x246

mem $lcdPnt 0x90
%-------------
