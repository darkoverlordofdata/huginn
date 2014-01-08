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

module.exports =
#
# create a new project scaffold in cwd
#
# @param  [String]  appname app to create
# @return none
#
  run: ($project, $args...) ->

    $path = path.resolve(process.cwd(), $project)
    if fs.existsSync($path)
      process.exit console.log("ERR: the folder #{$path} already exists.")

    $dest = 'www'
    while ($option = $args.shift())?

      switch $option

        when '-b', '--branch'
          $use_branch = true
          $branch = $args.shift()

        when '-d', '--dest'
          $has_dest = true
          $dest = $args.shift()

        else
          throw "ERR: Invalid option #{$option}"

    console.log "Creating #{$project}..."

    $readme = """
      # "#{$project}"
    """

    if $has_dest
      $dest ?= switch $branch
        when "master" then "gh-pages"
        when "source" then "master"
        else "www"

    if $use_branch

      fs.mkdirSync $path
      $path += '/'+$branch

      $config = """
        name: "#{$project}"
        description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

        source: ./template
        destination: ./#{$dest}

        port: 0xd16a
        url: http://#{$project}.com

        plugins:
          - huginn-asset-bundler

        asset_bundler:
          compress:
            js: true
            css: true
          base_path: /assets/
          shim: /#{$project}
          dev: false
          markup_templates:
            js: "<script type='text/javascript' src='{{url}}'></script>\n"
            css: "<link rel='stylesheet' type='text/css' href='{{url}}' />\n"

      """

      $config_dev = """
        name: "#{$project}"
        description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

        source: ./template
        destination: ./#{$dest}/#{$project}

        port: 0xd16a
        url: http://#{$project}.com

        serve:
          - ./#{$dest}
          - ../../user_org.github.io/master

        plugins:
          - huginn-asset-bundler

        asset_bundler:
          compress:
            js: false
            css: false
          base_path: /assets/
          shim: /#{$project}
          dev: true
          markup_templates:
            js: "<script type='text/javascript' src='{{url}}'></script>\n"
            css: "<link rel='stylesheet' type='text/css' href='{{url}}' />\n"

      """

    else

      $config = """
        name: "#{$project}"
        description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

        source: ./template
        destination: ./#{$dest}

        port: 0xd16a
        url: http://#{$project}.com

        serve:
          - ./#{$dest}

        plugins:
          - huginn-asset-bundler

        asset_bundler:
          compress:
            js: true
            css: true
          base_path: /assets/
          shim: /#{$project}
          dev: false
          markup_templates:
            js: "<script type='text/javascript' src='{{url}}'></script>\n"
            css: "<link rel='stylesheet' type='text/css' href='{{url}}' />\n"

      """

      $config_dev = """
        name: "#{$project}"
        description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

        source: ./template
        destination: ./#{$dest}

        port: 0xd16a
        url: http://#{$project}.com

        serve:
          - ./#{$dest}

        plugins:
          - huginn-asset-bundler

        asset_bundler:
          compress:
            js: false
            css: false
          base_path: /assets/
          shim: /#{$project}
          dev: true
          markup_templates:
            js: "<script type='text/javascript' src='{{url}}'></script>\n"
            css: "<link rel='stylesheet' type='text/css' href='{{url}}' />\n"

      """

    for $dir in [
      "#{$path}"
      "#{$path}/template"
      "#{$path}/template/_assets"
      "#{$path}/template/_data"
      "#{$path}/template/_drafts"
      "#{$path}/template/_includes"
      "#{$path}/template/_layouts"
      "#{$path}/template/_plugins"
      "#{$path}/template/_posts"
    ]
      fs.mkdirSync $dir
    
    for $file in [
      {path: "#{$path}/.gitignore",                       content: '.gitignore'}
      {path: "#{$path}/readme.md",                        content: $readme}
      {path: "#{$path}/config.yml",                       content: $config}
      {path: "#{$path}/config-dev.yml",                   content: $config_dev}
      {path: "#{$path}/index.js",                         content: 'index_js'}
      {path: "#{$path}/package.json",                     content: 'package_json'}
      {path: "#{$path}/Procfile",                         content: 'procfile'}
      {path: "#{$path}/template/.gitignore",              content: '.gitignore'}
      {path: "#{$path}/template/404.html",                content: '404'}
      {path: "#{$path}/template/CNAME",                   content: "#{$project}.com"}
      {path: "#{$path}/template/index.html",              content: 'index'}
      {path: "#{$path}/template/_layouts/default.html",   content: 'layouts_default'}
      {path: "#{$path}/template/_layouts/post.html",      content: 'layouts_post'}
      {path: "#{$path}/template/_includes/header.html",   content: 'includes_header'}
      {path: "#{$path}/template/_includes/footer.html",   content: 'includes_footer'}
      {path: "#{$path}/template/_posts/2013-01-01-hello.html", content: 'posts_hello'}
    ]

      if templates[$file.content]?
        fs.writeFileSync $file.path, templates[$file.content]()
      else
        fs.writeFileSync $file.path, $file.content
