module Gnuplot
  class Plot
    def initialize(*datasets, **options)
      @datasets = datasets.map{ |dataset| dataset.is_a?(Dataset) ? dataset : Dataset.new(*dataset) }
      @options = options
      @cmd = 'plot '
      @last_term = nil
      yield if block_given?
    end

    def plot(term = nil, **options)
      @last_term = term || @last_term || Terminal.new
      @last_term.restore_options
      @last_term.apply_options(@options.merge(options))
      @last_term.puts(@cmd + @datasets.map{ |dataset| dataset.to_s(@last_term) }.join(' , '))
    end

    def to_png(path = nil, *options)
      if path
        result = self.plot(Terminal.new, term: ['png', options], output: path)
      else
        path = Dir::Tmpname.make_tmpname('png', 0)
        plot(Terminal.new, term: ['png', options], output: path)
        sleep(0.1) until File.exist?(path)
        puts path
        result = File.binread(path)
      end
      result
    end
  end
end