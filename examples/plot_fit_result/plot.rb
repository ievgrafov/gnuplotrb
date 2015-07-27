require 'gnuplotrb'
include GnuplotRB

fit_result = fit('points.data', using: '1:2:3', function: 'a*x*x + b', initials: { a: 1, b: 1 }, term_options: { xrange: 0..5 })

plot = Plot.new(fit_result[:formula_ds], fit_result[:data])

plot.to_png('./gnuplot_gem.png', size: [600, 600])
