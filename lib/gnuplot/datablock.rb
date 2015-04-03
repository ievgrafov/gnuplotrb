module Gnuplot
  class Datablock
    def initialize(data, is_file = false)
      @is_file = is_file
      data = data.to_points
      if @is_file
        name = Dir::Tmpname.make_tmpname('tmp_data', 0)
        File.write(name, data)
        @name = name
        ObjectSpace.define_finalizer(self, proc { File.delete(name) })
        yield if block_given?
      else
        @data = data
      end
    end

    def update(data, update = true)
      if @is_file
        File.open(@name, 'a') { |f| f.puts "\n#{data.to_points}"}
      else
        @data += data.to_points
        @last_term.store_datablock(@name, @data) if update
      end
      @last_term.replot if update
    end

    def name(gnuplot_term = nil)
      @last_term = gnuplot_term
      if @is_file
        "'#{@name}'"
      else
        @name = @last_term.store_datablock(@data) unless @is_file
      end
    end
  end
end
