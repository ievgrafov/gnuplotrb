require 'gnuplotrb'
include GnuplotRB

fit_result = fit('points.data', using: '1:2:3', function: 'a*x*x + b', initials: { a: 1, b: 1 }, term_options: { xrange: 0..15 })

plot = Plot.new(fit_result[:data].with('yerr'), fit_result[:formula_ds].lw(3))

plot.to_png('./gnuplot_gem.png', size: [600, 600])
