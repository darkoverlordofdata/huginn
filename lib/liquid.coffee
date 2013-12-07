#+--------------------------------------------------------------------+
#| liquid.coffee
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
# Liquid.js wrapper
#
fs = require('fs')
path = require('path')

module.exports = ($site) ->

  #
  # Create a mock document object for strftime
  #
  Object.defineProperties @,
    document:
      get: ->
        getElementsByTagName: ($name) ->
          if $name is 'html' then [lang: $site.lang ? 'en'] else []

  #
  # Now we can safely load Liquid.js
  #
  eval String(fs.readFileSync(path.resolve(__dirname, './liquid.js')))

  #
  # Load template files from _includes\ folder
  #
  Liquid.readTemplateFile = ($file) ->
    $path = path.resolve($site.source, '_includes', $file)
    String(fs.readFileSync($path))

  Liquid

