set term gif animate optimize delay 3 size 300, 300
set output "result.gif"
set xzeroaxis
set title "Animation"
set xrange [0:0.1]
plot exp(-x)
do for [i=1:100] {
  set xrange [0:i/10.0]
  replot
}
do for [i=1:99] {
  set xrange [0:(100-i)/10.0]
  replot
}

unset output