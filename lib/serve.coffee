#+--------------------------------------------------------------------+
#| create.coffee
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
yaml = require('yaml-js')
express = require('express')


module.exports =
#
# create a new project
#
# @param  [String]  cfg alternate config file name
# @return none
#
  run: ($args) ->

    $cfg = 'config.yml'
    $root = process.cwd()
    if fs.existsSync("#{$root}/#{$cfg}")
      $config = yaml.load(fs.readFileSync("#{$root}/#{$cfg}"))
    else
      process.exit console.log("ERR: Hugin config file #{$cfg} not found")

    if not fs.existsSync($config.destination)
      process.exit console.log("ERR: #{$config.destination} not built")

    $404 = path.resolve($config.destination, '404.html')
    $app = express()
    $app.set 'port', ($port = 0xd16a)
    $app.use express.favicon()
    $app.use express.logger('dev')
    $app.use express.bodyParser()
    $app.use express.methodOverride()
    $app.use express.static($config.destination)
    $app.use $app.router
    $app.use ($err, $req, $res, $next) ->
      $res.send 500, $err.stack
    $app.use ($req, $res, $next) ->
      $res.sendfile $404
    $app.listen $port, ->
      console.log "Express server listening on port #{$port}"
      console.log "http://localhost:#{$port}"


