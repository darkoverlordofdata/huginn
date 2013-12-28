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
  run: ($project, $use_branch = false, $branch = "master") ->

    $path = path.resolve(process.cwd(), $project)
    if fs.existsSync($path)
      process.exit console.log("ERR: the folder #{$path} already exists.")

    console.log "Creating #{$project}..."


    $readme = """
      # "#{$project}"
    """

    if $use_branch in ['-b', '--branch']

      fs.mkdirSync $path
      $path += '/'+$branch

      $config = """
        name: "#{$project}"
        description: "On, Hekyll! On, Jekyll! On Huginn and Muninn!"

        source: ./template
        destination: ../gh-pages

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
        destination: ./gh-pages/#{$project}

        port: 0xd16a
        url: http://#{$project}.com

        serve:
          - ./gh-pages
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
        destination: ./www

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
        destination: ./www

        port: 0xd16a
        url: http://#{$project}.com

        serve:
          - ./www

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
      {path: "#{$path}/template/CNAME",                   content: "#{$project}.com"}
      {path: "#{$path}/template/404.html",                content: '404'}
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
