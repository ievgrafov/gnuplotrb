module GnuplotRB
  def fit(data, function: 'a*x*x+b*x+c', initials: {a: 1, b: 1, c: 1}, via: nil, **options)
  	datablock = case data
                when Dataset
      	          data.data
       	        when Datablock
                  data
                else
                  Datablock.new(data)
                end
    variables = via || initials.keys
    term = Terminal.new
    initials.each { |var_name, value| term << "#{var_name} = #{value}\n" }
    term << "fit #{function}" \
            " #{datablock.to_s(term)}" \
            " via #{variables.join(',')}" \
            " #{OptionHandling.ruby_class_to_gnuplot(options)}" \
            "\n"
    output = wait_for_output(term)
    term.close
    res = parse_output(variables, function, output)
    {
      formula_ds: Dataset.new(res[2], title: 'Fit formula'),
      coefficients: res[0],
      deltas: res[1],
      data: datablock
    }
  end

  def wait_for_output(term)
    # now we should catch 'error' from terminal: it will contain approximation data
    # but we can get a real error instead of output, so lets wait for limited time
    start = Time.now
    output = ''
    until output.include?('correlation matrix')
      begin
        term.check_errors
      rescue GnuplotRB::GnuplotError => e
        output += e.message
      end
      if Time.now - start > Settings.max_fit_delay
        fail GnuplotError, "Seems like there is an error in gnuplotrb: #{output}"
      end
    end
    output
  end

  def parse_output(variables, function, output)
    plottable_function = " #{function.clone} "
    coefficients = {}
    deltas = {}
    variables.each do |var|
      value, error = output.scan(/#{var} *= ([^ ]+) *\+\/\- ([^ ]+)/)[0]
      plottable_function.gsub!(/#{var}([^0-9a-zA-Z])/) { value + $1 }
      coefficients[var] = value.to_f
      deltas[var] = error.to_f
    end
    [coefficients, deltas, plottable_function]
  end

  def method_missing(meth_id, *args)
    meth = meth_id.id2name
    super unless meth[0..2] == 'fit'
    options = args[0] || {}
    options[:initials] ||= {}
    case meth[4..-1]
    when /poly.*_([0-9]+)/
      power = $1.to_i + 1
      opts = power.times.map { |i| ["a#{i}".to_sym, 1] }.to_h
      fun = power.times.map { |i| "a#{i}*x**#{i}" }.join(' + ')
    when /(exp|sin|log)/
      opts = { yoffset: 0.1, xoffset: 0.1, yscale: 1, xscale: 1}
      fun = "yscale * (yoffset + #{$1} ((x - xoffset) / xscale))"
    end
    options[:initials] = opts.merge(options[:initials])
    options[:function] ||= fun
    fit(options)
  end

  private :wait_for_output, :parse_output
end