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
    # * *options* are for inner use (to create new Datablock from existing one)
    def initialize(data, is_file = false, **options)
      @is_file = is_file
      if options[:copy_file]
        name = Dir::Tmpname.make_tmpname('tmp_data', 0)
        FileUtils.cp(options[:old_file_name], name)
        @name = name
        ObjectSpace.define_finalizer(self, proc { File.delete(name) })
        update!(data)
      else
        data = data.to_points
        if @is_file
          name = Dir::Tmpname.make_tmpname('tmp_data', 0)
          File.write(name, data)
          @name = name
          ObjectSpace.define_finalizer(self, proc { File.delete(name) })
        else
          @data = data
        end
      end
      yield(self) if block_given?
    end

    ##
    # ==== Overview
    # Add points to existing datablock
    # ==== Parameters
    # * *data* - anything with +#to_points+ method
    def update!(data)
      if @is_file
        File.open(@name, 'a') { |f| f.puts "\n#{data.to_points}"}
      else
        @data += data.to_points
      end
    end

    ##
    # ==== Overview
    # Instantiate one more Datablock with updated data
    # ==== Parameters
    # * *data* - anything with +#to_points+ method
    def update(data)
      if @is_file
        Datablock.new(data, true, copy_file: true, old_file_name: @name)
      else
        Datablock.new(@data + data.to_points, false)
      end
    end

    ##
    # ==== Overview
    # Returns quoted filename if datablock stored in file and outputs
    # datablock to gnuplot if not
    # *gnuplot_term* should be given if datablock not saved in file
    def name(gnuplot_term = nil)
      raise ArgumentError.new('No terminal given to output datablock') unless @is_file unless gnuplot_term
      @is_file ? "'#{@name}'" : gnuplot_term.store_datablock(@data)
    end

    alias_method :to_s, :name
  end
end
