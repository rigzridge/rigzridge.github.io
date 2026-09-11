% collatz
nop 

ldf 0x80
%inf 

.start
% jump if odd
jfo 0x1 .checkone

% must be even
fdx
jmp .start

.checkone 
cwf 0x81 
jmp 0x3 .stop 

fmx % 2f 
aff % 2f + f
fin % 3f+1
jmp .start

.stop
hlt

mem 0x80 0x378
mem 0x81 0x01