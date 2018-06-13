module SvgExport
  class SvgController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def create
      if Engine.batik_path.blank?
        raise ArgumentError, "Set SvgExport::Engine.batik_path = '...' to the correct path of the batik-rasterizer"
      end
      wrapper = CommandWrapper.new(params, base_url: request.referer)
      begin
        file = wrapper.call
      rescue SvgExport::Error => e
        render plain: "Unable to export image;\n #{e}", status: :unprocessable_entity
        return
      end
      send_file file, type: wrapper.type, filename: wrapper.filename, disposition: 'attachment', stream: false
    end
  end
end
