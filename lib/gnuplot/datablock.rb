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
    # * *data* - anything with +#to_points+ method
    # * *is_file* set to true will force this datablock to store its data in temporary file
    def initialize(data, is_file = false)
      @is_file = is_file
      data = data.to_points
      if @is_file
        name = Dir::Tmpname.make_tmpname('tmp_data', 0)
        File.write(name, data)
        @name = name
        ObjectSpace.define_finalizer(self, proc { File.delete(name) })
      else
        @data = data
      end
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # This will add points to datablock
    # ==== Parameters
    # * *data* - anything with +#to_points+ method
    # * *update* - set to true (by default) will try to call replot on last used terminal
    def update(data, update = true)
      if @is_file
        File.open(@name, 'a') { |f| f.puts "\n#{data.to_points}"}
      else
        @data += data.to_points
        @last_terminal.store_datablock(@name, @data) if update
      end
      @last_terminal.replot if update
    end

    ##
    # ==== Overview
    # Returns quoted filename if datablock stored in file and outputs
    # datablock to gnuplot if not
    # *gnuplot_term* should be given if datablock changes gnuplot instance
    def name(gnuplot_term = nil)
      @last_terminal ||= gnuplot_term
      if @is_file
        "'#{@name}'"
      else
        @name = @last_terminal.store_datablock(@data) unless @is_file
      end
    end

    alias_method :to_s, :name
  end
end
