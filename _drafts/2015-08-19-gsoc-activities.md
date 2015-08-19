---
layout: post
title: GSoC 2015
---
## Introduction

Hi, GSoC 2015 is almost over and in this blog post I want to draw a
 line under my activities related to GnuplotRB project and
 compare project [proposal]() with developed
 [gem]().

## Activities during this summer



### Pre-midterm contributions

#### Travis CI and Co

To be sure that I'm not breaking anything with new contributions,
 I added Travis CI build configuration for my project and
 used Codeclimate with its testcoverage gem. I ran tests via Travis on
 both MRI (2.0, 2.1, 2.2) and Jruby (9.0.0.0).

I also used Rubocop to check my code from time to time for style
 and code complexity issues.

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

### Post-midterm contributions

#### GnuplotRB::Animation

#### GnuplotRB::Fit

#### Notebooks

## Comparison

All features mentioned in project proposal were developed.
 Interface of GnuplotRB gem is very similar to proposed.
 I only added safe and destructive update methods and
 support for iRuby and Daru containers.

