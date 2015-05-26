module Gnuplot
  ##
  # === Overview
  # This class corresponds to points we want to plot. It may be
  # stored in temporary file (to allow fast update) or inside
  # "$DATA << EOD ... EOD" construction. Datablock stores data passed
  # to constructor and keeps datablock name or path to file where it is stored.
  class Datablock
    ##
    # ==== Parameters
    # * *data* - sequence of anything with +#to_points+ method
    # * *is_file* set to true will force this datablock to store its data
    # in temporary file
    def initialize(data, is_file = false)
      @is_file = is_file
      data_str = data.to_points
      if @is_file
        name = Dir::Tmpname.make_tmpname('tmp_data', 0)
        File.write(name, data_str)
        @name = name
        ObjectSpace.define_finalizer(self, proc { File.delete(name) })
      else
        @data = data_str
      end
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Instantiate one more Datablock with updated data
    # if data stored in here-doc. Append update to file
    # if data stored there.
    # ==== Parameters
    # * *data* - anything with +#to_points+ method
    def update(data)
      data_str = data.to_points
      if @is_file
        File.open(@name, 'a') { |f| f.puts "\n#{data_str}" }
        self
      else
        Datablock.new(@data + data_str, false)
      end
    end

    ##
    # ==== Overview
    # Returns quoted filename if datablock stored in file and outputs
    # datablock to gnuplot otherwise.
    # *gnuplot_term* should be given if datablock not stored in file
    def name(gnuplot_term = nil)
      fail(ArgumentError, 'No terminal given to output datablock') unless @is_file unless gnuplot_term
      @is_file ? "'#{@name}'" : gnuplot_term.store_datablock(@data)
    end

    def clone
      @is_file ? self : super
    end

    alias_method :to_s, :name
  end
end
