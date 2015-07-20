module GnuplotRB
  class Approximation < Dataset
    attr_reader :coefficients

    def initialize(data, function: 'a*x*x+b*x+c', initials: {a: 1, b: 1, c: 1}, **options)
      send(INIT_HANDLERS[data.class], data, options)
      @function = function
      @initials = initials
      @coefficients = initials
      @plottable_function = 'x*x + x + 1'
      unless @type == :datablock
        fail ArgumentError, 'Approximation may be initialized only with data'
      end
    end

    def to_s(terminal = nil)
      "#{@data.to_s(terminal)} #{options_to_string}, #{@plottable_function} title 'Approximation'"
    end

    def fit(function: nil, initials: nil, **options)
      function ||= @function
      initials ||= @initials
      term = Terminal.new
      initials.each { |var_name, value| term << "#{var_name} = #{value}\n" }
      term << "fit #{function}" \
              " #{@data.to_s(term)}" \
              " via #{initial_values.keys.join(':')}" \
              " #{OptionHandling.ruby_class_to_gnuplot(options)}" \
              "\n"

      # now we should catch 'error' from terminal: it will contain approximation data
      flag = true
      while flag
        begin
          sleep 0.01
          term.check_errors
        rescue GnuplotRB::GnuplotError => e
          flag = false
          output = e.message
        end
      end
      term.close

      # parse output
      @plottable_function = function.clone
      @coefficients = initials.map do |var, val|
        value = output.scan(/#{var} *= ([^ ]+)/)[0][0].to_f
        @plottable_function.gsub!(/#{var}/){value.to_s}
        [var, value]
      end.to_h
    end

    def [](*args)
      @coefficients[*args]
    end
  end
end

=begin
require 'gnuplotrb'
include GnuplotRB

x = (0..5).step(0.2).to_a
y = x.map { |xx| 3*xx**2 + xx + rand(2*xx)}
data = [x,y]
a = Approximation.new(data)
a.fit

=end
