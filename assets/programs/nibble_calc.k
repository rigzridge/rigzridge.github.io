%=-=-=-=-=-=-=-=-=-=-%
% Nibble calculator! %
%=-=-=-=-=-=-=-=-=-=-%
% Select one nibble,
% then an operation,
% then another nibble!
% Returns op(x,y) & 0xF
% --------------------
% Left/right change
% nibble or operation,
% Down (both buttons)
% selects/calculates
% --------------------
% Support for:
% Plus  (+)
% Minus (-)
% And   (&)
% Or    (|)
% Xor   (^)
%=-=-=-=-=-=-=-=-=-=-%

nop

% initialize lcd
lcd 0x38
lcd 0x0c
lcd 0x1

% allocate memory
mem $char
mem $loc

% set stack pointer
mem 0xff 0xff

.start
% reset cursor
clr $loc
lcd 0x80

.update
mem $lcdPnt 0x40
ldf $lcdPnt
.printChar
for $char
lfp
lcd 0x10

.poll
% handle input
ldf $char
con $both
mem $both 0x300
jmp 0x3 .select
%
con $right
mem $right 0x100
jmp 0x3 .right
%
con $left
mem $left 0x200
jmp 0x3 .left
%
jmp .poll

.select
lcd 0x14
psh $char
inc $loc
.refresh
ldf $loc
jfo 0x1 .showOp
jmp .update

.right
fin
jmp .mask

.left
fde 
.mask
mem $mask 0xf
fan $mask

% save and print
saf $char
jmp .refresh

.showOp
mem $three 0x3
cwf $three
jmp 0x3 .calc
mem $opPnt 0x60
ldf $opPnt
jmp .printChar

.calc
% perform operation
mem $a
mem $b 
mem $op
pop $b
pop $op
pop $a

mem $opadd 0x0
mem $opsub 0x1
mem $opand 0x2
mem $opor  0x3
mem $opxor 0x4
ldf $a
ldb $op
cwb $opadd
jmp 0x3 .add
cwb $opsub
jmp 0x3 .sub
cwb $opand
jmp 0x3 .and
cwb $opor
jmp 0x3 .or
cwb $opxor
jmp 0x3 .xor
jmp .start

.add
fad $b
jmp .printcalc

.sub
fsu $b
jmp .printcalc

.and
fan $b
jmp .printcalc

.xor
fxo $b
jmp .printcalc

.or
for $b

.printcalc
lcd 0xc9
fan $mask
for $lcdPnt
lfp

jmp .start

%-------------
% Hex to ascii
%-------------
mem 0x40 0x230
mem 0x41 0x231
mem 0x42 0x232
mem 0x43 0x233
mem 0x44 0x234
mem 0x45 0x235
mem 0x46 0x236
mem 0x47 0x237
mem 0x48 0x238
mem 0x49 0x239
mem 0x4a 0x241
mem 0x4b 0x242
mem 0x4c 0x243
mem 0x4d 0x244
mem 0x4e 0x245
mem 0x4f 0x246
%-------------

%-------------
% Hex to op
%-------------
mem 0x60 0x22b
mem 0x61 0x22d
mem 0x62 0x226
mem 0x63 0x27c
mem 0x64 0x25e
mem 0x65 0x23f
mem 0x66 0x23f
mem 0x67 0x23f
mem 0x68 0x23f
mem 0x69 0x23f
mem 0x6a 0x23f
mem 0x6b 0x23f
mem 0x6c 0x23f
mem 0x6d 0x23f
mem 0x6e 0x23f
mem 0x6f 0x23f
%-------------


