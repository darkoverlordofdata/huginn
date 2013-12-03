#+--------------------------------------------------------------------+
#| highlight.coffee
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
# highlight code listing
#

_site = null

module.exports =

  tag: 'highlight'    # {% highlight %}
  ends: true          # {% endhighlight %}

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
