$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "svg_export/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "svg_export"
  s.version     = SvgExport::VERSION
  s.authors     = ["Stefan Wienert"]
  s.email       = ["stefan.wienert@pludoni.de"]
  s.homepage    = "https://github.com/pludoni/svg_export"
  s.summary     = "Rails engine for rasterizing Highcharts SVG files"
  s.description = "Rails engine for rasterizing Highcharts SVG files"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_dependency "nokogiri"
end
