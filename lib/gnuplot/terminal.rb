module Gnuplot
  class Terminal
    QUOTED = %w{title output xlabel ylabel}
    CLASS_OPTIONS = %w{persist}

    def initialize(command = 'gnuplot', **options)
      @cmd = 'gnuplot'
      @current_datablock = 0
      @current_style = 0
      command += ' -persist' if options[:persist]
      input = IO.popen(command, 'w')
      ObjectSpace.define_finalizer(self, proc { input.close_write })
      @in = input
      @own_options = options.reject{ |k, _| CLASS_OPTIONS.include?(k.to_s) }
      @external_options = []
      apply_options(@own_options)
      yield if block_given?
    end

    def store_datablock(name = nil, data)
      name ||= "$DATA#{@current_datablock += 1}"
      @in.puts "#{name} << EOD"
      @in.puts data
      @in.puts 'EOD'
      name
    end

    def option_to_string(option)
      return '' if !!option == option #check for boolean
      case option
        when Array
          option.map{ |el| option_to_string(el)}.join(option[0].is_a?(Numeric) ? ',' : ' ')
        when Hash
          option.map{ |pair| "#{pair[0]} #{option_to_string(pair[1])}" }.join(' ')
        when Range
          "[#{option.begin}:#{option.end}]"
        else
          option.to_s
      end
    end

    def apply_options(opts)
      opts.each do |key, value|
        if value
          if QUOTED.include?(key.to_s)
            @in.puts("set #{key} '#{option_to_string(value)}'")
          else
            @in.puts("set #{key} #{option_to_string(value)}")
          end
        else
          unset(key)
        end
      end
      @external_options += opts.keys - @own_options.keys
    end

    def restore_options
      unset(@external_options)
      @external_options = []
      apply_options(@own_options)
    end

    def unset(*options)
      options.flatten.each { |key| @in.puts "unset #{key}"}
    end

    def <<(a)
      case a
        when Datablock
          store_datablock(a)
        when Plot
          a.plot(self)
        else
          @in << a.to_s
          self
      end
    end

    def puts(a)
      @in.puts(a)
    end

    def replot
      @in.puts('replot')
    end
  end
end

=begin
$LOAD_PATH << './lib';require 'gnuplot';include Gnuplot
x = (0..50).to_a.map{|xx| xx/10.0}
y = x.map{ |xx| Math.exp(xx) }
data = [x, y]
datablock = Datablock.new(data, true)
dataset = Dataset.new(datablock, title: 'test datablocks')
plot = Plot.new(dataset, title: 'ololo')
Plot.new([data, with: 'lines'], title: "plot title").plot
=end