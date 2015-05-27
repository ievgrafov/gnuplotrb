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
    # ==== Overview
    # Creates new dataset out of given string with
    # math function or filename. If *data* isn't a string
    # it will create datablock to store data.
    # ==== Parameters
    # * *data* - String, Datablock or something with method
    # * *options* - hash of options specific for gnuplot 
    # dataset, and some special options ('file: true' will
    # make data to be stored inside temporary file.
    def initialize(data, **options)
      @not_datablock = data.is_a? String
      @data = if @not_datablock
                # check if string is a filename or math function
                File.exist?(data) ? "'#{data}'" : data.clone
              else
                data.is_a?(Datablock) ? data.clone : Datablock.new(data, options[:file])
              end
      @options = Hash[options.reject { |k, _| RUBY_OPTIONS.include?(k.to_s) }
                        .sort_by { |key, _| OPTION_ORDER.find_index(key.to_s) || 999 }]
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Converts dataset to string containing gnuplot dataset.
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
    # Creates new dataset with updated data (given
    # data is appended to existing) and merged options.
    # ==== Parameters
    # * *data* - data to append to existing
    # * *options* - hash to merge with existing options
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
    # Own implementation of #clone 
    def clone
      if @not_datablock
        super
      else
        Dataset.new(@data, **@options)
      end
    end

    ##
    # ==== Overview
    # Create new Dataset object with given options
    # merged with existing options if any given. It
    # will return existing options otherwise.
    # ==== Parameters
    # * *options* - options to add
    # ==== Example
    # TODO add example and spec 
    def options(**options)
      if options.empty?
        @options.clone
      else
        Dataset.new(@data, **@options.merge(options))
      end
    end

    ##
    # ==== Overview
    # You may set options using #option_name(option_value) method.
    # A new object will be constructed with selected option set.
    # And finally you can get current value of any option using
    # #options_name without arguments.
    # ===== Examples
    #   new_dataset = dataset.title('Awesome plot')
    #   dataset.title # >nil
    #   new_dataset.title # >'Awesome plot'
    #   dataset.title # >'One more awesome plot'
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
