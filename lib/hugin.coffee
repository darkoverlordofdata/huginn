#+--------------------------------------------------------------------+
#| hugin.coffee
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
# hugin command dispatch
#

Object.defineProperties module.exports,

  build:  # generate the site
    get: ->
      require('./build.coffee').run

  create: # create a new project
    get: ->
      require('./create.coffee').run

  serve:  # serve the site
    get: ->
      require('./serve.coffee').run
