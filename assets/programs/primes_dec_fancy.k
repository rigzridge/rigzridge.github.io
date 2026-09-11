%=-=-=-=-=%
% Primes! %
%=-=-=-=-=%

% Set stack pointer
mem 0xff 0xfe

% need a 2 every time
mem $two 0x2
mem $div
% initialize #
mem $n 0x1

%nop

% lcd ops in memory:
% initialize
mem 0xd1 0x38
mem 0xd2 0x0f
mem 0xd3 0x1
"Count:"
mem 0xd4 0x243
mem 0xd5 0x26f
mem 0xd6 0x275
mem 0xd7 0x26e
mem 0xd8 0x274
mem 0xd9 0x23a
"Prime:"
mem 0xda 0xc0
mem 0xdb 0x250
mem 0xdc 0x272
mem 0xdd 0x269
mem 0xde 0x26d
mem 0xdf 0x265
mem 0xe0 0x23a
"Div:"
mem 0xe1 0x8a
mem 0xe2 0x244
mem 0xe3 0x269
mem 0xe4 0x276
mem 0xe5 0x23a


% loop lcd ops
mem $start 0xd1
mem $end 0xe6
ldf $start  % load pointer
.loop
lfp       % lcd op
fin       % increment flip
cwf $end  % check lim
jmp 0x3 .next  % jump out
jmp .loop

.next
% Load 2 and inc #
ldf $two
saf $div
% n+=2
inc $n
%inc $n

% print count
lcd 0x86
ldf $n  % push input
sri 0x66
jmp .mem2dec

.newdiv
% check if a>2b
ldf $n
fdx 
cwf $div
jmp 0x2 .prime

% print divisor
lcd 0x8e
ldf $div  % push input
sri 0x66
jmp .mem2dec

% $out,$mod = divide($n,$div)
cpu 0x2
pud $n
pud $div
jmp .div

mem $null 0x0
ldf $null
cwf $mod
jmp 0x3 .next % if divisor, not prime
% otherwise inc divisor
inc $div
jmp .newdiv

.prime
% print prime
lcd 0xc6
ldf $n  % push input
sri 0x66
jmp .mem2dec

jmp .next

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

% n//10
cpu 0x2
pud $char
pud $m10
jmp .div

ldf $out
mem $n2ascii 0x230
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