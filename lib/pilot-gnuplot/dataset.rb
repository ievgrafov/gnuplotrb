module Gnuplot
  ##
  # === Overview
  # Dataset keeps control of Datablock or String (some math functions like this 'x*sin(x)'
  # or filename) and options related to original dataset in gnuplot (with, title, using etc)
  class Dataset
    # This constant is needed to separate ruby and gnuplot options
    RUBY_OPTIONS = %w{file}

    ##
    # ==== Parameters
    # *data* - String, Datablock or something with method +#to_points+ (used inside +Datablock::new+)
    def initialize(data, options = {})
      @not_datablock = data.is_a? String
      @data = if @not_datablock
                # check if string is a filename or math function
                !File.exist?(data) ? data : "'#{data}'"
              else
                data.is_a?(Datablock) ? data : Datablock.new(data, options[:file])
              end
      @options = options.reject{ |k, _| RUBY_OPTIONS.include?(k.to_s) }
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Converts dataset to string containing gnuplot dataset
    # ==== Parameters
    # * *terminal* - must be given if Datablock does not use temp file
    def to_s(term = nil)
      "#{@not_datablock ? @data : @data.name(term)} #{options_to_string}"
    end

    ##
    # ==== Overview
    # Create string from own options
    def options_to_string
      # order is significant for some options
      order = %w{index using axes title}
      @options = @options.sort_by{ |key, _| order.find_index(key.to_s) || 999}
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
    # Check if this Dataset uses *old_one* datablock. Create new Dataset with replaces datablock if it uses and return self otherwise.
    # ==== Parameters
    # * *old_one* - datablock object that should be replaced
    # * *new_one* - replacement for old_one
    def update_datablock(old_one, new_one)
      (@not_datablock || old_one != @data) ? self : Dataset.new(new_one, @options)
    end

    ##
    # ==== Overview
    # Check if this Dataset uses *old_one* datablock. Replaces old datablock with the new one.
    # ==== Parameters
    # * *old_one* - datablock object that should be replaced
    # * *new_one* - replacement for old_one
    def update_datablock!(old_one, new_one)
      @data = new_one unless @not_datablock if old_one === @data
      self
    end
  end
end
