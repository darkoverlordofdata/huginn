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
yaml = require('yaml-js')
_site   = null
_js     = ''
_css    = ''
_cdn    = ''
_url    = ''
_dev    = false
_bundler = /\"([^\"]*)\"/



module.exports =

  tag: 'bundle'   # {% bundle %}
  ends: true      # {% endbundle %}

  #
  # Connect to the site
  # grab some configuration values
  #
  connect: ($site) ->

    _site = $site
    _js   = _site.asset_bundler.markup_templates.js
    _css  = _site.asset_bundler.markup_templates.css
    _cdn  = _site.asset_bundler.server_url
    _url  = _site.asset_bundler.base_path
    _dev  = _site.asset_bundler.dev

  #
  # build the tag content
  #
  compile: (compiler, args, content, parents, options, blockName) ->

    $assets = compiler(content, parents, options, blockName)

    if ($match = $assets.match(_bundler))?

      if _dev # Just create tags for each asset file

        $bundle = yaml.load($match[1].replace(/\\n/g, "\n"))
        $s = ''
        for $asset in $bundle
          if /.js$/.test $asset
            $url = $asset.replace(/^\/_assets\//, _url)
            $s+= _js.replace("{{url}}", $url)

          else if /.css$/.test $asset
            $url = $asset.replace(/^\/_assets\//, _url)
            $s+=_css.replace("{{url}}", $url)

        $assets = $assets.replace(_bundler, "\"#{$s.replace(/\n/g, "\\n")}\"")

      else ## TODO - bundle into 1 file, optionaly compressed

    return $assets

  #
  # build the tag
  #
  parse: (str, line, parser, types, stack, opts) ->
    return true;
