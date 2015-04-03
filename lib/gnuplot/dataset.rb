module Gnuplot
  class Dataset
    QUOTED = %w{title}
    CLASS_OPTIONS = %w{file}

    def initialize(data, options = {})
      @not_datablock = data.is_a? String
      @data = if @not_datablock
                !File.exist?(data) ? data : "'#{data}'"
              else
                data.is_a?(Datablock) ? data : Datablock.new(data, options[:file])
              end
      @options = options.reject{ |k, _| CLASS_OPTIONS.include?(k.to_s) }
      yield if block_given?
    end

    def to_s(term = nil)
      "#{@not_datablock ? @data : @data.name(term)} #{get_options}"
    end

    def get_options
      @options.map do |key, value|
        value = '' if value.is_a?(TrueClass)
        if QUOTED.include?(key.to_s)
          "#{key} '#{value}'"
        else
          "#{key} #{value}"
        end
      end.join(' ')
    end
  end
end
