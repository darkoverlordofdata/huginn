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

_site       = {}
_paginator  = {}
_plugins    = []


module.exports =
#
# Generate a site
#
# @param  [String]  cfg alternate config file name
# @return none
#
  run: ($args) ->

    $cfg = 'config.yml'
    $root = process.cwd()
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
        writable: false, value: path.resolve($root, $config.source)
      destination:
        writable: false, value: path.resolve($root, $config.destination)

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
    fs.mkdirSync "#{_site.destination}/assets" unless fs.existsSync("#{_site.destination}/assets")


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

  url: ($path) ->
    _post_url($path)

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
  $slug = $seg.join('-')

  fs.mkdirSync "#{_site.destination}/#{$yy}" unless fs.existsSync("#{_site.destination}/#{$yy}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}")
  fs.mkdirSync "#{_site.destination}/#{$yy}/#{$mm}/#{$dd}" unless fs.existsSync("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}")

  $src = path.normalize("#{_site.source}/_posts/#{$path}")
  $dst = path.normalize("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}/#{$slug}")

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
# Generate a post url from a template path
#
# @param  [String]  path  template file path
# @return none
#
_post_url = ($template) ->

  if $template.indexOf(_site.source) is 0
    $template = $template.substr(_site.source.length)
  if $template[0] is '/'
    $template = $template.substr(1)

  $path = path.dirname($template)
  $ext = path.extname($template)
  $name = path.basename($template, $ext)

  if $path is '_posts'

    $seg = $name.split('-')
    $yy = $seg.shift()
    $mm = $seg.shift()
    $dd = $seg.shift()
    $slug = $seg.join('-')
    "/#{$yy}/#{$mm}/#{$dd}/#{$slug}#{$ext}"
  else
    if $path is '.'
      "/#{$name}#{$ext}"
    else
      "/#{$path}/#{$name}#{$ext}"


#
# Generate a page from a template
#
# @param  [String]  template
# @param  [String]  page
# @return none
#
_generate = ($template, $path) ->

  $buf = String(fs.readFileSync($template))

  if path.extname($template) is '.html'

    $fm = null
    if $buf[0..3] is '---\n'
      # pull out the front matter and parse with yaml
      $buf = $buf.split('---\n')
      $fm = yaml.load($buf[1])
      $buf = $buf[2]


    $page =
      content: ''
      title: ''
      excerpt: ''
      url: _post_url($template)
      date: ''
      id: ''
      categories: []
      tags: []
      path: ''
      content: $buf
    for $key, $val of $fm
      $page[$key] = $val

    $buf = swig.render($buf, filename: $template, locals: page: $page, site: _site, paginator: _paginator, test: [1,2,3])
    if $page.layout?
      $layout = "#{_site.source}/_layouts/#{$page.layout}.html"
      $buf =  swig.renderFile($layout, content: $buf, page: $page, site: _site, paginator: _paginator)

  fs.writeFileSync $path, $buf

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


  $page =
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
    url: _post_url($template)
  for $key, $val of $fm
    $page[$key] = $val
  $page


