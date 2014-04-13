#+--------------------------------------------------------------------+
#| LocalFileSystem.coffee
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
#
# valid template filetypes
#
fs = require('fs')
path = require('path')

module.exports = class LocalFileSystem

  constructor: (@root) ->

  readTemplateFile: ($template) ->
    String(fs.readFileSync(path.resolve(@root, $template)))
