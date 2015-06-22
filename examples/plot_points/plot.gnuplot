set term png size 600,600
set output './gnuplot.png'
$DATA << EOD
0 0
1 1
2 4
3 9
4 16
5 25
EOD
plot $DATA with points title 'Points'
unset output