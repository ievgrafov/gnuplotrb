require 'gnuplotrb'
include GnuplotRB

fit_result = fit_exp('points.data', using: '1:2:3')

plot = Plot.new(fit_result[:data].with('yerr'), fit_result[:formula_ds].lw(3))

plot.to_png('./gnuplot_gem.png', size: [600, 600])
