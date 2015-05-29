require 'pilot-gnuplot'
include Gnuplot


graph = Plot.new(['tons_of_data', title: 'Tons of data', with: 'lines'], term: ['qt', persist: true])
graph.plot
#Need to change some dataset options? Ok:
plot_with_points = graph.update_dataset(with: 'points', title: 'Plot with points')
plot_with_points.plot
#Need to change the whole plot options? Ok:
plot_interval = graph.options(title: 'Plot on [1..3]', xrange: 1..3)
plot_interval .plot