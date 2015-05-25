require 'pilot-gnuplot'
include Gnuplot

x = (0..500).map{ |xx| xx/1000.0 }
y = x.map{ |xx| Math.exp(-xx) }
datablock = Datablock.new([x, y], true) # < this variant uses temporary file to store and update data
# datablock = Datablock.new([x, y]) #< this variant resends whole datablock to pipe each time it is updated
plot = Plot.new([datablock, with: 'lines', title: 'Exp (points)'], term: ['qt', persist: true])
plot.plot
puts 'Hit return to continue'
gets

x = (500..1000).map{ |xx| xx/1000.0 }
y = x.map{ |xx| Math.exp(-xx) }
#datablock.update!([x, y])
#plot.plot

plot2 = plot.update_data(datablock, datablock.update([x, y]))
plot2.plot
