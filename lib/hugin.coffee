#+--------------------------------------------------------------------+
#| coffee
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

#
# Generate pages
#
# @param  [String]  tpl template
# @param  [String]  folder  subfolder
# @return none
#
_pages = ($tpl, $folder = '') ->

  $src = path.normalize("#{_site.source}/#{$folder}/#{$tpl}")
  $dst = path.normalize("#{_site.destination}/#{$folder}/#{$tpl}")

  $stats = fs.statSync($src)

  if $stats.isDirectory()

    fs.mkdirSync $dst unless fs.existsSync($dst)
    for $f in fs.readdirSync($src)
      _pages $f, "#{$folder}/#{$tpl}"

  else if $stats.isFile()
    console.log $src
    _generate $src, $dst


#
# Load pages data
#
# @param  [String]  tpl template
# @param  [String]  folder  subfolder
# @return none
#
_load_pages = ($tpl, $folder = '') ->

  $src = path.normalize("#{_site.source}/#{$folder}/#{$tpl}")
  $stats = fs.statSync($src)

  if $stats.isDirectory()
    for $f in fs.readdirSync($src)
      _load_pages $f, "#{$folder}/#{$tpl}"

  else if $stats.isFile()
    if path.extname($src) in ['.html']
      _site.pages.push _load($src)


#
# Generate a post from template
#
# @param  [String]  tpl template
# @return none
#
_post = ($tpl) ->
  $seg = $tpl.split('-')
  $yy = $seg.shift()
  $mm = $seg.shift()
  $dd = $seg.shift()
  $link = $seg.join('-')

  fs.mkdirSync "#{_site.destination}/#{$yy}" unless fs.existsSync("#{_site.destination}/#{$yy}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}/#{$dd}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}")

  $src = path.normalize("#{_site.source}/_posts/#{$tpl}")
  $dst = path.normalize("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}/#{$link}")

  _generate $src, $dst

#
# Load post data
#
# @param  [String]  tpl template
# @return none
#
_load_post = ($tpl) ->
  $src = path.normalize("#{_site.source}/_posts/#{$tpl}")
  _site.posts.push _load($src)


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
  _page


module.exports =
  #
  # Generate a site
  #
  # @return none
  #
  main: ($cfg = '_config.yml') ->

    swig.setDefaults autoescape:false
    #
    # Get the configuration
    #
    $root = path.resolve(__dirname,'..')
    if fs.existsSync("#{$root}/#{$cfg}")
      $config = yaml.load(fs.readFileSync("#{$root}/#{$cfg}"))
    else
      process.exit console.log("Hugin config file #{$cfg} NOT found")

    if not fs.existsSync($config.source)
      process.exit console.log("No source dir")


    #
    # Inialize the site object with configuration
    #
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
      source:
        writable: false, value: path.resolve(__dirname, '..', $config.source)
      destination:
        writable: false, value: path.resolve(__dirname, '..', $config.destination)

    _site = Object.create($config, _site)

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
    # pre-load post data
    #
    for $f in fs.readdirSync("#{_site.source}/_posts")
      _load_post $f

    #
    # pre-load page data
    #
    for $f in fs.readdirSync(_site.source)
      _load_pages $f unless $f[0] is '_'    #

    # process all posts
    #
    for $f in fs.readdirSync("#{_site.source}/_posts")
      _post $f

    #
    # process all pages
    #
    for $f in fs.readdirSync(_site.source)
      _pages $f unless $f[0] is '_'