set term png size 600,600
set output './gnuplot.png'
set title 'Plot in polar example'
set polar
set samples 1000
plot abs(sin(3*t)) with filledcurves
unset output