throw(NotImplementedError, 'Not ready yet!')

# create a plot (just a Ruby object)
updatable_plot = Plot.new(['exp(-x)', title: 'Exp'])

# create empty Animation (just a Ruby object)
animation = Animation.new(title: 'Animation', path: './animation.gif', delay: 10, size: [300, 300])
# output to gnuplot options (output, term, title)
animation.begin
for i in 0..100
  # change xrange (tell gnuplot 'set xrange [0:(i/10.0)]')
  # output plot to animated term
  animation << updatable_plot.xrange(0..(i/10.0))
end
for i in 1..99
  # change xrange (tell gnuplot 'set xrange [0:(i/10.0)]')
  # output plot to animated term
  animation << updatable_plot.xrange(0..((100-i)/10.0))
end
# unset output to end animation
animation.end

## or
##
# Animation.new(title: 'Animation', path: './animation.gif', delay: 10, size: [300, 300]).plot do |animation|
# for i in 0..100
#   animation << updatable_plot.xrange(0..(i/10.0))
# end
# end