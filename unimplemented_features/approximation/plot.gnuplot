f(x) = a2*x*x+a1*x+a0
fit f(x) 'points.data' using 1:2:3 via a2,a1,a0
# found a2, a1 and a0 are displayed in gnuplot terminal
set term qt persist
plot f(x), 'points.data' with yerr