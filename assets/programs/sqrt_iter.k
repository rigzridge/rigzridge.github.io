%=-=-=-=-=%
% Sq root %
%=-=-=-=-=%

% s = (s + n/s)/2

% Set stack pointer
mem 0xff 0xfe

%nop

lcd 0x38
lcd 0x0f
%lcd 0x1

% initialize #
mem $n 0x3c1
mem $s 0x0
mem $old 0x0

.start
% Use n//2 as initial guess
ldf $n
fdx
saf $s
%saf $old
clr $cnt

% print answer
lcd 0x86
ldf $n  % push input
sri 0x66
jmp .mem2dec

.nextiter
% $out,$mod = divide($n,$div)
cpu 0x2
pud $n
pud $s
jmp .div

ldf $s   
fad $out % s += n/s
fdx      % s/= 2
saf $s

inc $cnt
ldf $cnt
mem $lim 0x5
cwf $lim
jmp 0x3 .print 
jmp .nextiter

%cwf $old
%jmp 0x3 .print 
%saf $old
%jmp .nextiter

.print
% print answer
lcd 0xc6
ldf $s  % push input
sri 0x66
jmp .mem2dec

inc $n
jmp .start

% Print memory location data as hex character on LCD
%=========
.mem2dec
%=========

mem $m1000 0x3e8
mem $m100 0x64
mem $m10 0xa
mem $m1 0x1

mem $char 0x0
saf $char

% n//1000
%cpu 0x2
%pud $char
%pud $m1000
%jmp .div

%ldf $out
mem $n2ascii 0x230
%fad $n2ascii
%lcf

% n//100
cpu 0x2
pud $char
pud $m100
jmp .div

ldf $out
fad $n2ascii
lcf

% n//10
cpu 0x2
pud $mod
pud $m10
jmp .div

ldf $out
fad $n2ascii
lcf

% Last
ldf $mod
fad $n2ascii
lcf

% jump out 
sro 0x66
%=========


%------------------
% divide($a,$b)
%------------------
% $out = a/b
% $mod = a%b
.div

% Set variable addresses
mem $a 0x0
mem $b 0x0
mem $dum 0x0
mem $out 0x0
mem $mod 0x0

% pop inputs
pod $b % get divisor
pod $a % get n

clr $out
ldf $a
saf $mod % copy a to $mod

% check if a>b
.check
ldf $mod
cwf $b
jmp 0x2 .done % b>a, done
jmp 0x3 .inc % a=b

.sub 
fsu $b
saf $mod
inc $out % increment counter
jmp .check

% Mod == 0, divisor
.inc
inc $out
clr $mod

.done
cpo
%-------------