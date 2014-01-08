#+--------------------------------------------------------------------+
#| templates.coffee
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
# Create App Templates
#

module.exports =

  '.gitignore': ->
    """
      /.idea
      /node_modules
      /gh-pages
    """

  '404':  ->
    """
        {% include "header.html" %}
        <h3>The page you requested was not found</h3>
        {% include "footer.html" %}
    """

  index:  ->
    """
      ---
      layout: default
      ---
      {% for post in site.posts %}
              <h1>{{ post.title }}</h1>
              <p class="muted">{{ post.date | date_to_long_string }}</p>
              {{ post.content }}
      {% endfor %}
    """

  layouts_default:  ->
    """
      {% include "header.html" %}
      <div class="row-fluid">
          <div class="span8">
              {{ content }}
          </div>
      </div>
      {% include "footer.html" %}
    """

  layouts_post:  ->
    """
      {% include "header.html" %}
      <div class="row-fluid">
          <div class="span12">
              <h1>{{ page.title }}</h1>
              <p class="muted">{{ page.date | date_to_long_string }}</p>
              {{ content }}
          </div>
      </div>
      {% include "footer.html" %}
    """

  includes_header:  ->
    """
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="utf-8">
          <title>{{ site.name }}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <meta name="description" content="">
          <meta name="author" content="">
          <link rel='stylesheet' href='//cdn.darkoverlordofdata.com/css/bootstrap.min.css' type='text/css'/>
          <style>
          .container-narrow {
              margin: 0 auto;
              max-width: 800px;
          }
          </style>
          <link rel='stylesheet' href='//cdn.darkoverlordofdata.com/css/bootstrap-responsive.min.css' type='text/css'/>
          <link href="/favicon.png" rel="shortcut icon" type="image/png">
      </head>
      <body>
      <div class="row-fluid">
          <div class="span10">
              <blockquote class="pull-right"><h4><a class="no-link" href="/">{{ site.description }}</a></h4>
                  <small><a class="no-link" href="/">{{ site.name }}</a></small>
              </blockquote>
          </div>
      </div>
      <div class="container-narrow">
    """

  includes_footer:  ->
    """
      <hr />
      </div>
      <script type="text/javascript" src="//cdn.darkoverlordofdata.com/js/jquery-2.0.2.min.js" ></script>
      <script type="text/javascript" src="//cdn.darkoverlordofdata.com/js/bootstrap.min.js" ></script>
      </body>
      </html>
    """

  posts_hello:  ->
    """
      ---
      title: Huginn
      layout: post
      tags: coffeescript
      ---
      <p>
          pronounced "HOO-gin"
      </p>
      <p>
          Huginn is a static page generator.
      </p>
      <p>
        "On, Hekyll! On, Jekyll! On Huginn and Muninn!"
      </p>
    """

  # stuff for Heroku:

  procfile: ->
    """
      web: node index.js
    """

  index_js: ->
    """
      require('coffee-script');
      var huginn = require('huginn');
      huginn.serve(['--port', process.env.PORT]);
    """

  package_json: ->
    """
      {
        "name": "yourapp",
        "description": "Huginn generator templates",
        "author": "your name <yourname@mail.com>",
        "dependencies": {
          "huginn": "0.1.x",
          "coffee-script": "~1.6.3"
        },
        "devDependencies": {
        },
        "node": "0.10.x",
      }
    """
