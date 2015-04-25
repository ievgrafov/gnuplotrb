set term png size 600,600
set output './gnuplot.png'
set title 'Plotting to png'
plot 'points.data' with lines title 'Points from file'
unset output