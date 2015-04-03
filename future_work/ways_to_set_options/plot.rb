throw(NotImplementedError, 'Not ready yet!')
require '../helper'
include Gnuplot

# 1. Chaining
Plot.new(['x*sin(x)', with: 'lines', lw: 4]).xrange(-10..10).title('Math function example').ylabel('x').xlabel('x*sin(x)').term('qt', persist: true).plot

# 2. Passed as hash
Plot.new(['x*sin(x)', with: 'lines', lw: 4], xrange: -10..10, title: 'Math function example', ylabel: 'x', xlabel: 'x*sin(x)', term: ['qt', persist: true]).plot

# 3. Passing block into constructor
Plot.new(['x*sin(x)', with: 'lines', lw: 4]) do |plot|
  plot.xrange = -10..10
  ...
  plot.term = 'qt'
end

# 4. Just setting them
plot = Plot.new(['x*sin(x)', with: 'lines', lw: 4])
plot.xrange = -10..10
...
plot.term = 'qt'