#+--------------------------------------------------------------------+
#| gist.coffee
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
# Embed a link to a post specified by the source filename
#
Liquid = require('huginn-liquid')

module.exports = ($site) ->

  class Gist extends Liquid.Tag

    id: ''
    file: ''

    constructor: ($name, $markup, $tokens) ->
      super $name, $markup, $tokens
      [@id, @file] = $markup.split(' ', 2)

    render: ($ctx) ->
      super $ctx
      if @file.length
        "<script src=\"https://gist.github.com/#{@id}.js?#{@file}\"></script>"
      else
        "<script src=\"https://gist.github.com/#{@id}.js\"></script>"

  Liquid.Template.registerTag "gist", Gist

