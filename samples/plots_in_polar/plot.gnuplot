set xrange [-10:10]
set title "Math function example"
set ylabel "x"
set xlabel "x*sin(x)"
set term qt persist
plot x*sin(x) with lines lw 4