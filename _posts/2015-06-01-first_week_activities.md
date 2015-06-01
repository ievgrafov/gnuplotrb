---
layout: post
title: First week progress
---
### Introduction

Hi, first week of GSOC 2015 is over and in this post I want to explain what progress I had and provide you some thoughts about my objectives for the next week.

### Working features

Gnuplot gem already may be used to plot some 2D graphs. It can plot math functions, data given in file or in Ruby Array.
You may plot in cartesian or polar coordinates and set functions with parametric formulas.

I think [examples from repository](https://github.com/dilcom/pilot-gnuplot/tree/master/samples) are more informative.
Most of them are used to test gnuplot gem in specs so you may be sure they work since Travis CI builds are successful.

#### Plotting data from existing file

When you need to plot data from file you should not read it and them pass to gem as data. All you need is to pass file name.
In this case file is *not* read by Ruby and piped out to Gnuplot. Only its *name* piped out to Gnuplot. And Gnuplot takes care of reading and plotting itself. Plotting from datafiles with gnuplot gem works as fast as with Gnuplot itself.

More information and samples of that case may be found in [mailing list](https://groups.google.com/forum/#!topic/sciruby-dev/lhWvb5hWc3k).

### Installation (variant used during development)

#### Dependencies:
- Ruby 2.0.0+
- Gnuplot 5.0+

#### How to install with Gemfile
- create Gemfile with following contents
{% highlight ruby %}
source 'https://rubygems.org'
gem 'pilot-gnuplot', :git => 'https://github.com/dilcom/pilot-gnuplot.git'
{% endhighlight %}
- run 'bundle install' in directory with Gemfile

#### How to install without creating Gemfile
Run following commands:
{% highlight bash %}
git clone https://github.com/dilcom/pilot-gnuplot.git
cd pilot-gnuplot
bundle install
rake install
{% endhighlight %}

#### Usage
{% highlight bash %}
require 'pilot-gnuplot'
include Gnuplot
  
# see examples
{% endhighlight %}
Examples: https://github.com/dilcom/pilot-gnuplot/tree/master/samples

### Objectives for this week

This week I'm going to focus on trying to use Daru for storage data in memory. I will also need to write specs for Datablock and Plot. And finally I'm going to share the gem and samples with community to recieve feedbacks and make gem better.
