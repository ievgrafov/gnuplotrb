---
layout: post
title: GnuplotRB - GSoC 2015 project
---
### Introduction

Hi, I'm Ivan Evgrafov and this summer I've been participating in [Google Summer of Code]()
 with [GnuplotRB project]() (plotting tool for Ruby users based on [Gnuplot]())
 for [SciRuby](). GSoC is almost over and I'm releasing v0.3.1 of GnuplotRB as a [gem]().
 In this blog post I want to introduce the gem and highlight some of its capabilities.

### Features

There are several existing plotting tools for Ruby such as Nyaplot, Plotrb, Rubyvis
 and Gnuplot gem. Althought they are not designed for large datasets and have less
 plotting styles and options than Gnuplot. Gnuplot gem is developed far ago and nowadays consist
 mostly of hacks and does not support modern Gnuplot features such as multiplot.

Therefore my goal was to develop new gem for Gnuplot which would allow to use its
 features in Ruby. I was inspired to build easy-to-use interface for most common
 used features of Gnuplot and allow users to customize their plots with
 Gnuplot options as easy as possible in Ruby way.

#### 2D and 3D plots

The main feature of every plotting tool is its ability to plot graphs. Gnuplot(RB) allows you
 to plot both mathematical formula  and (huge) sets of data. Gnuplot(RB) supports plotting
 2D graphs (GnuplotRB::Plot class)  in cartezian/parametric/polar coordinates and 3D
 graphs (GnuplotRB::Splot class) - in cartezian/cylindrical/spherical coordinates.

There are vast of plotting styles supported by Gnuplot(RB):

- points
- lines
- histograms
- boxerrorbars
- circles
- boxes
- filledcurves
- vectors
- heatmap
- etc (full list in [gnuplot doc](http://www.gnuplot.info/docs_5.0/gnuplot.pdf) p. 47)

Example of basic plot:
  code here
<img here\>

More examples:
- Notebooks list here

#### Multiplot

GnuplotRB::Multiplot allows users to place several plots on a single layout and output
 them at once (e.g. to png file).

Basic example:
  code here
<img here\>

More examples:
- something here

#### Animated plots

Gnuplot(RB) may output any plot to gif file but GnuplotRB::Animation allows
 to make this gif animated. It takes several Plot or Splot objects just as
 Multiplot does and outputs them one-by-one as frames of gif animation.

Example:

More examples:

#### Fit

Although the main GnuplotRB's purpose is to provide you with swift, robust and
 easy-to-use plotting tool, it also offers Fit module that contains several
 methods for fitting given data with a function.

Example:


Shortcuts:
- fit log\exp\sin
- fit polynomial

#### Integration

##### Embedding plots into iRuby notebooks



##### Using data from Daru containers



#### Possible datasources for plots

You can pass to Plot (or Splot or Dataset) constructor data in following forms:

- String containing mathematical formula (e.g. 'sin(x)')
- String containing name of file with data (e.g. 'points.data')
- Some Ruby object responding to ``#to_gnuplot_points``
  - Array
  - Daru::Dataframe
  - Daru::Vector

### Additional links

- [Project proposal]()
- [Gem page on Rubygems]()
- [Project repository]()
- [Gem documentation on Rubydoc]()
- [Blog of the project]()
- [Examples]()
- [iRuby notebooks]()

