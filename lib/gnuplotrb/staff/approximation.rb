module GnuplotRB
  class Approximation < Dataset
    attr_reader :coefficients
    attr_reader :deltas
    attr_reader :plottable_function


    def initialize(data, coefficients: {}, deltas: {}, plottable_function: nil, **options)
      send(INIT_HANDLERS[data.class], data, options)
      unless @type == :datablock
        fail ArgumentError, 'Approximation may be initialized only with data'
      end
      @coefficients = coefficients
      @deltas = deltas
      @plottable_function = plottable_function
    end

    def new_with_update(data: nil, **options)
      if data
        self.class.new(
          @data.update(data),
          coefficients: @coefficients,
          deltas: @deltas,
          plottable_function: @plottable_function,
          **options
        )
      else
        self.class.new(
          @data,
          coefficients: @coefficients,
          deltas: @deltas,
          plottable_function: @plottable_function,
          **options
        )
      end
    end

    def to_s(terminal = nil)
      "#{@data.to_s(terminal)} #{options_to_string}, #{plottable_function} title 'Approximation'"
    end

    def fit(function: 'a*x*x+b*x+c', initials: {a: 1, b: 1, c: 1}, via: nil, **options)
      variables = via || initials.keys
      term = Terminal.new
      initials.each { |var_name, value| term << "#{var_name} = #{value}\n" }
      term << "fit #{function}" \
              " #{@data.to_s(term)}" \
              " via #{variables.join(',')}" \
              " #{OptionHandling.ruby_class_to_gnuplot(options)}" \
              "\n"
      output = wait_for_output(term)
      term.close
      parse_output(variables, function, output)
    end

    def wait_for_output(term)
      # now we should catch 'error' from terminal: it will contain approximation data
      output = ''
      until output.include?('correlation matrix')
        begin
          term.check_errors
        rescue GnuplotRB::GnuplotError => e
          output += e.message
        end
      end
      output
    end

    def parse_output(variables, function, output)
      @plottable_function = function.clone
      @coefficients = {}
      @deltas = {}
      variables.each do |var|
        value, error = output.scan(/#{var} *= ([^ ]+) *\+\/\- ([^ ]+)/)[0]
        @plottable_function.gsub!(/#{var}/) { value }
        @coefficients[var] = value.to_f
        @deltas[var] = error.to_f
      end
      @coefficients
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
y = x.map { |xx| 3*xx**2 + rand(5*xx)}
data = [x,y]
a = Approximation.new(data)
a.fit

=end
