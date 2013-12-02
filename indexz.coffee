#+--------------------------------------------------------------------+
#| index.coffee
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
fs = require('fs')
path = require('path')
hugin = require('./lib/hugin')

_src  = ''  # source folder
_dst  = ''  # destination folder

_drafts   = []
_includes = []
_layouts  = []
_plugins  = []
_posts    = []

_mkdir = ($dir) ->
  fs.mkdirSync $dir unless fs.existsSync($dir)

#
# Generate items from template
#
# @param  [String]  tpl template
# @param  [String]  folder  subfolder
# @return none
#
_generate = ($tpl, $folder = '') ->

  $src = path.normalize("#{_src}/#{$folder}/#{$tpl}")
  $dst = path.normalize("#{_dst}/#{$folder}/#{$tpl}")

  $stats = fs.statSync($src)

  if $stats.isDirectory()

    _mkdir $dst
    for $f in fs.readdirSync($src)
      _generate $f, "#{$folder}/#{$tpl}"

  else if $stats.isFile()

    hugin.generate $src, $dst


_post = ($tpl) ->
  $seg = $tpl.split('-')
  $yy = $seg.shift()
  $mm = $seg.shift()
  $dd = $seg.shift()
  $link = $seg.join('-')

  _mkdir "#{_src}/#{$yy}"
  _mkdir "#{_src}/#{$yy}/#{$mm}"
  _mkdir "#{_src}/#{$yy}/#{$mm}/#{$dd}"

  $src = path.normalize("#{_src}/_posts/#{$tpl}")
  $dst = path.normalize("#{_src}/#{$yy}/#{$mm}/#{$dd}/#{$link}")

  #hugin.generate $src, $dst






if ($config = hugin.config()) is null
  process.exit console.log("No config file found")


if not fs.existsSync($config.source)
  process.exit console.log("No source dir")


_src = $config.source
_dst = $config.destination

fs.mkdirSync _dst unless fs.existsSync(_dst)

#
# process all posts
#
for $f in fs.readdirSync("#{_src}/_posts")
  _post $f

#
# process all public items
#
for $f in fs.readdirSync(_src)
  _generate $f unless $f[0] is '_'