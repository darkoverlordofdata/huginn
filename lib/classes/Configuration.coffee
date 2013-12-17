#+--------------------------------------------------------------------+
#| Configuration.coffee
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
#
# valid template filetypes
#
fs = require('fs')
path = require('path')

module.exports = class Configuration

  constructor: ($dev = true) ->

    $cfg = if $dev then 'config-dev.yml' else 'config.yml'
    $root = process.cwd()
    if fs.existsSync("#{$root}/#{$cfg}")
      $config = yaml.load(fs.readFileSync("#{$root}/#{$cfg}"))
    else
      throw "ERR: Huginn config file #{$cfg} not found"

    if not fs.existsSync($config.source)
      throw "ERR: Huginn source directory #{$config.source} not found"


    for $key, $value of $config
      @[$key] = $value