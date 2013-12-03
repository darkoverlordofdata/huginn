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
# Create a new app folder:
#
#   hugin create <appname>
#
#
fs = require('fs')
path = require('path')
yaml = require('yaml-js')
templates = require('./templates')

module.exports =
#
# create a new project in cwd
#
# @param  [String]  appname app to create
# @return none
#
  run: ($appname) ->

    $cwd = process.cwd()
    $path = path.resolve($cwd, $appname)

    $config = """
      name: "#{$appname}"
      description: "On, Hekyll! On, Jekyll! On Hugin and Munin!"

      source: ./www
      destination: ./public

      port: 53610
      url: http://#{$appname}.com
    """
    console.log "Creating #{$appname}..."

    if fs.existsSync($path)
      process.exit console.log("ERR: the folder #{$path} already exists.")

    for $dir in [
      $path
      "#{$path}/www"
      "#{$path}/www/_assets"
      "#{$path}/www/_data"
      "#{$path}/www/_drafts"
      "#{$path}/www/_includes"
      "#{$path}/www/_layouts"
      "#{$path}/www/_plugins"
      "#{$path}/www/_posts"
    ]
      fs.mkdirSync $dir
    
    for $file in [
      {path: "#{$path}/config.yml",                 content: $config}
      {path: "#{$path}/www/CNAME",                  content: "#{$appname}.com"}
      {path: "#{$path}/www/404.html",               content: '404'}
      {path: "#{$path}/www/index.html",             content: 'index'}
      {path: "#{$path}/www/_layouts/default.html",  content: 'layouts_default'}
      {path: "#{$path}/www/_layouts/post.html",     content: 'layouts_post'}
      {path: "#{$path}/www/_includes/header.html",  content: 'includes_header'}
      {path: "#{$path}/www/_includes/footer.html",  content: 'includes_footer'}
      {path: "#{$path}/www/_posts/2013-01-01-hello.html", content: 'posts_hello'}
    ]

      if templates[$file.content]?
        fs.writeFileSync $file.path, templates[$file.content]()
      else
        fs.writeFileSync $file.path, $file.content
