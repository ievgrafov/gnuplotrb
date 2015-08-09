module GnuplotRB
  ##
  # Splot class correspond to simple 3D visualisation.
  # Most of Plot's docs are right for Splot too.
  #
  # Examples of usage are in
  # {a notebook}[http://nbviewer.ipython.org/github/dilcom/gnuplotrb/blob/master/notebooks/3d_plot.ipynb]
  class Splot < Plot
    ##
    # @param *datasets [Sequence of Dataset or Array] either instances of Dataset class or
    #   "[data, **dataset_options]"" arrays
    # @param options [Hash] see Plot top level doc for options examples
    def initialize(*datasets, **options)
      super
      @cmd = 'splot '
    end
  end
end
