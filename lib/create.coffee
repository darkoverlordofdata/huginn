#+--------------------------------------------------------------------+
#| create.coffee
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
# Create a new app folder:
#
#   huginn create <appname>
#
#
fs = require('fs')
path = require('path')
yaml = require('yaml-js')
templates = require('./templates')

PORT  = 0xd16a        # default port for huginn serve
SRC   = './source'    # templates and resources root
DST   = './master'    # output location root

module.exports =
#
# create a new project scaffold in cwd
#
# @param  [String]  appname app to create
# @return none
#
  run: ($appname) ->

    $path = path.resolve(process.cwd(), $appname)
    

    $config = """
      name: "#{$appname}"
      description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

      source: #{SRC}
      destination: #{DST}

      port: #{PORT}
      url: http://#{$appname}.com

      markdown:
        - '.md'
        - '.markdown'

      template:
        - '.html'
        - '.xml'
        - '.md'
        - '.markdown'

    """
    console.log "Creating #{$appname}..."

    if fs.existsSync($path)
      process.exit console.log("ERR: the folder #{$path} already exists.")

    for $dir in [
      "#{$path}"
      "#{$path}/#{SRC}"
      "#{$path}/#{SRC}/_assets"
      "#{$path}/#{SRC}/_data"
      "#{$path}/#{SRC}/_drafts"
      "#{$path}/#{SRC}/_includes"
      "#{$path}/#{SRC}/_layouts"
      "#{$path}/#{SRC}/_plugins"
      "#{$path}/#{SRC}/_posts"
    ]
      fs.mkdirSync $dir
    
    for $file in [
      {path: "#{$path}/config.yml",                     content: $config}
      {path: "#{$path}/#{SRC}/CNAME",                   content: "#{$appname}.com"}
      {path: "#{$path}/#{SRC}/404.html",                content: '404'}
      {path: "#{$path}/#{SRC}/index.html",              content: 'index'}
      {path: "#{$path}/#{SRC}/_layouts/default.html",   content: 'layouts_default'}
      {path: "#{$path}/#{SRC}/_layouts/post.html",      content: 'layouts_post'}
      {path: "#{$path}/#{SRC}/_includes/header.html",   content: 'includes_header'}
      {path: "#{$path}/#{SRC}/_includes/footer.html",   content: 'includes_footer'}
      {path: "#{$path}/#{SRC}/_posts/2013-01-01-hello.html", content: 'posts_hello'}
    ]

      if templates[$file.content]?
        fs.writeFileSync $file.path, templates[$file.content]()
      else
        fs.writeFileSync $file.path, $file.content
