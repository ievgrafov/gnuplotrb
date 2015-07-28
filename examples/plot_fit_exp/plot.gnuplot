set term png size 600,600
set output './gnuplot.png'
xoffset = 0.1
xscale = 1
yoffset = 0.1
yscale = 1
fit yscale * (yoffset + exp((x - xoffset) / xscale)) 'points.data' using 1:2:3 zerror via yscale,yoffset,xoffset,xscale
plot 'points.data' with yerr, yscale * (yoffset + exp((x - xoffset) / xscale)) title 'Fit formula' lw 3
unset output
