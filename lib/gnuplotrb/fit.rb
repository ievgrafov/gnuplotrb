module GnuplotRB
  ##
  # ====== Overview
  # Fit given data with function. Covered in {fit notebook}
  # [https://github.com/dilcom/gnuplotrb/blob/master/notebooks/fitting_data.ipynb].
  # ====== Arguments
  # * *data* - method accepts the same sources as Dataset.new
  #   and Dataset object
  # * *:function* - function to fit data with. Default 'a2*x*x+a1*x+a0'
  # * *:initials* - initial values for coefficients used in fitting.
  #   Default: {a2: 1, a1: 1, a0: 1}
  # * *:via* - coefficients that Gnuplot should change during fitting.
  #   Default: initials#keys
  # * *:term_options* - terminal options that should be setted to terminal before fit.
  #   For example *xrange*, *yrange* etc
  # * *options* - options passed to Gnuplot's fit such as *using*
  # ====== Return value
  # Fit returns hash of 4 elements:
  # * *:formula_ds* - dataset with best fit curve as data
  # * *:coefficients* - hash of calculated coefficients. So if you gave {via: [:a, :b, :c]} or
  #   {initials: {a: 1, b: 1, c: 1} } it will return hash with keys :a, :b, :c and its values
  # * *:deltas* - Gnuplot calculates possible deltas for coefficients during fitting and
  #   *deltas* hash contains this deltas
  # * *:data* - pointer to Datablock with given data
  # ====== Examples
  #   fit(some_data, function: 'exp(a/x)', initials: {a: 10}, term_option: { xrange: 1..100 })
  #   fit(some_dataset, using: '1:2:3')
  def fit(data, function: 'a2*x*x+a1*x+a0', initials: {a2: 1, a1: 1, a0: 1}, via: nil, term_options: {}, **options)
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
    term.set(term_options)
    initials.each { |var_name, value| term.stream_puts "#{var_name} = #{value}" }
    term.stream_puts("fit #{function}" \
                     " #{datablock.to_s(term)}" \
                     " via #{variables.join(',')}" \
                     " #{OptionHandling.ruby_class_to_gnuplot(options)}"
                    )
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

  ##
  # ====== Overview
  # Shortcut for fit with polynomial. Degree here is max power of *x* in polynomial.
  # ====== Arguments
  # * *data* - method accepts the same sources as Dataset.new and Dataset object
  # * *:degree* - degree of polynomial
  # * *options* - all of this options will be passed to *#fit* so you
  #   can set here any *term_options*. If you pass here *:initials* hash, it
  #   will be merged into default initals hash (all values are 1).
  # ====== Return value
  # See the same section for #fit.
  # ====== Examples
  #   fit_poly(some_data, degree: 5, initials: { a4: 10, a2: -1 }, term_option: { xrange: 1..100 })
  #   #=> The same as:
  #   #=> fit(
  #   #=>   some_data,
  #   #=>   function: 'a5*x**5 + a4*x**4 + ... + a0*x**0',
  #   #=>   initals: {a5: 1, a4: 10, a3: 1, a2: -1, a1: 1, a0: 1},
  #   #=>   term_option: { xrange: 1..100 }
  #   #=> )
  def fit_poly(data, degree: 2, **options)
    sum_count = degree + 1
    initials = sum_count.times.map { |i| ["a#{i}".to_sym, 1] }.to_h
    options[:initials] = initials.merge(options[:initials] || {})
    function = sum_count.times.map { |i| "a#{i}*x**#{i}" }.join(' + ')
    fit(data, **options, function: function)
  end

  ##
  # ====== Overview
  # Shortcuts for fitting with several math functions (exp, log, sin).
  # ====== Arguments
  # * *data* - method accepts the same sources as Dataset.new and Dataset object
  # * *options* - all of this options will be passed to *#fit* so you
  #   can set here any *term_options*. If you pass here *:initials* hash, it
  #   will be merged into default initals hash { yoffset: 0.1, xoffset: 0.1, yscale: 1, xscale: 1 }
  # ====== Return value
  # See the same section for #fit.
  # ====== Examples
  #   fit_exp(some_data, initials: { yoffset: -11 }, term_option: { xrange: 1..100 })
  #   #=> The same as:
  #   #=> fit(
  #   #=>   some_data,
  #   #=>   function: 'yscale * (yoffset + exp((x - xoffset) / xscale))',
  #   #=>   initals: { yoffset: -11, xoffset: 0.1, yscale: 1, xscale: 1 },
  #   #=>   term_option: { xrange: 1..100 }
  #   #=> )
  #   fit_exp(...)
  #   fit_sin(...)
  %w(exp log sin).map do |fname|
    define_method("fit_#{fname}".to_sym) do |data, **options|
      options[:initials] = {
        yoffset: 0.1,
        xoffset: 0.1,
        yscale: 1,
        xscale: 1
      }.merge(options[:initials] || {})
      function = "yscale * (yoffset + #{fname} ((x - xoffset) / xscale))"
      fit(data, **options, function: function)
    end
  end

  private

  ##
  # It takes some time to produce output so here we need
  # to wait for it.
  def wait_for_output(term)
    # now we should catch 'error' from terminal: it will contain approximation data
    # but we can get a real error instead of output, so lets wait for limited time
    start = Time.now
    output = ''
    until output.include?('Final set of parameters')
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

  ##
  # Parse Gnuplot's output to get coefficients and their deltas
  # from it. Also replaces coefficients in given function with
  # exact values.
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
end