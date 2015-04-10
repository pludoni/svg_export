module SvgExport
  class SvgController < ApplicationController
    skip_before_filter :verify_authenticity_token

    def create
      if Engine.batik_path.blank?
        raise ArgumentError.new("Set SvgExport::Engine.batik_path = '...' to the correct path of the batik-rasterizer")
      end
      wrapper = CommandWrapper.new(params, base_url: request.referer)
      begin
        file = wrapper.()
      rescue SvgExport::Error => e
        render :text => "Unable to export image;\n #{e}", status: 422
        return
      end
      send_file file, type: wrapper.type, filename: wrapper.filename, disposition: 'attachment', stream: false
    end
  end
end
