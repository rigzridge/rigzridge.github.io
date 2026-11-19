%nop

mem 0xff 0xff

mem $vec 0x40
mem $n 0x0

mem 0x40 0x1

mem $k 0x0
mem $nk 0x0

mem $sum 0x0

mem $out 0x0

mem $null 0x0

.next
inc $n

clr $sum
clr $k

.loop

ldf $n
fsu $k
saf $nk

%------------------
% sigma($a)
%------------------
.sigma

mem $c 0x0
mem $divsum 0x0
mem $cnt 0x0

clr $cnt
clr $divsum

.adddiv
ldf $divsum
fad $cnt
saf $divsum

.newdiv
inc $cnt

cpu 0x2
psh $nk
psh $cnt
jmp .div

ldf $null
cwf $mod
jmp 0x3 .adddiv % if divisor, add

cwf $out
jmp 0x3 .outSigma

% otherwise inc divisor
jmp .newdiv

%------------------

.outSigma

psh $vec
ppa $k
ldf $divsum

%----------
.mult
%----------
mem $a 0x0

pod $a

.checknull
cwf $null 
jmp 0x3 .outMult

% else add
fde
lda $out
ldb $a
add $out
jmp .checknull

%----------

.outMult

ldf $out
fad $sum
saf $sum

ldf $n
inc $k
cwf $k
jmp 0x3 .saveval

jmp .loop

%------------------
% divide($a,$b)
%------------------
% $out = a/b
% $mod = a%b
.div

% Set variable addresses
mem $b 0x0
mem $mod 0x0

% pop inputs
pop $b % get divisor
pop $mod % get n

clr $out

% check if a>b
.check
ldf $mod
cwf $b
jmp 0x2 .return % b>a, done
jmp 0x3 .inc % a=b

fsu $b
saf $mod
inc $out % increment counter
jmp .check

% Mod == 0, divisor
.inc
inc $out
clr $mod

.return
cpo
%-------------

.saveval

cpu 0x2
psh $sum
psh $n
jmp .div

%swap
psh $vec
ppa $n

hlt

mem $dum 0x0
swp $out % Swaps data @ $data with sp** 
pop $dum 

%jmp .next


