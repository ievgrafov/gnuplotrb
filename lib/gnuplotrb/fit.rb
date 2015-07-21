module GnuplotRB
  def fit(data, function: 'a2*x*x+a1*x+a0', initials: {a2: 1, a1: 1, a0: 1}, via: nil, **options)
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

  def fit_poly(data, degree: 2, **options)
    sum_count = degree + 1
    initials = sum_count.times.map { |i| ["a#{i}".to_sym, 1] }.to_h
    function = sum_count.times.map { |i| "a#{i}*x**#{i}" }.join(' + ')
    fit(data, **options, function: function, initials: initials)
  end

  %w(exp log sin).map do |fname|
    define_method("fit_#{fname}".to_sym) do |data, **options|
      initials = { yoffset: 0.1, xoffset: 0.1, yscale: 1, xscale: 1}
      function = "yscale * (yoffset + #{fname} ((x - xoffset) / xscale))"
      fit(data, **options, function: function, initials: initials)
    end
  end

  private :wait_for_output, :parse_output
end