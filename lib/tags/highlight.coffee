#+--------------------------------------------------------------------+
#| highlight.coffee
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
# highlight code listing
#
highlight = require("highlight.js").highlight

module.exports = (Liquid) ->

  class Highlight extends Liquid.Block

    code: ''
    lang: ''

    constructor: ($name, $markup, $tokens) ->
      @lang = $markup.split(' ')[0]
      super

    render: ($ctx) ->

      @code = highlight(@lang, super[0]).value
      "<pre><code class=\"#{@lang}\">#{@code}</code></pre>"



  Liquid.Template.registerTag "highlight", Highlight
