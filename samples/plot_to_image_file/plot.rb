require '../helper'
include Gnuplot

Plot.new(['points.data', with: 'lines', title: 'Points from file'], title: 'Plotting to png').to_png('./real_result.png', size: [600, 600])
# Call of #to_png without path will return plotted png as binary data
# bytes = Plot.new(['points.data', with: 'lines', title: 'Points from file'], title: 'Plotting to png').to_png(size: [600, 600])