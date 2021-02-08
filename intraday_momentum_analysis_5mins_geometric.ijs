col_min =: |: min
'date time price' =: col_min

is_open =: 905 = time
is_open_plus_30 =: 930 = time
is_close_minus_60 =: 1430 = time
is_close_minus_30 =: 1500 = time
is_close =: 1530 = time

FH =:  (is_open_plus_30 # price) -&^. (is_open # price)
M =: (is_close_minus_60 # price) -&^. (is_open_plus_30 # price)
SLF =: (is_close_minus_30 # price) -&^. (is_close_minus_60 # price)
LH =: (}. is_close # price) -&^. (is_close_minus_30 # price)
ON =: (is_open # price) -&^. (}: is_close # price)
ONFH =: (is_open_plus_30 # price) -&^. (}: is_close # price)
ROD =: (is_close_minus_30 # price) -&^. (}: is_close # price)

is_rod_up =: ROD > 0
is_rod_down =: ROD < 0

mean =: +/ % #

NB. Pr(ROD > 0)
echo 'Pr(ROD > 0): ', ": mean is_rod_up

NB. Pr(ROD < 0)
echo 'Pr(ROD < 0): ', ": mean is_rod_down

NB. Pr(LH > 0 | ROD > 0) long position, profit
is_lh_up =: LH > 0
is_lh_up_rod_up =: is_lh_up *. is_rod_up
echo 'Pr(LH > 0 | ROD > 0) long position, profit: ', ": (mean is_lh_up_rod_up) % mean is_rod_up

NB. Pr(LH < 0 | ROD > 0) long position, loss
is_lh_down =: LH < 0
is_lh_down_rod_up =: is_lh_down *. is_rod_up
echo 'Pr(LH < 0 | ROD > 0) long position, loss: ', ": (mean is_lh_down_rod_up) % mean is_rod_up

NB. Pr(LH < 0 | ROD < 0) short position, profit
is_lh_down_rod_down =: is_lh_down *. is_rod_down
echo 'Pr(LH < 0 | ROD < 0) short position, profit: ', ": (mean is_lh_down_rod_down) % mean is_rod_down

NB. Pr(LH > 0 | ROD < 0) short position, loss
is_lh_up_rod_down =: is_lh_up *. is_rod_down
echo 'Pr(LH > 0 | ROD < 0) short position, loss: ', ": (mean is_lh_up_rod_down) % mean is_rod_down

NB. strategy test
threshold =: 0.015
is_larger_than_threshold =: (|ROD) > threshold

is_win =: is_larger_than_threshold *. is_lh_up_rod_up +. is_lh_down_rod_down
is_lose =: is_larger_than_threshold *. is_lh_down_rod_up +. is_lh_up_rod_down


pnl =: (is_win * | LH) + is_lose * - | LH
pnlplot =: conew 'jzplot'
plot__pnlplot ^ +/\ pnl

NB. simple regression
mp =: +/ .*
coef =: LH %. (1 ,. ROD)
estimate =: (1 ,. ROD) mp coef
'type dot; pensize 4; aspect 1' plot (ROD j. LH) ,: ROD j. estimate