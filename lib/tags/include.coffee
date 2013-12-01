#+--------------------------------------------------------------------+
#| include.coffee
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
# The standard include tag, but it looks in the _include folder
#

path = require('path')
util = require('./../util.coffee')
_config = util.config()
_dir = path.resolve(__dirname, '../..', _config.source, '_includes')+'/'

ignore = "ignore"
missing = "missing"
only = "only"

module.exports =

  ends: false # no end tag

  compile: (compiler, args) ->
    file = args.shift().replace('"', "\"#{_dir}")
    onlyIdx = args.indexOf(only)
    onlyCtx = (if onlyIdx isnt -1 then args.splice(onlyIdx, 1) else false)
    parentFile = args.pop().replace(/\\/g, "\\\\")
    ignore = (if args[args.length - 1] is missing then (args.pop()) else false)
    w = args.join("")
    ((if ignore then "  try {\n" else "")) + "_output += _swig.compileFile(" + file + ", {" + "resolveFrom: \"" + parentFile + "\"" + "})(" + ((if (onlyCtx and w) then w else ((if not w then "_ctx" else "_utils.extend({}, _ctx, " + w + ")")))) + ");\n" + ((if ignore then "} catch (e) {}\n" else ""))

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
