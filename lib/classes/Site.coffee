#+--------------------------------------------------------------------+
#| Site.coffee
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

fs = require('fs')
path = require('path')
yaml = require('yaml-js')
Page = require('./Page')
Configuration = require('./Configuration')
Liquid = require('huginn-liquid')

module.exports = class Site

  constructor: ($dev = true) ->

    $config = new Configuration($dev)
    #
    # Inialize the site object from configuration
    #
    Object.defineProperties @,
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
      config:
        writable: false, value: $config
      source:
        writable: false, value: path.resolve(process.cwd(), $config.source)
      destination:
        writable: false, value: path.resolve(process.cwd(), $config.destination)

    for $key, $value of $config
      @[$key] = $value unless 'function' is typeof @[$key]

    @markdown = do($marked = @marked) ->

      if $marked?
        marked = require('marked')
        ($md) ->
          marked($md, $marked)

      else
        markdown = require('markdown').markdown
        ($md) ->
          markdown.toHTML($md)



  #
  # Load data file
  #
  # @param  [String]  path  data file path
  # @return none
  #
  loadDataFile: ($path) ->
    $path = path.normalize("#{@source}/_data/#{$path}")
    $ext = path.extname($path)
    $name = path.basename($path, $ext)
    switch $ext
      when '.yml'     then @data[$name] = yaml.load(fs.readFileSync($path))
      when '.json'    then @data[$name] = require($path)
      when '.js'      then @data[$name] = require($path)
      when '.coffee'  then @data[$name] = require($path)
      else console.log "WARN: Unknown data format: #{$path}"

  #
  # Load data
  #
  # @return none
  #
  loadData: () ->
    if fs.existsSync("#{@source}/_data")
      for $file in fs.readdirSync("#{@source}/_data")
        @loadDataFile $file

  #
  # Load post data
  #
  # @param  [String]  path  template path
  # @return none
  #
  loadPost: ($path) ->
    $src = path.normalize("#{@source}/_posts/#{$path}")
    @posts.unshift new Page(@, $src)

  #
  # Load posts
  #
  # @param  [Boolean]  drafts include drafts?
  # @return none
  #
  loadPosts: ($drafts = false) ->
    if fs.existsSync("#{@source}/_posts")
      for $file in fs.readdirSync("#{@source}/_posts")
        @loadPost $file

    if $drafts
      if fs.existsSync("#{@source}/_drafts")
        for $file in fs.readdirSync("#{@source}/_drafts")
          @loadPost $file

  #
  # Load page data
  #
  # @param  [String]  path  template path
  # @param  [String]  folder  subfolder
  # @return none
  #
  loadPage: ($path, $folder = '') ->

    $src = path.normalize("#{@source}/#{$folder}/#{$path}")
    $stats = fs.statSync($src)

    if $stats.isDirectory()
      for $f in fs.readdirSync($src)
        @loadPage $f, "#{$folder}/#{$path}"

    else if $stats.isFile()
      if path.extname($src) in @template
        @pages.push new Page(@, $src)

  #
  # Load pages
  #
  # @return none
  #
  loadPages: () ->
    for $file in fs.readdirSync(@source)
      @loadPage $file unless $file[0] is '_'


  #
  #
  # Render a template, create output at path
  #
  # @param  [String]  template
  # @param  [String]  extra page data
  # @return none
  #
  render: ($template, $extra) ->

    #
    # Make sure it's a template
    #
    if ($ext = path.extname($template)) in @template
      $page = new Page(@, $template, $extra)
      $page.content = @markdown($page.content) if $ext in ['.md', '.markdown']

      $buf = Liquid.Template
      .parse($page.content)
      .render(page: $page, site: @, paginator: null)

      if $page.layout?

        $layout = String(fs.readFileSync("#{@source}/_layouts/#{$page.layout}.html"))

        $buf = Liquid.Template
        .parse($layout)
        .render(content: $buf, page: $page, site: @, paginator: null)

      else $buf
    else
      if /.js$/.test $template
        String(fs.readFileSync($template))
      else
        fs.readFileSync($template)

  #
  # Generate page
  #
  # @param  [String]  tpl template
  # @param  [String]  folder  subfolder
  # @return none
  #
  generatePage: ($tpl, $folder = '') ->
  
    $tmp = path.normalize("#{@source}/#{$folder}/#{$tpl}")
    $out = path.normalize("#{@destination}/#{$folder}/#{$tpl}")
  
    $stats = fs.statSync($tmp)
  
    if $stats.isDirectory()
  
      fs.mkdirSync $out unless fs.existsSync($out)
      for $file in fs.readdirSync($tmp)
        @generatePage $file, "#{$folder}/#{$tpl}"
  
    else if $stats.isFile()
      $out = $out
      .replace(/\.md$/, '.html')
      .replace(/\.markdown$/, '.html')
      console.log $out
      if path.extname($tmp) in @template
        fs.writeFileSync $out, @render($tmp)
      else
        $bin = fs.createWriteStream($out)
        $bin.write fs.readFileSync($tmp)
        $bin.end()


  #
  # Generate pages
  #
  # @return none
  #
  generatePages: () ->
    for $file in fs.readdirSync(@source)
      @generatePage $file unless $file[0] is '_' #


  #
  # Generate a post from template
  #
  # @param  [String]  path  template path
  # @return none
  #
  generatePost: ($path) ->
    $seg = $path.split('-')
    $yy = $seg.shift()
    $mm = $seg.shift()
    $dd = $seg.shift()
    $slug = $seg.join('-')
  
    fs.mkdirSync "#{@destination}/#{$yy}" unless fs.existsSync("#{@destination}/#{$yy}")
    fs.mkdirSync "#{@destination}/#{$yy}/#{$mm}" unless fs.existsSync("#{@destination}/#{$yy}/#{$mm}")
    fs.mkdirSync "#{@destination}/#{$yy}/#{$mm}/#{$dd}" unless fs.existsSync("#{@destination}/#{$yy}/#{$mm}/#{$dd}")
  
    $tmp = path.normalize("#{@source}/_posts/#{$path}")
    $out = path.normalize("#{@destination}/#{$yy}/#{$mm}/#{$dd}/#{$slug}")
  
    console.log $out
    fs.writeFileSync $out, @render($tmp)

  #
  # Generate posts from template
  #
  # @param  [Boolean]  drafts include drafts?
  # @return none
  #
  generatePosts: ($drafts = false) ->
    for $file in fs.readdirSync("#{@source}/_posts")
      @generatePost $file
    if $drafts
      for $file in fs.readdirSync("#{@source}/_posts")
        @generatePost $file


  #
  # Parse url
  #
  # @param  [String]  template path to parse
  # @return none
  #
  parseUrl: ($template) ->

    if $template.indexOf(@source) is 0
      $template = $template.substr(@source.length)
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

