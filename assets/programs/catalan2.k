nop

mem 0xff 0xff

mem $vec 0x40
mem $n 0x0

mem 0x40 0x1

mem $k 0x0
mem $nk 0x0

mem $ptr 0x0
mem $sum 0x0

.next
inc $n
clr $sum

clr $k
ldf $n
fde 
saf $nk

.loop
cpu 0x8

ldf $vec
fad $k
saf $ptr
psh $ptr

ldf $vec
fad $nk
saf $ptr
psh $ptr

jmp .mult

ldf $out
fad $sum
saf $sum

ldf $n
inc $k
cwf $k
jmp 0x3 .saveval

ldf $nk
fde
saf $nk
jmp .loop

.saveval
ldf $vec
fad $n
saf $ptr

%swap
psh $ptr
psh $sum

mem $data 0x0
mem $dum 0x0

pop $data % Get var
swp $data % Swaps data @ $data with sp** 

pop $dum

ldf $sum
hlt
jmp .next

%----------
.mult
%----------
mem $a 0x0
mem $b 0x0
mem $out 0x0

clr $out

pod $b
pod $a

ldf $b
mem $zero 0x0
.checknull
cwf $zero 
jmp 0x3 .return

% else add
fde
lda $out
ldb $a
add $out
jmp .checknull

.return
cpo
%----------