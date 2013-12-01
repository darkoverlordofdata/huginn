#+--------------------------------------------------------------------+
#| util.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Hugin
#|
#| Hugin is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
fs = require('fs')
path = require('path')
yaml = require('yaml-js')
swig = require('swig')



_fm = /^---[\n]+(?:\w+\s*:\s*\w+\s*[\n])*---[\n]/

_config = null
_paginator = {}
_page = {}
_site =
  time:
    writable: false, value: (new Date()).getTime()
  pages:
    writable: false, value: []
  posts:
    writable: false, value: []
  related_posts:
    writable: false, value: []
  categories:
    writable: false, value: []
  tags:
    writable: false, value: []



#
# resolve the path
#
# @return [Object] the path
#
_path = ($path) ->
  path.resolve(__dirname,'..', $path)


#
# Get the configuration
#
# @return [Object] the Config object
#
_get_config = ->
  if fs.existsSync(_path('config.js'))
    require(_path('config.js'))
  else if fs.existsSync(_path('config.coffee'))
    require(_path('config.coffee'))
  else if fs.existsSync(_path('_config.yml'))
    yaml.load(fs.readFileSync(_path('_config.yml')))
  else
    null

_site = Object.create(_get_config(), _site)


module.exports =

  #
  # Get the configuration
  #
  # @return [Object] the Config object
  #
  config: ->
    _config = _config ? _get_config()

  #
  # Generate items from template
  #
  # @param  [String]  src source root
  # @param  [String]  dst destination root
  # @param  [String]  tpl template
  # @param  [String]  folder  subfolder
  # @return none
  #
  generate: ($src, $dst, $folder, $tpl) ->

    _page =
      content: ''
      title: ''
      excerpt: ''
      url: ''
      date: ''
      id: ''
      categories: []
      tags: []
      path: ''

    $file = path.resolve("#{$src}/#{$folder}/#{$tpl}")
    $use_fm = false
    $buf = String(fs.readFileSync($file))
    #
    # Load page[] with front-matter
    #
    if ($front = $buf.match(_fm))?
      $use_fm = true
      $buf = $buf.replace(_fm, '')
      for $var in $front[0].split("\n").slice(1,-2)
        $a = $var.split(/\s*:\s*/)
        _page[$a[0]] = $a[1]

    _page.content = $buf

    if $use_fm
      $buf = swig.render($buf, filename: $file, locals: page: _page, site: _site, paginator: _paginator)

    fs.writeFileSync "#{$dst}/#{$folder}/#{$tpl}", $buf

# load core plugins
plugin = require('./plugin')
