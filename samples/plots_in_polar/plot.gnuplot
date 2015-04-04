set title 'Plot in polar example'
set polar
set samples 1000
set term png size 700, 700
set output './result.png'
plot abs(sin(3*t)) with filledcurves