#+--------------------------------------------------------------------+
#| build.coffee
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
Liquid = require('huginn-liquid')
Site = require('./classes/Site')
LocalFileSystem = require('./classes/LocalFileSystem')

module.exports =
#
# Generate a site
#
# @param  [Array<String>]  command line args
# @return none
#
  run: ($args = []) ->

    $site = new Site('--dev' in $args)
    $plugins = []

    #
    #   Initialize Liquid
    #
    Liquid.Template.fileSystem = new LocalFileSystem("#{$site.source}/_includes")
    Liquid.Template.registerFilter require("#{__dirname}/filters.coffee")

    #
    #   Tags
    #
    for $name in fs.readdirSync("#{__dirname}/tags")
      $tag = require("#{__dirname}/tags/#{$name}")
      $tag $site


    #
    # System plugins
    #
    if $site.plugins?
      for $name in $site.plugins
        $plugins.push require($name)

    #
    # User plugins
    #
    if fs.existsSync("#{$site.source}/_plugins")
      for $name in fs.readdirSync("#{$site.source}/_plugins")
        $plugin = require("#{$site.source}/_plugins/#{$name}")
        $plugins.push $plugin

    #
    # load everything
    #
    $site.loadData()
    $site.loadPosts('-d' in $args or '--drafts' in $args)
    $site.loadPages()

    #
    # generate output
    #
    fs.mkdirSync $site.destination unless fs.existsSync($site.destination)
    if fs.existsSync("#{$site.source}/assets")
      fs.mkdirSync "#{$site.destination}/assets" unless fs.existsSync("#{$site.destination}/assets")
    for $plugin in $plugins
      $plugin $site
    $site.generatePages()
    $site.generatePosts('-d' in $args or '--drafts' in $args)


