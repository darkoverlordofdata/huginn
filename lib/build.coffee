#+--------------------------------------------------------------------+
#| build.coffee
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

_config = null
_plugins = []
_paginator = {}
_page = {}
_site = {}

module.exports =
#
# Generate a site
#
# @param  [String]  cfg alternate config file name
# @return none
#
  run: ($args) ->

    $cfg = 'config.yml'
    $root = path.resolve(__dirname,'..')
    if fs.existsSync("#{$root}/#{$cfg}")
      $config = yaml.load(fs.readFileSync("#{$root}/#{$cfg}"))
    else
      process.exit console.log("ERR: Hugin config file #{$cfg} not found")

    if not fs.existsSync($config.source)
      process.exit console.log("ERR: Hugin source directory #{$config.source} not found")



    #
    # Inialize the site object from configuration
    #
    _site =
      date:
        writable: false, value: new Date()
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
      data:
        writable: false, value: {}
      source:
        writable: false, value: path.resolve(__dirname, '..', $config.source)
      destination:
        writable: false, value: path.resolve(__dirname, '..', $config.destination)

    _site = Object.create($config, _site)
    swig.setDefaults autoescape:false

    #
    # load core plugins:
    #
    #   Filters
    #
    for $name, $function of require("#{__dirname}/filters")
      swig.setFilter $name, $function
    #
    #   Tags
    #
    for $name in fs.readdirSync("#{__dirname}/tags")
      $tag = require("#{__dirname}/tags/#{$name}")
      $tag.connect? _site
      swig.setTag $tag.tag, $tag.parse, $tag.compile, $tag.ends

    #
    #   User plugins
    #
    for $name in fs.readdirSync("#{_site.source}/_plugins")
      $plugin = require("#{_site.source}/_plugins/#{$name}")

      _plugins.push $plugin
      $plugin.connect? _site
      $plugin.generate?()
      if $plugin.tag?
        swig.setTag $plugin.tag, $plugin.parse, $plugin.compile, $plugin.ends
      else if $plugin.filter?
        swig.setFilter $plugin.name, $plugin.filter

    fs.mkdirSync _site.destination unless fs.existsSync(_site.destination)


    #
    # pre-load data & variables
    #
    for $file in fs.readdirSync("#{_site.source}/_data")
      _load_data $file
    for $file in fs.readdirSync("#{_site.source}/_posts")
      _load_post $file
    for $file in fs.readdirSync(_site.source)
      _load_pages $file unless $file[0] is '_'

    #
    # process all posts
    #
    for $file in fs.readdirSync("#{_site.source}/_posts")
      _generate_post $file

    #
    # process all pages
    #
    for $file in fs.readdirSync(_site.source)
      _generate_pages $file unless $file[0] is '_'#


# Generate pages
#
# @param  [String]  tpl template
# @param  [String]  folder  subfolder
# @return none
#
_generate_pages = ($tpl, $folder = '') ->

  $src = path.normalize("#{_site.source}/#{$folder}/#{$tpl}")
  $dst = path.normalize("#{_site.destination}/#{$folder}/#{$tpl}")

  $stats = fs.statSync($src)

  if $stats.isDirectory()

    fs.mkdirSync $dst unless fs.existsSync($dst)
    for $f in fs.readdirSync($src)
      _generate_pages $f, "#{$folder}/#{$tpl}"

  else if $stats.isFile()
    console.log $src
    _generate $src, $dst


#
# Load pages data
#
# @param  [String]  path  template path
# @param  [String]  folder  subfolder
# @return none
#
_load_pages = ($path, $folder = '') ->

  $src = path.normalize("#{_site.source}/#{$folder}/#{$path}")
  $stats = fs.statSync($src)

  if $stats.isDirectory()
    for $f in fs.readdirSync($src)
      _load_pages $f, "#{$folder}/#{$path}"

  else if $stats.isFile()
    if path.extname($src) in ['.html']
      _site.pages.push _load($src)


#
# Generate a post from template
#
# @param  [String]  path  template path
# @return none
#
_generate_post = ($path) ->
  $seg = $path.split('-')
  $yy = $seg.shift()
  $mm = $seg.shift()
  $dd = $seg.shift()
  $link = $seg.join('-')

  fs.mkdirSync "#{_site.destination}/#{$yy}" unless fs.existsSync("#{_site.destination}/#{$yy}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}/#{$dd}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}")

  $src = path.normalize("#{_site.source}/_posts/#{$path}")
  $dst = path.normalize("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}/#{$link}")

  _generate $src, $dst

#
# Load post data
#
# @param  [String]  path  template path
# @return none
#
_load_post = ($path) ->
  $src = path.normalize("#{_site.source}/_posts/#{$path}")
  _site.posts.push _load($src)


#
# Load data file
#
# @param  [String]  path  data file path
# @return none
#
_load_data = ($path) ->
  $path = path.normalize("#{_site.source}/_data/#{$path}")
  $ext = path.extname($path)
  $name = path.basename($path, $ext)
  switch $ext
    when '.yml'     then _site.data[$name] = yaml.load(fs.readFileSync($path))
    when '.json'    then _site.data[$name] = require($path)
    when '.js'      then _site.data[$name] = require($path)
    when '.coffee'  then _site.data[$name] = require($path)
    else console.log "WARN: Unknown data format: #{$path}"




#
# Generate a page from a template
#
# @param  [String]  template
# @param  [String]  page
# @return none
#
_generate = ($template, $page) ->

  $fm = null
  $buf = String(fs.readFileSync($template))
  if $buf[0..3] is '---\n'
    # pull out the front matter and parse with yaml
    $buf = $buf.split('---\n')
    $fm = yaml.load($buf[1])
    $buf = $buf[2]


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
    content: $buf
  for $key, $val of $fm
    _page[$key] = $val

  $buf = swig.render($buf, filename: $template, locals: page: _page, site: _site, paginator: _paginator, test: [1,2,3])
  if _page.layout?
    $layout = "#{_site.source}/_layouts/#{_page.layout}.html"
    $buf =  swig.renderFile($layout, content: $buf, page: _page, site: _site, paginator: _paginator)

  fs.writeFileSync $page, $buf

#
# Load page/post data
#
# @param  [String]  template
# @param  [String]  page
# @return none
#
_load = ($template) ->

  $fm = null
  $buf = String(fs.readFileSync($template))
  if $buf[0..3] is '---\n'
    # pull out the front matter and parse with yaml
    $buf = $buf.split('---\n')
    $fm = yaml.load($buf[1])
    $buf = $buf[2]


  _page =
    category: ''
    categories: []
    content: $buf
    date: ''
    excerpt: ''
    id: ''
    path: ''
    tag: ''
    tags: []
    title: ''
    url: ''
  for $key, $val of $fm
    _page[$key] = $val
  _page


