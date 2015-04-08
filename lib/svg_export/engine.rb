module SvgExport
  class Engine < ::Rails::Engine
    isolate_namespace SvgExport
    cattr_accessor :batik_path
  end
end

# SvgExport::Engine.batik_path = SvgExport::Engine.root.join('bin/batik-rasterizer-1.8.jar')
