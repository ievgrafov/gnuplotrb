set term png size 600,600
set output './gnuplot.png'
set xrange [-10:10]
set title "Math function example"
set ylabel "x"
set xlabel "x*sin(x)"
plot x*sin(x) with lines lw 4
unset output