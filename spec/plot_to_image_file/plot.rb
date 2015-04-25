include Gnuplot

plot = Plot.new(['points.data', with: 'lines', title: 'Points from file'], title: 'Plotting to png')

plot.to_png('./gnuplot_gem.png', size: [600, 600])