set term png size 600,600
set output './gnuplot.png'
a = 1
b = 1
set xrange [0:15]
fit a*x*x + b 'points.data' using 1:2:3 zerror via a,b
unset xrange
plot 'points.data' with yerr, a*x*x+b title 'Fit formula' lw 3
unset output
