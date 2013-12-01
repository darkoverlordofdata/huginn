#+--------------------------------------------------------------------+
#| plugin.coffee
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
swig = require('swig')

_month_short = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
]
_month_long = [
  'January', 'February', 'March', 'April', 'May', 'June'
  'July', 'August', 'September', 'October', 'November', 'Decenber'
]

#
# Liquid Compatability
#
_filters = 
  date_to_xmlschema: ($input) ->
    $input.toISOString()
  
  date_to_rfc822: ($input) ->
    $input.toUTCString()
  
  date_to_string: ($input) ->
    $input.getDate()+' '+_month_short[$input.getMonth()]+' '+$input.getFullYear()
  
  date_to_long_string: ($input) ->
    $input.getDate()+' '+_month_long[$input.getMonth()]+' '+$input.getFullYear()
  
  xml_escape: ($input) ->
    escape($input)
  
  cgi_escape: ($input) ->
    escape($input)
  
  uri_escape: ($input) ->
    encodeURI($input)
  
  number_of_words: ($input) ->
    if ($match = $input.match(_word_count))
      $match.length
    else
      0
  
  array_to_sentence_string: ($input) ->
    switch $input.length
      when 0 then ''
      when 1 then $input[0]
      when 2 then "#{$input[0]} and #{$input[1]}"
      else
        $last = $input.pop()
        $input.join(', ')+', and '+$last
  
  textilize: ($input) ->
    textile($input)
  
  markdownify: ($input) ->
    md($input)
  
  jsonify: ($input) ->
    JSON.stringify($input)

for $name, $function of _filters
  swig.setFilter $name, $function

for $name in fs.readdirSync("#{__dirname}/tags")

  $name = path.basename($name, path.extname($name))
  $tag = require("./tags/#{$name}")
  swig.setTag $name, $tag.parse, $tag.compile, $tag.ends
