---
layout: post
title: First half of june progress
---
#### Introduction

Hi, last several weeks I spend developing gem parts which allow to plot 3D visualizations (Splot) and place several plots on single layout (Multiplot).
I found cases when current Terminal was unable to set some gnuplot options and fixed it.
GnuplotRB now may be used in iRuby notebooks, see [notebook readme](https://github.com/dilcom/gnuplotrb/blob/master/notebooks)
Last week (15-19.06) I also reviewed ruby bindings for symengine (developed by Abinash Meher) and Alexej Gossmann reviewed my project.

#### 3D plots and multiplotting

To implement plotting 3D visualizations with GnuplotRB I developed Splot that inherited almost all features from Plot. I also added [example](https://github.com/dilcom/gnuplotrb/tree/master/examples/plot_3d_surface) for that type of visualization and [a notebook](https://github.com/dilcom/gnuplotrb/blob/master/notebooks/3d_plot.ipynb).

Multiplot class was developed to allow placing several visualizations on one layout.
It takes several Plot or Splot objects and options.
Most of options are handled just as in any other plottable object but Multiplot also have two speciefic options:

* :title is a string that should be placed above all the plots on that layout
* :layout is size of layout, possible values: [r, c], 'r c' and so on. 'r' here is number of rows and "c" is number of columns in Multiplot.

Unfortunately I still haven't add a notebook for that kind of plots (will add soon) but there is an [example](https://github.com/dilcom/gnuplotrb/tree/master/examples/multiplot) for it.

#### Multi word keys in options

Last week I found that some options of gnuplot have multi word keys (e.g. 'set style data ...' and 'set style fill ...'). Since GnuplotRB allows only one value for each option key and in this case the key (for GnuplotRB) is 'style' this options can't be used together. To avoid that issue I made GnuplotRB to permit option keys like :style_fill. In this case :style_fill and :style_data are different keys so they can be used together. Before outputting this options to gnuplot, GnuplotRB replaces underscores with spaces. If you have some other ideas how it should be implemented, there is an [github issue](https://github.com/dilcom/gnuplotrb/issues/7) where we can discuss it.

By the way I have one more subject that may be discussed: [error handling](https://github.com/dilcom/gnuplotrb/issues/3).

#### Code review session

As it was stated on the meeting, last week was time for the first code review session. So I reviewed Ruby bindings for symengine ([repository](https://github.com/abinashmeher999/symengine/tree/ruby_file_structure) and [pull request](https://github.com/sympy/symengine/pull/414)) developed by Abinash. I looked through his code and told him about places where in my opinion something should be done another way. I also tried installing his gem on my computer with Ubuntu 14.04 and installation was successful. I wanted to try to use some symengine features but they were WIP so I tested only gem installation and basic object creation.

During that code review session Alexej reviewed my code and found a [bug](https://github.com/dilcom/gnuplotrb/issues/13) that related to outputting updated data to gnuplot.
His review was very thorough and helpful.
He both pointed me on missing and wrong docs and fixed some of them in his pull request.
And he also gave me idea about notebook with example that should be created.

#### Plans for nearest next weeks

1. Add missing specs for Splot and Multiplot
2. Add iRuby notebook for Multiplot
3. Implement Daru support
