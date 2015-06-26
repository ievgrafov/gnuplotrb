require 'tempfile'
require 'hamster'
require 'open3'

require 'gnuplotrb/version'
require 'gnuplotrb/staff/settings'
require 'gnuplotrb/mixins/option_handling'
require 'gnuplotrb/mixins/error_handling'
require 'gnuplotrb/mixins/plottable'
require 'gnuplotrb/mixins/external_classes'
require 'gnuplotrb/staff/terminal'
require 'gnuplotrb/staff/datablock'
require 'gnuplotrb/staff/dataset'
require 'gnuplotrb/plot'
require 'gnuplotrb/splot'
require 'gnuplotrb/multiplot'
require 'gnuplotrb/mixins/iruby'

def require_if_available(name)
  begin
    require name
    true
  rescue
    false
  end
end

require_if_available('daru')
