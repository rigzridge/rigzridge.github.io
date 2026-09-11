%=-=-=-=-=-=-=-=%
% Print decimal %
%=-=-=-=-=-=-=-=%

nop

% test char
mem $char 0x0

% set stack pointer
mem 0xff 0xfe

lcd 0x38
lcd 0x0f
lcd 0x1
lcd 0x80

.print
jmp .mem2dec

.next
lcd 0x80
inc $char
jmp .print


% Print memory location data as decimal character on LCD
%=========
.mem2dec
%=========

mem $m1000 0x3e8
mem $m100 0x64
mem $m10 0xa
mem $m1 0x1

% n//1000
% $div, $mod = divide($a,$b)
cpu 0x2
pud $char
pud $m1000
jmp .div

% n//100
cpu 0x2
pud $mod
pud $m100
jmp .div

% n//10
cpu 0x2
pud $mod
pud $m10
jmp .div

% Last
ldf $mod
mem $n2ascii 0x230
fad $n2ascii
lcf

% next #
jmp .next
%=========


%------------------
% divide($a,$b)
%------------------
% $div = a/b
% $mod = a%b
.div
% Initialize variables
mem $a 0x0
mem $b 0x0
mem $dum 0x0
mem $div 0x0
mem $mod 0x0

% pop inputs
pkd $b % get divisor
pop $dum
pkd $a % get n
pop $dum

clr $div
ldf $a
saf $mod % copy a to $mod

% check if a>b
.check
ldf $b
cwf $mod
jmp 0x2 .sub % a>b, subtract
jmp 0x3 .inc % a=b
jmp .done

.sub 
ldf $mod
fsu $b
saf $mod
inc $div % increment counter
jmp .check

% Mod == 0, divisor
.inc
inc $div
clr $mod

.done
ldf $div
mem $n2ascii 0x230
fad $n2ascii
lcf
cpo
%-------------