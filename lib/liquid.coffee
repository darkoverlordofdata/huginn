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

_site = null
_lang = 'en'
#
# If we're in the browser, it's business as usual
#
if window?
  #
  # load 'file' from in-document
  #
  Liquid.readTemplateFile = ($file) ->
    document.getElementById($file).value


#
# Interface to node.js
#
else
  #
  # Create a mock document obect for strftime
  #
  Object.defineProperties global,
    document:
      get: ->
        getElementsByTagName: ($name) ->
          if $name is 'html' then [lang: _lang] else []

  #
  # Now we can safely load Liquid.js
  #
  eval String(fs.readFileSync(path.resolve(__dirname, './liquid.js')))
  #
  # Load template file from _includes
  #
  Liquid.readTemplateFile = ($file) ->
    $path = path.resolve(_site.source, '_includes', $file)
    String(fs.readFileSync($path))


Object.defineProperties module.exports,
  connect:
    value: ($site) ->
      _site = $site
      _lang = $site.lang ? _lang
      Liquid

  Liquid:
    get: ->
      Liquid
