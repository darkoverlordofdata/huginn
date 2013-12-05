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

_site = null

module.exports =

  tag: 'highlight'    # {% highlight "lang" %}
  ends: true          # {% endhighlight %}

  connect: ($site) ->
    _site = $site

  #
  # build the executable
  #
  compile: (compiler, args, content, parents, options, blockName) ->

    $lang = args.shift()[1..-2]
    $linenos = if args.length > 0 then true else false

    $content = ""
    if $linenos
      $content += "_output += \"<pre class='prettyprint lang-#{$lang} linenums:1'>\";"
    else
      $content += "_output += \"<pre class='prettyprint lang-#{$lang}'>\";"

    $content += compiler(content, parents, options, blockName)
    $content += "_output += \"</pre>\";"
    return $content


  #
  # build the tag
  #
  parse: (str, line, parser, types, stack, opts) ->
    $lang = undefined
    $linenos = undefined

    parser.on types.STRING, (token) ->
      unless $lang
        $lang = token.match
        @out.push $lang
        return
      true

    parser.on types.VAR, (token) ->
      unless $linenos
        if token.match is "linenos"
          @out.push true
          return
      true

    true

