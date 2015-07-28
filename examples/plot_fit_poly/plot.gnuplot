set term png size 600,600
set output './gnuplot.png'
a3 = 1
a2 = 1
a1 = 1
a0 = 1
fit a3*x**3 + a2*x**2 + a1*x + a0 'points.data' using 1:2:3 zerror via a3,a2,a1,a0
plot 'points.data' with yerr, a3*x**3 + a2*x**2 + a1*x + a0 title 'Fit formula' lw 3
unset output
