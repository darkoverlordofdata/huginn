#+--------------------------------------------------------------------+
#| gist.coffee
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
# display a gist
#

_site = null

module.exports =

  tag: 'gist'     # {% post_url %}
  ends: false     # no end tag

  connect: ($site) ->
    _site = $site

  #
  # build the executable
  #
  compile: (compiler, args) ->
    ''
  #
  # build the tag
  #
  parse: (str, line, parser, types, stack, opts) ->
    true
