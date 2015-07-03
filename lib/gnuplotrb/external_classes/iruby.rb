if defined?(IRuby)
  module GnuplotRB
    module Plottable
      def to_iruby
        available_terminals = {
          'png'      => 'image/png',
          'pngcairo' => 'image/png',
          'jpeg'     => 'image/jpeg',
          'svg'      => 'image/svg+xml',
          'dumb'     => 'text/plain'
        }
        terminal, options = term.is_a?(Array) ? [term[0], term[1]] : [term, {}]
        terminal = 'svg' unless available_terminals.keys.include?(terminal)
        [available_terminals[terminal], self.send("to_#{terminal}".to_sym, **options)]
      end
    end
  end
end
