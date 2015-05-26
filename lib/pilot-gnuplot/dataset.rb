module Gnuplot
  ##
  # === Overview
  # Dataset keeps control of Datablock or String (some math functions like
  # this 'x*sin(x)' or filename) and options related to original dataset
  # in gnuplot (with, title, using etc).
  class Dataset
    # This constant is needed to separate ruby and gnuplot options
    RUBY_OPTIONS = %w(file)
    # order is significant for some options
    OPTION_ORDER = %w(index using axes title)

    ##
    # ==== Parameters
    # *data* - String, Datablock or something with method
    # +#to_points+ (used inside +Datablock::new+)
    def initialize(data, **options)
      @not_datablock = data.is_a? String
      @data = if @not_datablock
                # check if string is a filename or math function
                File.exist?(data) ? "'#{data}'" : data.clone
              else
                data.is_a?(Datablock) ? data.clone : Datablock.new(data, options[:file])
              end
      @options = options.reject { |k, _| RUBY_OPTIONS.include?(k.to_s) }
                        .sort_by { |key, _| OPTION_ORDER.find_index(key.to_s) || 999 }
                        .to_h
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Converts dataset to string containing gnuplot dataset
    # ==== Parameters
    # * *terminal* - must be given if Datablock does not use temp file
    def to_s(terminal = nil)
      "#{@not_datablock ? @data : @data.name(terminal)} #{options_to_string}"
    end

    ##
    # ==== Overview
    # Create string from own options
    def options_to_string
      @options.map do |key, value|
        value = '' if value.is_a?(TrueClass)
        if QUOTED.include?(key.to_s)
          "#{key} '#{value}'"
        else
          "#{key} #{value}"
        end
      end.join(' ')
    end

    ##
    # ==== Overview
    def update(data, **options)
      if @not_datablock
        # in this case copy should not be done
        @options.merge!(options)
        self
      else
        Dataset.new(@data.update(data), **@options.merge(options))
      end
    end

    ##
    # ==== Overview
    def clone
      if @not_datablock
        super
      else
        Dataset.new(@data, **@options)
      end
    end

    ##
    # ==== Overview
    def options(**options)
      if options.empty?
        @options.clone
      else
        Dataset.new(@data, **@options.merge(options))
      end
    end

    ##
    # ==== Overview
    def method_missing(meth_id, *args)
      meth = meth_id.id2name
      if args.empty?
        value = @options[meth.to_sym]
        value = value[0] if value && value.size == 1
        value
      else
        options(meth.to_sym => args)
      end
    end

    attr_reader :data
  end
end
