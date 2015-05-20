set term png size 600,600
set output './gnuplot.png'
plot 'points.data' with lines title 'Points from file'
unset output