#+--------------------------------------------------------------------+
#| build.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2013
#+--------------------------------------------------------------------+
#|
#| This file is a part of Huginn
#|
#| Huginn is free software; you can copy, modify, and distribute
#| it under the terms of the MIT License
#|
#+--------------------------------------------------------------------+
#
fs = require('fs')
path = require('path')
yaml = require('yaml-js')
liquid = require('./liquid.coffee')
#
# path to the Liquid.js distribution
#
LIQUID_JS = path.resolve(__dirname, '..', 'liquid.js/dist/liquid.js')
#
# valid template filetypes
#
TYPES = ['.html', '.xml']
#
# Liquid.js module
#
Liquid      = null

_site       = {}  # Site object tree
_paginator  = {}  # Pagination object


module.exports = build =
#
# Generate a site
#
# @param  [Array<String>]  command line args
# @return none
#
  run: ($args) ->

    $cfg = if '--dev' in $args then 'config-dev.yml' else 'config.yml'
    $root = process.cwd()
    if fs.existsSync("#{$root}/#{$cfg}")
      $config = yaml.load(fs.readFileSync("#{$root}/#{$cfg}"))
    else
      process.exit console.log("ERR: Huginn config file #{$cfg} not found")

    if not fs.existsSync($config.source)
      process.exit console.log("ERR: Huginn source directory #{$config.source} not found")



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

    Liquid = liquid(LIQUID_JS, "#{_site.source}/_includes")
    #
    # load core plugins:
    #
    #   Filters
    #
    Liquid.Template.registerFilter require("#{__dirname}/filters.coffee")
    #
    #   Tags
    #
    for $name in fs.readdirSync("#{__dirname}/tags")
      $tag = require("#{__dirname}/tags/#{$name}")
      $tag Liquid, _site, build


    $plugins = []
    #
    # System plugins
    #
    if _site.plugins?
      for $name in _site.plugins
        $plugins.push require($name)

    #
    # User plugins
    #
    if fs.existsSync("#{_site.source}/_plugins")
      for $name in fs.readdirSync("#{_site.source}/_plugins")
        $plugin = require("#{_site.source}/_plugins/#{$name}")
        $plugins.push $plugin

    #
    # pre-load data
    #
    if fs.existsSync("#{_site.source}/_data")
      for $file in fs.readdirSync("#{_site.source}/_data")
        _load_data $file

    #
    # pre-load posts
    #
    if fs.existsSync("#{_site.source}/_posts")
      for $file in fs.readdirSync("#{_site.source}/_posts")
        _load_post $file

    #
    # pre-load drafts?
    #
    if '-d' in $args or '--drafts' in $args
      if fs.existsSync("#{_site.source}/_drafts")
        for $file in fs.readdirSync("#{_site.source}/_drafts")
          _load_post $file

    #
    # pre-load pages
    #
    for $file in fs.readdirSync(_site.source)
      _load_pages $file unless $file[0] is '_'

    #
    # Build the output
    #
    fs.mkdirSync _site.destination unless fs.existsSync(_site.destination)
    fs.mkdirSync "#{_site.destination}/assets" unless fs.existsSync("#{_site.destination}/assets")

    #
    # initialize plugins
    #
    for $plugin in $plugins
      $plugin Liquid, _site, build

    #
    # process all pages
    #
    for $file in fs.readdirSync(_site.source)
      _generate_pages $file unless $file[0] is '_' #

    #
    # process all posts
    #
    for $file in fs.readdirSync("#{_site.source}/_posts")
      _generate_post $file


    #
    # process drafts
    #
    if '-d' in $args or '--drafts' in $args
      for $file in fs.readdirSync("#{_site.source}/_posts")
        _generate_post $file


  url: ($path) ->
    _post_url $path

  render: ($path, $extra) ->
    _render $path, $extra

# Generate pages
#
# @param  [String]  tpl template
# @param  [String]  folder  subfolder
# @return none
#
_generate_pages = ($tpl, $folder = '') ->

  $tmp = path.normalize("#{_site.source}/#{$folder}/#{$tpl}")
  $out = path.normalize("#{_site.destination}/#{$folder}/#{$tpl}")

  $stats = fs.statSync($tmp)

  if $stats.isDirectory()

    fs.mkdirSync $out unless fs.existsSync($out)
    for $file in fs.readdirSync($tmp)
      _generate_pages $file, "#{$folder}/#{$tpl}"

  else if $stats.isFile()
    console.log $out
    if path.extname($tmp) in TYPES
      fs.writeFileSync $out, _render($tmp)
    else
      $bin = fs.createWriteStream($out)
      $bin.write fs.readFileSync($tmp)
      $bin.end()


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
    if path.extname($src) in TYPES
      _site.pages.push _load_page($src)


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

  $tmp = path.normalize("#{_site.source}/_posts/#{$path}")
  $out = path.normalize("#{_site.destination}/#{$yy}/#{$mm}/#{$dd}/#{$slug}")

  console.log $out
  fs.writeFileSync $out, _render($tmp)

#
# Load post data
#
# @param  [String]  path  template path
# @return none
#
_load_post = ($path) ->
  $src = path.normalize("#{_site.source}/_posts/#{$path}")
  _site.posts.unshift _load_page($src)


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
  _parse_url($template).path

_parse_url = ($template) ->

  if $template.indexOf(_site.source) is 0
    $template = $template.substr(_site.source.length)
  if $template[0] is '/'
    $template = $template.substr(1)

  $path = path.dirname($template)
  $ext = path.extname($template)
  $name = path.basename($template, $ext)

  if $path is '_posts'

    $seg = $name.split('-')
    $yyyy = $seg.shift()
    $mm = $seg.shift()
    $dd = $seg.shift()
    $slug = $seg.join('-')
    return {
      post  : true
      path  : "/#{$yyyy}/#{$mm}/#{$dd}/#{$slug}#{$ext}"
      yyyy  : $yyyy
      mm    : $mm
      dd    : $dd
      slug  : $slug
      ext   : $ext
    }
  else
    if $path is '.'
      return {
        post  : false
        path  : "/#{$name}#{$ext}"
        slug  : $name
        ext   : $ext
      }
    else
      return {
        post  : false
        path  : "/#{$path}/#{$name}#{$ext}"
        slug  : $name
        ext   : $ext
      }

#
# Render a template, create output at path
#
# @param  [String]  template
# @param  [String]  extra page data
# @return none
#
_render = ($template, $extra) ->

  #
  # Make sure it's a template
  #
  if path.extname($template) in TYPES
    $page = _load_page($template, $extra)

    $buf = Liquid.Template
    .parse($page.content)
    .render(page: $page, site: _site, paginator: _paginator)

    if $page.layout?

      $layout = String(fs.readFileSync("#{_site.source}/_layouts/#{$page.layout}.html"))

      $buf = Liquid.Template
      .parse($layout)
      .render(content: $buf, page: $page, site: _site, paginator: _paginator)

  else fs.readFileSync($template)

#
# Load template data
#
# @param  [String]  template
# @param  [String]  page
# @return none
#
_load_page = ($template, $extra = {}) ->

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
    date: new Date
    excerpt: ''
    id: ''
    path: ''
    tag: ''
    tags: []
    title: ''
    url: _post_url($template)

  if ($url = _parse_url($template)).post
    $page.date = new Date($url.yyyy, $url.mm, $url.dd)

  for $key, $val of $fm
    $page[$key] = $val

  for $key, $val of $extra
    $page[$key] = $val

  $page


