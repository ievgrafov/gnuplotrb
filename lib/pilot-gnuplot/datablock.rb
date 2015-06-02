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
    # * *stored_in_file* true here will force this datablock to store its data
    #   in temporary file
    def initialize(data, stored_in_file = false)
      @stored_in_file = stored_in_file
      data_str = data.to_points
      if @stored_in_file
        @file_name = Dir::Tmpname.make_tmpname('tmp_data', 0)
        File.write(@file_name, data_str)
        name = File.join(Dir.pwd, @file_name)
        ObjectSpace.define_finalizer(self, proc { File.delete(name) })
      else
        @data = data_str
      end
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
      if @stored_in_file
        File.open(@file_name, 'a') { |f| f.puts "\n#{data_str}" }
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
      if @stored_in_file
        "'#{@file_name}'"
      else
        fail(ArgumentError, 'No terminal given to output datablock') unless gnuplot_term
        gnuplot_term.store_datablock(@data)
      end
    end

    ## ==== Overview
    # Overridden #clone. Since datablock which store data
    # in temporary files should not be cloned (otherwise it will cause
    # double attempt to delete file), this #clone returns self for such
    # cases. For other cases it just calls default #clone.
    def clone
      @stored_in_file ? self : super
    end

    alias_method :to_s, :name
  end
end
