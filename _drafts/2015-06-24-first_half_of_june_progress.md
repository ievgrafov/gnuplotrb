---
layout: post
title: First half of june progress
---
### Introduction

Hi, last several weeks I spend developing gem parts which allowed to plot 3D visualizations (Splot) and place several plots on single layout (Multiplot).
I found cases when current Terminal was unable to set some gnuplot options and fixed this issues.
Last week (15-19.06) I also reviewed ruby bindings for symengine (developed by Abinash) and Alexej reviewed my project.

### 3D plots and multiplotting

To implement plotting 3D visualizations with GnuplotRB I developed Splot that inherited almost all features from Plot. I also added [example](!example link here) for that type of visualization and a [notebook](notebook link here).

Multiplot class was developed to allow placing several visualizations on one layout.
It takes several Plot or Splot objects and options.
Most of options are handled just as in any other plottable object but Multiplot also have two speciefic options:
* :title is a string that should be placed above all the plots on that layout
* :layout is size of layout, possible values: [x, y], 'x y' and so on. X is number of column and y is number of rows in Multiplot.

Unfortunately I still haven't add a notebook for that kind of plots but there is an [example](example link here) in repository for it.

### Multi word keys in options

Last week I found that some options of gnuplot have multi word keys (e.g. 'set style data ...' and 'set style fill ...'). Since GnuplotRB allows only one value for each option key and in this case the key (for GnuplotRB) is 'style' this options can't be used. To avoid that issue I made GnuplotRB to permit option keys like :style_fill. In this case :style_fill and :style_data are different keys so they can be used together. Before outputting this options to gnuplot, GnuplotRB replaces underscores with spaces.

### Code review session

As it was stated on the first Sciruby GSoC meeting last week was time for code review session. So I reviewed Ruby bindings for symengine developed by Abinash. I looked through his code and let him know about places where in opinion something should be done another way.
I also tried installing his gem on my computer with Ubuntu 14.04 and installation was successful. I wanted to try to use some symengine features but they were WIP so I tested only gem installation and basic object creation.


During that code review session Alexej reviewed my code and found a bug that related to outputting updated data to gnuplot.
His review was very thorough and helpful.
He both pointed me on missing and wrong docs and fixed some of them in his pull request.
And he gave me idea about notebook with example that should be created.

