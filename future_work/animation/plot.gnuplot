set term gif animate optimize delay 10 size 300, 300
set output "result.gif"
set xrange[0:2]
set yrange[-0.7:0.9]
set xzeroaxis
set title "Animation"
do for [i=0:99] {
  angle = 2*pi*i/100.0
  plot \
    sin(10.*x)*exp(-x) title "angle = 0" lw 2, \
    sin(10.*x)*exp(-x)*cos(angle) lw 2 title sprintf("angle = %d",i/100.0*360)
}
unset output