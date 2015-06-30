if defined?(IRuby)
   module IRuby::Display::Registry
      type { GnuplotRB::Plottable }
      format 'image/svg+xml' do |obj|
         options = obj.term ? obj.term[1] : {}
         obj.to_svg(options)
       end
   end
end
