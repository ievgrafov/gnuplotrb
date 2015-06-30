require 'tempfile'
require 'hamster'
require 'open3'

def require_if_available(name)
  begin
    require name
  rescue LoadError
    false
  end
end

require_if_available('daru')

require 'gnuplotrb/external_classes/string'
require 'gnuplotrb/external_classes/array'
require 'gnuplotrb/external_classes/daru'
require 'gnuplotrb/external_classes/iruby'

require 'gnuplotrb/version'
require 'gnuplotrb/staff/settings'
require 'gnuplotrb/mixins/option_handling'
require 'gnuplotrb/mixins/error_handling'
require 'gnuplotrb/mixins/plottable'
require 'gnuplotrb/staff/terminal'
require 'gnuplotrb/staff/datablock'
require 'gnuplotrb/staff/dataset'
require 'gnuplotrb/plot'
require 'gnuplotrb/splot'
require 'gnuplotrb/multiplot'

