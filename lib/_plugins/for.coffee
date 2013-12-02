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
# The standard for tag, plus liquid extensions:
#
#   limit: n
#

module.exports =

  tag: 'for'      # {% for %}
  ends: true      # {% endfor %}

  #
  # build the executable
  #
  compile: (compiler, args, content, parents, options, blockName) ->

    limit = args.pop()
    if isNaN(limit)
      args.push limit
      limit = undefined

    val = args.shift()
    key = "__k"
    last = undefined
    if args[0] and args[0] is ","
      args.shift()
      key = val
      val = args.shift()

    last = args.join("")

    if limit?
       """
        (function () {
          var __l = #{last};
          if (!__l) { return; }
          var loop = { first: false, index: 1, index0: 0, revindex: __l.length, revindex0: __l.length - 1, length: __l.length, last: false };
          _utils.each(__l, function (#{val}, #{key}) {
            if (loop.index0 > #{limit}) return;
            loop.key = #{key};
            loop.first = (loop.index0 === 0);
            loop.last = (loop.revindex0 === 0);
            #{compiler(content, parents, options, blockName)}
            loop.index += 1; loop.index0 += 1; loop.revindex -= 1; loop.revindex0 -= 1;
          });
        })();
      """
    else
      """
        (function () {
          var __l = #{last};
          if (!__l) { return; }
          var loop = { first: false, index: 1, index0: 0, revindex: __l.length, revindex0: __l.length - 1, length: __l.length, last: false };
          _utils.each(__l, function (#{val}, #{key}) {
            loop.key = #{key};
            loop.first = (loop.index0 === 0);
            loop.last = (loop.revindex0 === 0);
            #{compiler(content, parents, options, blockName)}
            loop.index += 1; loop.index0 += 1; loop.revindex -= 1; loop.revindex0 -= 1;
          });
        })();
      """


  #
  # build the tag
  #
  parse: (str, line, parser, types) ->
    firstVar = undefined
    ready = undefined

    parser.on types.NUMBER, (token) ->
      @out.push token.match
      return
      lastState = (if @state.length then @state[@state.length - 1] else null)
      throw new Error("Unexpected number \"" + token.match + "\" on line " + line + ".")  if not ready or (lastState isnt types.ARRAYOPEN and lastState isnt types.CURLYOPEN and lastState isnt types.CURLYCLOSE and lastState isnt types.FUNCTION and lastState isnt types.FILTER)
      true

    parser.on types.VAR, (token) ->
      if not (ready and firstVar)
        firstVar = true  unless @out.length
        @out.push token.match
      else if token.match is 'limit'
        return
      else
        return true

#      return true  if ready and firstVar
#      firstVar = true  unless @out.length
#      @out.push token.match

    parser.on types.COMMA, (token) ->
      if firstVar and @prevToken.type is types.VAR
        @out.push token.match
        return
      true

    parser.on types.COLON, (token) ->
      return

    parser.on types.COMPARATOR, (token) ->
      throw new Error("Unexpected token \"" + token.match + "\" on line " + line + ".")  if token.match isnt "in" or not firstVar
      ready = true

    true

