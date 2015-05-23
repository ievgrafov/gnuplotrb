---
layout: post
title: Project state before coding starts
---

#### About my project

Hi, this summer I will develop new Ruby gem for [Gnuplot](http://www.gnuplot.info/). I aim to build a new user-friendly interface for such an amazing plotting tool which will support modern Gnuplot features such as multiplot and data inside here-doc.

Much more detailed information about the new gem and development process may be found in [my proposal](http://www.google-melange.com/gsoc/proposal/public/google/gsoc2015/dilcom/5629499534213120).

I wrote that proposal about two months ago and spent this time to think more about my project and make some preparation to coding phase. And in this post I want to share with you my thoughts and show what is already done.

#### Functional approach

My proposal does not contain any thoughts about programming style I'm going to use. After discussion with my mentor we decided to choose functional style.

I often use functional style in my Ruby code since it improves readability and safety. It also decreases amount of code I need to write because in functional style one should explain \*what\* to do, not \*how\*.

All above is pretty nice but developing a gem in functional style it's not only about using each\map\inject in every fitting place.
Functional style also comes with some [requirements](http://www.sitepoint.com/functional-programming-techniques-with-ruby-part-i/) to functions such as absence of side-effects.
Since all the functions I'm going to develop are class methods, in order to avoid side-effects I'm going to make objects immutable.

Immutability is a good thing but in this case it may be very inefficient because Gnuplot often works with huge datasets and one of the new gem features is using temporary files for storage to append to them as data updates.
Making everything immutable will make the gem to copy this files before update and only then appending them.
Because of this I prefer the Ruby way of implementation immutability: every method that changes object's state should have two versions, the first one (default, named like #set_options(...)) creates new object with updated data, and the second one (it's name ends with !) changes the existing object. I also want to not allow methods like #option= to avoid modifying objects.

I expect it will both make code safe and allow users to avoid unnecessary copying when they really need high performance.

#### Preparations

As I already mentioned in my proposal, I was going to setup continuos integration tools for my repository. During my preparations to coding phase I worked on installing gnuplot 5.0 at [Travis CI](https://travis-ci.org/) virtual machine and successed.

I also wrote some tests with RSpec. This tests are based on [examples](https://github.com/dilcom/pilot-gnuplot/tree/master/samples) I already have. All of them use both command line and gem to plot some graphs and them compare them pixel-by-pixel. Test considered as passed if comparison found no different pixels.

So anytime the project may be checked for such characteristics as:

+ Current build status [![Build status](https://travis-ci.org/dilcom/pilot-gnuplot.svg?branch=master)](https://travis-ci.org/dilcom/pilot-gnuplot)
+ Current code quality (via CodeClimate) [![Code quality](https://codeclimate.com/github/dilcom/pilot-gnuplot/badges/gpa.svg)](https://codeclimate.com/github/dilcom/pilot-gnuplot/)
+ Test coverage (via CodeClimate) [![Test coverage](https://codeclimate.com/github/dilcom/pilot-gnuplot/badges/coverage.svg)](https://codeclimate.com/github/dilcom/pilot-gnuplot/)

#### Future work

In nearest feature I'm going to start moving along my timeline and next week I will end implementation of Terminal, Dataset and Datablock classes. I also want to spend some time to make my existing code safe in terms of functional style.

Hope I'll like it when the gem will come to its working state.
