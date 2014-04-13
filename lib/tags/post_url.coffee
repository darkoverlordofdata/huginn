#+--------------------------------------------------------------------+
#| post_url.coffee
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
# Embed a link to a post specified by the source filename
#
# Ex:
#
#   <a href="{% post_url 2013-01-01-hello-world %}">Hello!</a>
#
#   [Hello!]({% post_url 2013-01-01-hello-world %})
#
Liquid = require('huginn-liquid')

module.exports = ($site) ->

  class PostUrl extends Liquid.Tag

    url: ''

    constructor: ($name, $markup, $tokens) ->
      super $name, $markup, $tokens
      @url = $markup.split(' ')[0]

    render: ($ctx) ->
      super $ctx
      $site.url(@url)

  Liquid.Template.registerTag "post_url", PostUrl