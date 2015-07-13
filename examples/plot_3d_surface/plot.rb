require 'gnuplotrb'
include GnuplotRB

double_pi = Math::PI * 2

plot3d = Splot.new('cos(x)*cos(y)', xrange: -double_pi..double_pi, yrange: -double_pi..double_pi, style: 'function lp', hidden3d: true)

plot3d.to_png('./gnuplot_gem.png', size: [600, 600])
