nop

mem 0xff 0xff

mem $n 0x0

.next
inc $n

.loop
cpu 0x1
psh $n
jmp .sigma

ldf $divsum
hlt

jmp .next



%------------------
% divide($a,$b)
%------------------
% $div = a/b
% $mod = a%b
.div

% Set variable addresses
mem $div 0x0
mem $mod 0x0

% pop inputs
pod $b % get divisor
pod $mod % get n

clr $div

% check if a>b
.check
ldf $mod
cwf $b
jmp 0x2 .done % b>a, done
jmp 0x3 .inc % a=b

fsu $b
saf $mod
inc $div % increment counter
jmp .check

% Mod == 0, divisor
.inc
inc $div
clr $mod

.done
cpo
%-------------

%------------------
% sigma($a)
%------------------
.sigma

mem $c 0x0
mem $divsum 0x0
mem $cnt 0x0
clr $cnt
clr $divsum

pop $c

.adddiv
ldf $divsum
fad $cnt
saf $divsum

.newdiv
inc $cnt

cpu 0x2
pud $c
pud $cnt
jmp .div

mem $null 0x0
ldf $null
cwf $mod
jmp 0x3 .adddiv % if divisor, add

cwf $div
jmp 0x3 .outsigma

% otherwise inc divisor
jmp .newdiv

.outsigma
cpo
%------------------