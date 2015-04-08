module SvgExport
  class Engine < ::Rails::Engine
    isolate_namespace SvgExport
    cattr_accessor :batik_path
    cattr_accessor :default_options
    self.default_options = {
    }
    initializer 'svg_export.init' do
      Engine.default_options.reverse_merge!({
        allowed_types: ['image/png', 'image/jpeg', 'application/pdf'],
        tmp_path: Rails.root.join('tmp'),
        svg_transformer: SvgTransformer
      })
    end
  end
end

# SvgExport::Engine.batik_path = SvgExport::Engine.root.join('bin/batik-rasterizer-1.8.jar')
