Visualize pixel events
======================

Visualizes pixel events for given product catalog / product set by providing data set for GNU plot

Prerequisities
--------------

* Ruby >= 2.3
* Bundler
* GNU Plot

Installation
------------

    bundle install

Usage
-----

Get to help screen with

    bundle exec ruby investigate.rb -h

To get events for the pixel associated with product set 123

    bundle exec ruby investigate.rb --product_set 123 > data.dat
    gnuplot -e "filename='data.dat'" histogram.gpi > data.svg
