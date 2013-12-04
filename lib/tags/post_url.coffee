#+--------------------------------------------------------------------+
#| post_url.coffee
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
# Embed a link to a post specified by the source filename
#

path = require('path')
build = require('./../build.coffee')
_dir = ''

ignore = "ignore"
missing = "missing"
only = "only"

module.exports =

  tag: 'post_url'   # {% post_url %}
  ends: false       # no end tag

  #
  # build the executable
  #
  compile: (compiler, args) ->
    file = build.url(args.shift())
    "_output +=<a href=\"#{file}\">#{file}</a>"
  #
  # build the tag
  #
  parse: (str, line, parser, types, stack, opts) ->
    file = undefined
    w = undefined

    parser.on types.STRING, (token) ->
      unless file
        file = token.match
        @out.push file
        return
      true

    parser.on types.VAR, (token) ->
      unless file
        file = token.match
        return true
      if not w and token.match is "with"
        w = true
        return
      if w and token.match is only and @prevToken.match isnt "with"
        @out.push token.match
        return
      return false  if token.match is ignore
      if token.match is missing
        throw new Error("Unexpected token \"" + missing + "\" on line " + line + ".")  if @prevToken.match isnt ignore
        @out.push token.match
        return false
      throw new Error("Expected \"" + missing + "\" on line " + line + " but found \"" + token.match + "\".")  if @prevToken.match is ignore
      true

    parser.on "end", ->
      @out.push opts.filename or null

    true
