#+--------------------------------------------------------------------+
#| tag_cloud.coffee
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
# tag cloud hugin-plugin
#
_generated = false

module.exports =

  name: 'tag_cloud'   # {{ site | tag_cloud }}

  generate: ->
    return if _generated
    _generated = true

  filter: ($site) ->

    return 'tag cloud'