[![Gem Version](https://badge.fury.io/rb/svg_export.svg)](http://badge.fury.io/rb/svg_export)

# Svg-Export Engine for Ruby on Rails

Highcharts compliant svg-rasterizer. To find more about Highcharts Exporting, look [here](http://www.highcharts.com/docs/export-module/export-module-overview)

Features:

* makes relative URLs absolute (with HTTP_REFERER)
* relative URLs that begins with /assets are locally linked (Performance boost + works in single-threaded server envs)


## Installation


### 1. install Gem

```ruby
# Gemfile
gem 'svg_export'
```

Run ``bundle``

### 2. mount engine + configure


```ruby
# config/routes.rb

Rails.application.routes.draw do
  #...

  mount SvgExport::Engine => '/exporting'
end
```

### 3. Download or install Apache Batik

This project needs Apache Batik installed on the system.

Quick install:

```
cd bin
wget http://ftp.halifax.rwth-aachen.de/apache/xmlgraphics/batik/binaries/batik-bin-1.8.tar.gz
tar xf batik-bin-1.8.tar.gz
```

And configure the path, e.g. in ``config/initializers/svg_export.rb``

```ruby
SvgExport::Engine.batik_path = Rails.root.join('bin/batik-1.8/batik-rasterizer-1.8.jar')
```


### 4. Change Highchart configuration to use that server:

e.g.:

```javascript
{
  exporting: {
    url: '/exporting'
  }
}
```


