module GnuplotRB
  ##
  # === Overview
  # Plot correspond to simple 2D visualisation
  class Plot
    include Plottable
    ##
    # Array of datasets which are plotted by this object.
    attr_reader :datasets
    ##
    # ====== Arguments
    # * *datasets* are either instances of Dataset class or
    #   [data, **dataset_options] arrays from which Dataset may be created
    # * *options* will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]' for { xrange: 1..10 },
    #   "set title 'plot'" for { title: 'plot' } etc)
    def initialize(*datasets)
      # had to relace **options arg with this because in some cases
      # Daru::DataFrame was mentioned as hash and added to options
      # instead of plots
      @options = Hamster.hash
      if datasets[-1].is_a?(Hamster::Hash) || datasets[-1].is_a?(Hash)
        @options = Hamster.hash(datasets[-1])
        datasets = datasets[0..-2]
      end
      @datasets = parse_datasets_array(datasets)
      @cmd = 'plot '
      OptionHandling.validate_terminal_options(@options)
      yield(self) if block_given?
    end

    ##
    # ====== Overview
    # This outputs plot to term (if given) or to this plot's own terminal.
    # ====== Arguments
    # * *term* - Terminal to plot to
    # * *multiplot_part* - part of a multiplot. Option for inner usage
    # * *options* - will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]', 'set title 'plot'' etc)
    # Options passed here have priority over already existing.
    def plot(term = nil, multiplot_part: false, **options)
      fail ArgumentError, 'Empty plots are not supported!' if @datasets.empty?
      opts = @options.merge(options)
      opts = opts.reject { |key, _value| [:term, :output].include?(key) } if multiplot_part
      terminal = term || (opts[:output] ? Terminal.new : own_terminal)
      full_command = @cmd + @datasets.map { |dataset| dataset.to_s(terminal) }.join(' , ')
      terminal.set(opts)
              .stream_puts(full_command)
              .unset(opts.keys)
      if opts[:output]
        # guaranteed wait for plotting to finish
        terminal.close unless term
        # not guaranteed wait for plotting to finish
        # work bad with terminals like svg and html
        sleep 0.01 until File.size?(opts[:output])
      end
      self
    end

    alias_method :replot, :plot

    ##
    # ====== Overview
    # Create new Plot object where dataset at *position* will
    # be replaced with the new one created from it by updating.
    # ====== Arguments
    # * *position* - position of dataset which you need to update
    #   (by default first dataset is updated)
    # * *data* - data to update dataset with
    # * *options* - options to update dataset with
    # ====== Example
    #   updated_plot = plot.update_dataset(data: [x1,y1], title: 'After update')
    def update_dataset(position = 0, data: nil, **options)
      old_ds = @datasets[position]
      new_ds = old_ds.update(data, options)
      new_ds.equal?(old_ds) ? self : replace_dataset(position, new_ds)
    end

    ##
    # ====== Overview
    # Create new Plot object where dataset at *position* will
    # be replaced with the given one.
    # ====== Arguments
    # * *position* - position of dataset which you need to update
    #   (by default first dataset is replaced)
    # * *dataset* - dataset to replace the old one. You can also
    #   give here [data, **dataset_options] array from
    #   which Dataset may be created.
    # ====== Example
    #   sinx = Plot.new('sin(x)')
    #   cosx = sinx.replace_dataset(['cos(x)'])
    def replace_dataset(position = 0, dataset)
      self.class.new(@datasets.set(position, dataset_from_any(dataset)), @options)
    end

    ##
    # ====== Overview
    # Create new Plot object where given datasets will
    # be inserted into dataset list before given position
    # (position = 0 by default).
    # ====== Arguments
    # * *position* - position where to insert given datasets
    # * *datasets* - sequence of datasets to add
    # ====== Example
    #   sinx = Plot.new('sin(x)')
    #   sinx_and_cosx_with_expx = sinx.add(['cos(x)'], ['exp(x)'])
    #
    #   cosx_and_sinx = sinx << ['cos(x)']
    def add_datasets(*datasets)
      datasets.map! { |ds| ds.is_a?(Numeric) ? ds : dataset_from_any(ds) }
      datasets.unshift(0) unless datasets[0].is_a?(Numeric)
      self.class.new(@datasets.insert(*datasets), @options)
    end

    alias_method :add_dataset, :add_datasets
    alias_method :<<, :add_datasets

    ##
    # ====== Overview
    # Create new Plot object where dataset at given position
    # will be removed from dataset list.
    # ====== Arguments
    # * *position* - position of dataset that should be
    #   removed (by default last dataset is removed)
    # ====== Example
    #   sinx_and_cosx = Plot.new('sin(x)', 'cos(x)')
    #   sinx = sinx_and_cosx.remove_dataset
    #   cosx = sinx_and_cosx.remove_dataset(0)
    def remove_dataset(position = -1)
      self.class.new(@datasets.delete_at(position), @options)
    end

    ##
    # ====== Overview
    # The same as Plot#datasets[args]
    def [](*args)
      @datasets[*args]
    end

    private
    ##
    # Checks several conditions and set options needed
    # to handle DateTime indexes properly.
    def provide_with_datetime_format(data, using)
      if defined?(Daru) &&
         (data.is_a?(Daru::DataFrame) || data.is_a?(Daru::Vector)) &&
         data.index.first.is_a?(DateTime) &&
         using[0..1] == '1:'
        @options = @options.merge(
            xdata: 'time',
            timefmt: '%Y-%m-%dT%H:%M:%S',
            format_x: '%d\n%b\n%Y'
        )
      end
    end

    ##
    # Check if given args is a dataset and returns it. Creates
    # new dataset from given args otherwise.
    def dataset_from_any(source)
      ds = case source
           # when initialized with dataframe (it passes here several vectors)
           when (defined?(Daru) ? Daru::Vector : nil)
             Dataset.new(source)
           when Dataset
             source.clone
           else
             Dataset.new(*source)
           end
      data = source.is_a?(Array) ? source[0] : source
      provide_with_datetime_format(data, ds.using)
      ds
    end

    ##
    # Parses given array and returns Hamster::Vector of Datasets
    def parse_datasets_array(datasets)
      case datasets[0]
      when Hamster::Vector
        datasets[0]
      when (defined?(Daru) ? Daru::DataFrame : nil)
        Hamster::Vector.new(datasets[0].map { |ds| dataset_from_any(ds) })
      else
        Hamster::Vector.new(datasets.map { |ds| dataset_from_any(ds) })
      end
    end

    ##
    # Creates new Plot with existing data and given options.
    def new_with_options(options)
      self.class.new(@datasets, options)
    end
  end
end
