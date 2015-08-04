module GnuplotRB
  ##
  # === Overview
  # Dataset keeps control of Datablock or String (some math functions like
  # this 'x*sin(x)' or filename) and options related to original dataset
  # in gnuplot (with, title, using etc).
  #
  # === Options
  # Dataset options are explained in
  # {gnuplot docs}[http://www.gnuplot.info/docs_5.0/gnuplot.pdf](pp. 80-101).
  # Several common options:
  # * with - set plot style for dataset ('lines', 'points', 'impulses' etc)  
  # * using - choose which columns of input data gnuplot should use. Takes String
  #   (using: 'xtic(1):2:3'). If Daru::Dataframe passed one can use column names
  #   instead of numbers (using: 'index:value1:summ' - value1 and summ here are column names).
  # * linewidth (lw) - integer line width
  # * dashtype (dt) - takes pattern with dash style. Examples: '.. ', '-- ', '.-  '.
  # * pointtype (pt) - takes integer number of point type (works only when :with option is set to
  #   'points'). One can call Terminal::test(term_name)
  #   or Terminal#test in order to see which point types are supported by terminal.
  class Dataset
    include Plottable
    ##
    # Data represented by this dataset
    attr_reader :data

    ##
    # Order is significant for some options
    OPTION_ORDER = %w(index using axes title)

    ##
    # Hash of init handlers for data given in
    # different containers.
    INIT_HANDLERS = Hash.new(:init_default).merge(
      String =>          :init_string,
      Datablock =>       :init_dblock
    )
    INIT_HANDLERS.merge!(
      Daru::DataFrame => :init_daru_frame,
      Daru::Vector =>    :init_daru_vector
    ) if defined? Daru

    ##
    # ====== Overview
    # Creates new dataset out of given string with
    # math function or filename. If *data* isn't a string
    # it will create datablock to store data.
    # ====== Parameters
    # * *data* - String, Datablock or something acceptable by
    #   Datablock.new as data (e.g. [x,y] where x and y are arrays)
    # * *options* - hash of options specific for gnuplot
    #   dataset, and some special options ('file: true' will
    #   make data to be stored inside temporary file).
    # ====== Examples
    # Math function:
    #   Dataset.new('x*sin(x)', with: 'lines', lw: 4)
    # File with points:
    #   Dataset.new('points.data', with: 'lines', title: 'Points from file')
    # Some data (creates datablock stored in memory):
    #   x = (0..5000).to_a
    #   y = x.map {|xx| xx*xx }
    #   points = [x, y]
    #   Dataset.new(points, with: 'points', title: 'Points')
    # The same data but datablock stores it in temp file:
    #   Dataset.new(points, with: 'points', title: 'Points', file: true)
    def initialize(data, **options)
      # run method by name
      send(INIT_HANDLERS[data.class], data, options)
    end

    ##
    # ====== Overview
    # Converts Dataset to string containing gnuplot dataset.
    # ====== Parameters
    # * *terminal* - must be given if data given as Datablock and
    #   it does not use temp file so data should be piped out
    #   to gnuplot via terminal before use.
    # ====== Examples
    #   Dataset.new('points.data', with: 'lines', title: 'Points from file').to_s
    #   #=> "'points.data' with lines title 'Points form file'"
    #   Dataset.new(points, with: 'points', title: 'Points').to_s
    #   #=> "$DATA1 with points title 'Points'"
    def to_s(terminal = nil)
      "#{@type == :datablock ? @data.name(terminal) : @data} #{options_to_string}"
    end

    ##
    # ====== Overview
    # Creates new dataset with updated data (given
    # data is appended to existing) and merged options.
    # Data is updated only if Dataset stores it in Datablock.
    # Method does nothing if no options given and data isn't stored
    # in in-memory Datablock.
    # ====== Parameters
    # * *data* - data to append to existing
    # * *options* - hash to merge with existing options
    # ====== Examples
    # Updating dataset with Math formula or filename given:
    #   dataset = Dataset.new('file.data')
    #   dataset.update(data: 'asd')
    #   #=> nothing updated
    #   dataset.update(data: 'asd', title: 'File')
    #   #=> Dataset.new('file.data', title: 'File')
    # Updating dataset with data stored in Datablock:
    #   in_memory_points = Dataset.new(points, title: 'Old one')
    #   in_memory_points.update(data: some_update, title: 'Updated')
    #   #=> Dataset.new(points + some_update, title: 'Updated')
    #   temp_file_points = Dataset.new(points, title: 'Old one', file: true)
    #   temp_file_points.update(data: some_update)
    #   #=> data updated but no new dataset created
    #   temp_file_points.update(data: some_update, title: 'Updated')
    #   #=> data updated and new dataset with title 'Updated' returned
    def update(data = nil, **options)
      if data && @type == :datablock
        new_datablock = @data.update(data)
        if new_datablock == @data
          update_options(options)
        else
          self.class.new(new_datablock, options)
        end
      else
        update_options(options)
      end
    end

    ##
    # ====== Overview
    # Own implementation of #clone. Creates new Dataset if
    # data stored in datablock and calls super otherwise.
    def clone
      if @type == :datablock
        new_with_options(@options)
      else
        super
      end
    end

    ##
    # ====== Overview
    # Creates new Plot object with only one Dataset given - self.
    # Calls #plot on created Plot. All arguments given to this #plot
    # will be sent to Plot#plot instead.
    # ====== Example
    #   sin = Dataset.new('sin(x)')
    #   sin.plot(term: [qt, size: [300, 300]])
    #   #=> shows qt window 300x300 with sin(x)
    #   sin.to_png('./plot.png')
    #   #=> creates png file with sin(x) plotted
    def plot(*args)
      Plot.new(self).plot(*args)
    end

    private

    ##
    # ====== Overview
    # Creates new dataset with existing options merged with
    # the given ones. Does nothing if no options given.
    # ====== Parameters
    # * *options* - hash to merge with existing options
    # ====== Examples
    # Updating dataset with Math formula or filename given:
    #   dataset = Dataset.new('file.data')
    #   dataset.update_options(title: 'File')
    #   #=> Dataset.new('file.data', title: 'File')
    def update_options(**options)
      if options.empty?
        self
      else
        new_with_options(@options.merge(options))
      end
    end

    ##
    # ====== Overview
    # Create string from own options
    def options_to_string
      options.sort_by { |key, _| OPTION_ORDER.find_index(key.to_s) || 999 }
             .map { |key, value| OptionHandling.option_to_string(key, value) }
             .join(' ')
    end

    ##
    # Needed by OptionHandling to create new object when
    # options are changed.
    def new_with_options(options)
      self.class.new(@data, options)
    end

    def init_string(data, options)
      @type, @data = File.exist?(data) ? [:datafile, "'#{data}'"] : [:math_function, data.clone]
      @options = Hamster.hash(options)
    end

    def init_dblock(data, options)
      @type = :datablock
      @data = data.clone
      @options = Hamster.hash(options)
    end

    def get_daru_columns(data, cnt)
      new_opt = (2..cnt).to_a.join(':')
      if data.index[0].is_a?(DateTime) || data.index[0].is_a?(Numeric)
        "1:#{new_opt}"
      else
        "#{new_opt}:xtic(1)"
      end
    end

    def init_daru_frame(data, options)
      options[:title] ||= data.name
      if options[:using]
        options[:using] = " #{options[:using]} "
        data.vectors.to_a.each_with_index do |daru_index, array_index|
          options[:using].gsub!(/([\:\(\$ ])#{daru_index}([\:\) ])/) do
            "#{Regexp.last_match(1)}#{array_index + 2}#{Regexp.last_match(2)}"
          end
        end
        options[:using].gsub!('index', '1').strip!
      else
        options[:using] = get_daru_columns(data, data.vectors.size + 1)
      end
      init_default(data, options)
    end

    def init_daru_vector(data, options)
      options[:using] ||= get_daru_columns(data, 2)
      options[:title] ||= data.name
      init_default(data, options)
    end

    def init_default(data, file: false, **options)
      @type = :datablock
      @data = Datablock.new(data, file)
      @options = Hamster.hash(options)
    end
  end
end
