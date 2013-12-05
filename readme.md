# Huginn

pronounced "HOO-gin"

"On, Hekyll! On, Jekyll! On Huginn and Muninn!"

Static Page generator

## Quick Start

### Install

```bash
$ sudo npm install huginn -g
```


### Create a new application

```bash
$ huginn create <appname>
$ cd <appname>
$ huginn build
$ huginn serve
```

### Usage

    Usage:
      huginn create PATH

      cd PATH
      huginn build [--drafts]
      huginn serve

    Options:
      -d  [--drafts]    # publish _drafts folder
      -h  [--help]      # display this message
      -v  [--version]   # display version

### Blog Conversion

I started using Jekyll, but I don't enjoy using Ruby. So I created Huginn.
Huginn uses Swig which is similar to Liquid, but there are some differences:

*   Include filenames should be quoted:
    {% include "header.html" %}

*   For loops don't support :LIMIT n.
    Use explicit: if loop.index <= n

*   For loops use 'loop' variable instead of 'forloop'.

### TODO

*   finish gist tag
*   finish highlight tag
*   create http://darkoverlordofdata/huginn

## License

(The MIT License)

Copyright (c) 2012 - 2013 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
