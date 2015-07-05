
* Array and Array of Numeric
{% highlight ruby %}
['png', [300, 300]]
#=> 'png 300,300'
{% endhighlight %}
* Hash
{% highlight ruby %}
{data: 'histograms'}
#=> 'data histograms'
{% endhighlight %}
* Range
{% highlight ruby %}
{xrange: 0..100}
#=> 'xrange [0:100]'
{% endhighlight %}
* Boolean
{% highlight ruby %}
{multiplot: true}
#=> 'multiplot'
{% endhighlight %}
* Hashes with underscored keys (see [#7](https://github.com/dilcom/gnuplotrb/issues/7))
{% highlight ruby %}
{style_data: 'histograms'}
#=> 'style data histograms'
{% endhighlight %}
* Others
{% highlight ruby %}
object #=> object.to_s
{% endhighlight %}
* Nested structures
{% highlight ruby %}
{output: 'plot.png', term: ['pngcairo', size: [500,300], fsize: 14]}
#=> 
{% endhighlight %}