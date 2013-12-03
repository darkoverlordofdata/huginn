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
swig = require('swig')

_config = null
_plugins = []
_paginator = {}
_page = {}
_site = {}

module.exports =
#
# create a new project
#
# @param  [String]  cfg alternate config file name
# @return none
#
  run: ($args) ->

