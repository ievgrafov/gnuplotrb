require 'pilot-gnuplot'
include Gnuplot

double_pi = Math::PI * 2

plot3d = Splot.new('cos(x)*cos(y)', xrange: -double_pi..double_pi, yrange: -double_pi..double_pi, style: 'function lp', hidden3d: true, term: ['qt', size: [500, 500], persist: true])

$RSPEC_TEST ? plot3d.to_png('./gnuplot_gem.png', size: [600, 600]) : plot3d.plot
