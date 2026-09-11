%=-=-=-=-=%
% Print!  %
%=-=-=-=-=%

% Set stack pointer
mem 0xff 0xff

nop

% lcd ops in memory:
% initialize
lcd 0x38
lcd 0x0f
lcd 0x1

.start
mem $char 0x40
mem $loc 0x80

ldf $char

lcd 0xc7
sri 0x66
jmp .mem2char

lcd 0xcb
ldf $char
mem $q 0x200
fad $q
lcf

.poll
con $both
mem $both 0x300
jmp 0x3 .select

con $right
mem $right 0x100
jmp 0x3 .right

con $left
mem $left 0x200
jmp 0x3 .left

jmp .poll

.select
ldf $loc
lcf
psh $char
ldf $char
fad $q
lcf
inc $loc
jmp .poll

.right
ldf $char
mem $F 0xf
jfm 0x3 $F .resetLo 
mem $plusLo 0x1
fad $plusLo

.saveAndStart
saf $char
jmp .start

.resetLo
fsu $F
jmp .saveAndStart

.resetHi
mem $fixHi 0x60
fsu $fixHi
jmp .saveAndStart

.left
ldf $char
mem $seven 0x70
jfm 0x3 $seven .resetHi 

mem $plusHi 0x8
fad $plusHi

jmp .saveAndStart

hlt

% Print memory location data as hex character on LCD
%=========
.mem2char
%=========

% Second byte
ldf $char
mem $mask 0xF
gmf $mask
sri 0x77
jmp .h2a

% First byte
ldf $char
fan $mask
sri 0x77
jmp .h2a

% jump out 
sro 0x66
%=========

%-------------
% Hex to ascii
%-------------
.h2a
mem $nine 0xa
cwf $nine
jmp 0x2 .unda %jump if <10

mem $lcd1 0x237
fad $lcd1

.print
lcf 
sro 0x77

.unda
mem $lcd2 0x230
fad $lcd2
jmp .print
%-------------