#+--------------------------------------------------------------------+
#| Site.coffee
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


module.exports = class Site

  constructor: ($dev = true) ->

    $cfg = if $dev then 'config-dev.yml' else 'config.yml'
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
      util:
        writable: false, value: new Util(@)
      source:
        writable: false, value: path.resolve($root, $config.source)
      destination:
        writable: false, value: path.resolve($root, $config.destination)

    for $key, $value of $config
      @[$key] = $value



class Util

  constructor: (@site) ->

  parseUrl: ($template) ->

    if $template.indexOf(@site.source) is 0
      $template = $template.substr(@site.source.length)
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

