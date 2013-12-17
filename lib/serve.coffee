#+--------------------------------------------------------------------+
#| serve.coffee
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
fs = require('fs')
path = require('path')
yaml = require('yaml-js')
express = require('express')
Configuration = require('./classes/Configuration')


module.exports =
#
# serve the generated dite locally
#
# @param  [Array<String>]  command line args
# @return none
#
  run: ($args) ->

    $config = new Configuration('--dev' in $args)
    $404 = path.resolve($config.destination, '404.html')

    $app = express()
    $app.set 'port', $config.port
    $app.use express.favicon()
    $app.use express.logger('dev')
    $app.use express.bodyParser()
    $app.use express.methodOverride()

    $root = process.cwd()
    if $config.serve?
      if 'string' is typeof $config.serve
        $app.use express.static(path.resolve($root, $config.serve))
      else
        for $path in $config.serve
          console.log path.resolve($root, $path)
          $app.use express.static(path.resolve($root, $path))
    else
      $app.use express.static(path.resolve($root, $config.destination))

    $app.use $app.router
    $app.use ($err, $req, $res, $next) ->
      $res.send 500, $err.stack
    $app.use ($req, $res, $next) ->
      $res.sendfile $404

    $app.listen $config.port, ->
      console.log "Express server listening on port #{$config.port}"
      console.log "http://localhost:#{$config.port}"


