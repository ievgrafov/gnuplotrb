require '../helper'
include Gnuplot

plot = Plot.new(['points.data', with: 'lines', title: 'Points from file'], title: 'Plotting to different terminals')

plot.to_svg('./real_result.svg', size: [600, 600])
plot.to_png('./real_result.png', size: [600, 600])
plot.to_canvas('./real_result.html', size: [600, 600])

# You can also just get contents of image (or not image) file
contents = plot.to_dumb(size: [60, 40])
File.write('./real_result.txt', contents)