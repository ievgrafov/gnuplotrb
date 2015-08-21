---
layout: post
title: GSoC 2015
---
## Introduction

Hi, GSoC 2015 is almost over and in this blog post I want to draw a
 line under my activities related to GnuplotRB project and
 compare project [proposal](http://www.google-melange.com/gsoc/proposal/public/google/gsoc2015/dilcom/5629499534213120) with developed
 [gem](https://rubygems.org/gems/gnuplotrb).

## Activities during this summer

### CI, programming style and tests

#### Travis CI and Co

To be sure that I'm not breaking anything with new contributions,
 I added Travis CI build configuration for my project and
 used Codeclimate with its testcoverage gem. I ran tests (RSpec) via Travis on
 both MRI (2.0, 2.1, 2.2) and Jruby (9.0.0.0).

I also used Rubocop to check my code from time to time for style
 and code complexity issues.

For documenting I used RDoc until I realized that Rubydoc uses YARD to parse gem's documentation =).
 After it I fixed docs to satisfy YARD syntax so now it's readable on Rubydoc.

#### Functional style in Ruby

From the very beginning GnuplotRB's classes were immutable. Every time
 user changed it, a new object with given parameters was instantiated.
 Now it`s true for simple methods (not the ones ending with `!` or `=`).
 Destructive update methods (`#option!(value)` or `#option = value`) change
 state of existing object. The idea is taken from Ruby standart library (e.g., `Array#sort`
 and `Array#sort!`).

### Pre-midterm contributions

#### Basic staff classes

I started gem development by designing several staff classes:
 Terminal, Datablock and Dataset. Their main purpose was to create
 a robust base for other plottable classes such as Plot and Multiplot.

#### GnuplotRB::Plot class

My first milestone was to develop staff classes and GnuplotRB::Plot
 that would allow users to plot 2D graphs. During second week I
 implemented Plot as container of Datasets with its own plotting
 methods.

#### GnuplotRB::Splot and Multiplot

After `Plot` was developed it was pretty simple to implement `Splot` on its base.
 The only difference between them is in constructor: the main plotting command for
 `Plot` is `'plot'` while for `Splot` it's `'splot'`.

Multiplot is a little bit different: it is container of plots so I had to
 implement handy methods for updating plots multiplot consists of.

Since most plotting
 methods (`#to_png`, `#to_canvas` etc) were the same for `Plot` and `Multiplot`, I decided
 to move them to `Plottable` module and mixin it into both classes. A little bit later I
 also moved all methods related to option handling into `OptionHandling` module and added it
 into `Plottable` via `Module.extend`. Later it allowed me to make `Dataset` plottable just by adding
 `#plot` method and mixing in it `Plottable` module.

#### Project state before midterm

See [a blog post](http://www.evgrafov.work/gnuplotrb/2015/07/midterm/).

### Post-midterm contributions

#### Error handling

For now error handling wors in the following way:
- Gem checks if given terminal is available with current Gnuplot installation
  (e.g., if user tries to call `Plot#to_missing_term`, he will recieve an error).
- Before outputting each command to Gnuplot pipe, `GnuplotRB::Terminal` now checks
  stderr for errors. This is far from ideal and if you have any ideas how to
  imrove it, please take a part in [a discussion](https://github.com/dilcom/gnuplotrb/issues/3).

#### GnuplotRB::Animation

`GnuplotRB::Animation` is just container for plots with its own rules
 of outputting them. I created it as `Multiplot`'s child,
 wrote new `#plot` and restricted some plotting possibilities (e.g., '#to_png').

Since up to this moment all other plottable classes were able to
 embed themselves into iRuby notebooks, I wanted to embed `Animation`'s GIFs too.
 Now they are embedded as HTML =): GIF is converted to BASE64 and then inserted
 as `<img .../>` tag.

#### GnuplotRB::Fit

This module contain several public methods: `::fit_polynomial`, `::fit_exp`,
 `::fit_log`, `::fit_sin`. Each of them fits given data with methematical function
 mentioned in its name. If you want to use another function, I recommend you to
 look at `::fit` method that accepts function as an argument.

The main problem I faced with was to get output from Gnuplot. Since Terminal's
 ErrorHandling catchs all the output, I had to write a method that collected
 all the errors and took data from them. 

#### Notebooks

During GSoC I wrote several notebook to show GnuplotRB's features and
 provide examples for users. You can find them all in
 [the notebook folder](https://github.com/dilcom/gnuplotrb/tree/master/notebooks).

#### The rest

During last two weeks of GSoC I fixed my docs (made them compatible with YARD)
 and tests (improved coverage and found pair of bugs).

I also wrote a blog post for sciruby.com to introduce the gem to community.

## Comparison

All features mentioned in project proposal were developed.
 Interface of GnuplotRB gem is very similar to proposed.
 I only added safe and destructive update methods and
 support for iRuby and Daru containers. I planned to provide
 GnuplotRB with `Approximation` class for fitting data, but
 later decided to add `Fit` module instead.
