#+--------------------------------------------------------------------+
#| Page.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013 - 2014
#+--------------------------------------------------------------------+
#|
#| This file is a part of Huginn
#|
#| Huginn is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
#
# Generate a page
#
fs = require('fs')
path = require('path')
yaml = require('yaml-js')


module.exports = class Page

  category: ''
  categories: null
  content: ''
  date: null
  excerpt: ''
  id: ''
  path: ''
  tag: ''
  tags: null
  title: ''
  url: ''

  #
  # Load template data
  #
  # @param  [Object]  site parent
  # @param  [String]  template
  # @param  [String]  page
  # @return none
  #
  constructor: ($site, $template, $extra = {}) ->

    $hdr = null
    $buf = String(fs.readFileSync($template))

    if $buf[0..3] is '---\n'
      # pull out the header and parse with yaml
      $buf = $buf.split('---\n')
      $hdr = yaml.load($buf[1])
      $buf = $buf[2]


    @categories = []
    @content = $buf
    @date = new Date
    @tags = []
    @url = $site.parseUrl($template).path

    if ($url = $site.parseUrl($template)).post
      @date = new Date($url.yyyy, $url.mm-1, $url.dd)

    for $key, $val of $hdr
      @[$key] = $val

    for $key, $val of $extra
      @[$key] = $val


