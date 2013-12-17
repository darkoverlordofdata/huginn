fs = require('fs')
path = require('path')
yaml = require('yaml-js')
markdown = require('markdown').markdown

MD_TYPES = ['.md', 'markdown']

module.exports = class Page

  category: ''
  categories: null
  content: ''
  date: null
  excerpt: ''
  id: ''
  path: ''
  tag: ''
  tags: null
  title: ''
  url: ''

  #
  # Load template data
  #
  # @param  [Object]  site parent
  # @param  [String]  template
  # @param  [String]  page
  # @return none
  #
  constructor: ($site, $template, $extra = {}) ->

    $fm = null

    $ext = path.extname($template)
    $buf = String(fs.readFileSync($template))

    if $buf[0..3] is '---\n'
      # pull out the front matter and parse with yaml
      $buf = $buf.split('---\n')
      $fm = yaml.load($buf[1])
      $buf = $buf[2]


    @categories = []
    @content = if $ext in MD_TYPES then markdown.toHTML($buf) else $buf
    @date = new Date
    @tags = []
    @url = $site.parseUrl($template).path

    if ($url = $site.parseUrl($template)).post
      @date = new Date($url.yyyy, $url.mm, $url.dd)

    for $key, $val of $fm
      @[$key] = $val

    for $key, $val of $extra
      @[$key] = $val


