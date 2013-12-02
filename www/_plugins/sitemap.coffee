#+--------------------------------------------------------------------+
#| sitemap.coffee
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
# sitemap hugin-plugin
#
_site = null
_generated = false

module.exports =

  name: 'sitemap'   # {{ site | tag_cloud }}

  #
  # Connect to the site
  # grab some configuration values
  #
  connect: ($site) ->

    _site = $site

  generate: ->
    return if _generated
    _generated = true
