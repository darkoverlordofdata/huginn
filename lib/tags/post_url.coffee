#+--------------------------------------------------------------------+
#| post_url.coffee
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
# Ex:
#
#   <a href="{% post_url 2013-01-01-hello-world %}">Hello!</a>
#
#   [Hello!]({% post_url 2013-01-01-hello-world %})
#

module.exports = (Liquid, site, build) ->

  class PostUrl extends Liquid.Tag

    url: ''

    constructor: ($name, $markup, $tokens) ->
      super
      @url = $markup.split(' ')[0]

    render: ($ctx) ->
      super
      build.url(@url)

  Liquid.Template.registerTag "post_url", PostUrl