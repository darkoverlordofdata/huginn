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
# @see https://github.com/darthapo/liquid.js
#
# Copy your Liquid.js distro file to the same folder
#
#
fs = require('fs')
path = require('path')

#
# Initialize Liquid
#
# Satisfies dependancies, loads liquid.js
#
# @paran  [String]  liquidjs  path to Liquid.js dist
# @paran  [String]  source    file system root
# @param  [String]  lang      iso 639-1 language code
# @returns [Object] the Liquid.js module reference
#
#
module.exports = ($liquidjs, $source, $lang='en') ->

  #
  # Fabricate a document object for strftime
  #
  document =
    getElementsByTagName: ($name) ->
      if $name is 'html' then [lang: $lang] else []

  #
  # Now we can safely load Liquid.js
  #
  eval String(fs.readFileSync($liquidjs))

  #
  # Load template files from folder
  #
  Liquid.readTemplateFile = ($file) ->
    $path = path.resolve($source, $file)
    String(fs.readFileSync($path))

  Liquid

