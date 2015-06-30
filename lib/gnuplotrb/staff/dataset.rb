module GnuplotRB
  ##
  # === Overview
  # Dataset keeps control of Datablock or String (some math functions like
  # this 'x*sin(x)' or filename) and options related to original dataset
  # in gnuplot (with, title, using etc).
  class Dataset
    include OptionHandling
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
      self.send(INIT_HANDLERS[data.class], data, options)
    end

    ##
    # Method for inner use.
    def init_string(data, options)
      @type, @data= if File.exist?(data)
        [:datafile, "'#{data}'"]
      else
        [:math_function, data.clone]
      end
      @options = Hamster.hash(options)
    end

    ##
    # Method for inner use.
    def init_dblock(data, options)
      @type = :datablock
      @data = data.clone
      @options = Hamster.hash(options)
    end

    ##
    # Method for inner use.
    def init_daru_frame(data, options)
      options[:title] ||= data.name
      if options[:using]
        data.vectors.to_a.each_with_index do |daru_index, array_index|
          options[:using].gsub!(/#{daru_index}/) { array_index + 2 }
        end
      else
        new_opt = (2...(2 + data.vectors.size)).to_a.join(':')
        options[:using] = "#{new_opt}:xtic(1)"
      end
      init_default(data, options)
    end

    ##
    # Method for inner use.
    def init_daru_vector(data, options)
      options[:using] ||= '2:xtic(1)'
      options[:title] ||= data.name
      init_default(data, options)
    end

    ##
    # Method for inner use.
    def init_default(data, file: false, **options)
      @type = :datablock
      @data = Datablock.new(data, file)
      @options = Hamster.hash(options)
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
      "#{@type == :datablock ? @data.name(terminal) : @data } #{options_to_string}"
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
    #   dataset.update('asd')
    #   #=> nothing updated
    #   dataset.update('asd', title: 'File')
    #   #=> Dataset.new('file.data', title: 'File')
    # Updating dataset with data stored in Datablock:
    #   in_memory_points = Dataset.new(points, title: 'Old one')
    #   in_memory_points.update(some_update, title: 'Updated')
    #   #=> Dataset.new(points + some_update, title: 'Updated')
    #   temp_file_points = Dataset.new(points, title: 'Old one', file: true)
    #   temp_file_points.update(some_update)
    #   #=> data updated but no new dataset created
    #   temp_file_points.update(some_update, title: 'Updated')
    #   #=> data updated and new dataset with title 'Updated' returned
    def update(data = nil, **options)
      if data && @type == :datablock
        new_datablock = @data.update(data)
        if new_datablock == @data
          update_options(options)
        else
          Dataset.new(@data.update(data), @options.merge(options))
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
        Dataset.new(@data, **@options)
      else
        super
      end
    end

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
        return self
      else
        Dataset.new(@data, @options.merge(options))
      end
    end

    ##
    # Method for inner use.
    # Needed by OptionHandling to create new object when
    # options are changed.
    def new_with_options(options)
      self.class.new(@data, options)
    end

    ##
    # ====== Overview
    # You may set options using #option_name(option_value) method.
    # A new object will be constructed with selected option set.
    # And finally you can get current value of any option using
    # #options_name without arguments.
    # ====== Examples
    #   dataset = Dataset.new('file.data')
    #   dataset.title #=> nil
    #   new_dataset = dataset.title('Awesome plot')
    #   dataset.title #=> nil
    #   new_dataset.title #=> 'Awesome plot'
    def method_missing(meth_id, *args)
      option(meth_id, *args)
    end

    private :init_default,
            *INIT_HANDLERS.values,
            :new_with_options
  end
end
