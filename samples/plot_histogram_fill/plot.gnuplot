set term png size 600,600
set output './gnuplot.png'
set title "Time spent to run deploy pipeline"
set style data histograms
set style fill pattern border
set yrange [0:2200]
set xlabel 'Number of test'
set ylabel 'Time, s'
$DATA << EOD
1 312 525  215 1052
2 630 1050 441 2121
3 315 701  370 1386
4 312 514  220 1046
EOD
plot $DATA using 2:xtic(1) title 'Build',\
     $DATA using 3:xtic(1) title 'Test',\
     $DATA using 4:xtic(1) title 'Deploy',\
     $DATA using 5:xtic(1) title 'Overall'
unset output