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

module.exports =

  tag: 'highlight'    # {% highlight "lang" %}
  ends: true          # {% endhighlight %}

  #
  # Build the executable javascript
  #
  compile: ($compiler, $args, $content, $parents, $options, $blockName) ->

    $lang = $args.shift()[1..-2]
    $linenos = if $args.length > 0 then ' linenums:1' else ''

    """
      _output += \"<pre class='prettyprint lang-#{$lang}#{$linenos}'>\";
      #{$compiler($content, $parents, $options, $blockName)}
      _output += \"</pre>\";
    """


  #
  # Parse:
  #
  # {% highlight lang [linenos] %}
  # ...
  # {% endhighlight %}
  #
  parse: ($str, $line, $parser, $types, $stack, $opts) ->
    $lang = undefined
    $linenos = undefined

    #
    # lang
    #
    $parser.on $types.STRING, ($token) ->
      unless $lang
        $lang = $token.match
        @out.push $lang
        return
      true

    #
    # line numbers?
    #
    $parser.on $types.VAR, ($token) ->
      unless $linenos
        if $token.match is "linenos"
          @out.push true
          return
      true

    true

