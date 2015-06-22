set output './gnuplot.png'
set term png size 600,600
set hidden3d
set xrange [-pi*2:pi*2]
set yrange [-pi*2:pi*2]
set style function lp
splot cos(x)*cos(y)
unset output