module GnuplotRB
  ##
  # === Overview
  # Splot class correspond to simple 3D visualisation
  class Splot < Plot
    ##
    # ==== Arguments
    # * *datasets* are either instances of Dataset class or
    #   [data, **dataset_options] arrays
    # * *options* will be considered as 'settable' options of gnuplot
    #   ('set xrange [1:10]' for { xrange: 1..10 }, "set title 'plot'"
    #   for { title: 'plot' } etc)
    def initialize(*datasets, **options)
      super
      @cmd = 'splot '
    end
  end
end
