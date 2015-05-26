require 'pilot-gnuplot'
include Gnuplot

x = (0..500).map { |xx| xx / 1000.0 }
y = x.map { |xx| Math.exp(-xx) }

plot = Plot.new([[x, y], with: 'lines', title: 'Exp (points)'],
                term: ['qt', persist: true])
plot.plot
puts 'Hit return to continue'
gets

x = (500..1000).map { |xx| xx / 1000.0 }
y = x.map { |xx| Math.exp(-xx) }
# datablock.update!([x, y])
# plot.plot

plot2 = plot.update_dataset([x, y])
plot3 = plot.add_dataset(['sin(x)', title: 'Sin(x)'])

plot2.plot(plot.terminal)

plot3.plot
puts 'Hit return to continue'
gets

plot.plot
