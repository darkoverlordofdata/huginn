#+--------------------------------------------------------------------+
#| asset_bundler.coffee
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
# asset bundler hugin-plugin
#
module.exports =

  tag: 'bundle'   # {% bundle %}
  ends: true      # {% endbundle %}

  #
  # build the executable
  #
  compile: (compiler, args, content, parents, options, blockName) ->
    $assets = compiler(content, parents, options, blockName)

    # POC - change this to extract a block of lines and use yaml to parse
    #
    $assets.replace /(-\s+\/_assets\/[A-Za-z0-9.\-\/]+)/g, ($0, $1) ->
      $url = $1.replace(/-\s+\/_assets\//, "//cdn.darkoverlordofdata.com/")
      "<link rel='stylesheet' type='text/css' href='#{$url}' />"


  #
  # build the tag
  #
  parse: (str, line, parser, types, stack, opts) ->
    return true;
