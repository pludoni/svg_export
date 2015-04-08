module SvgExport
  class SvgController < ApplicationController
    skip_before_filter :verify_authenticity_token

    def find_asset_path(partial_path)
      Rails.application.config.assets.paths.each do |asset_dir|
        Dir.glob("#{asset_dir}/*").each do |full_path|
          if full_path.ends_with?(partial_path)
            return full_path
          end
        end
      end

      nil
    end

    def create
      if Engine.batik_path.blank?
        raise ArgumentError.new("Set SvgExport::Engine.batik_path = '...' to the correct path of the batik-rasterizer")
      end
      svg = params[:svg]
      doc = Nokogiri::XML.parse(svg)
      tfs = []
      doc.search('image').each do |image|
        if image['xlink:href'] and image['xlink:href'][/^\//]
          if image['xlink:href'][%r{/assets/([^\?]+)}, 1]
            # local Asset path
            path = find_asset_path($1)
            body = File.read(path)
            url = path
          else
            url = URI.join(request.referer, image['xlink:href']).to_s
            body = open(url)
          end

          ext =  url[/\.(\w+)$/, 1] || 'png'
          tf = Tempfile.new(["highchart-tmp-inline", ".#{ext}", Rails.root.join('tmp')])
          tf.binmode
          tfs << tf
          tf.write(body)
          tf.flush
          # relative url
          image['xlink:href'] = "file://" + tf.path
        end
      end
      svg = doc.to_s

      filename = params[:filename].blank? ? "chart" : params[:filename]

      if params[:type] == 'image/png'
        type = '-m image/png';
        ext = 'png'
      elsif params[:type] == 'image/jpeg'
        type = '-m image/jpeg'
        ext = 'jpg'
      elsif params[:type]  == 'application/pdf'
        type = '-m application/pdf'
        ext = 'pdf'
      else
        show_error "unknown image type: #{params[:type]}"
      end

      # two random file names - one for Batik to read (with SVG XML) and one for it to write to
      Tempfile.open(['highcharts-out',".#{ext}"], Rails.root.join('tmp')) do |outfile|
        Tempfile.open(['highcharts-in',".svg"], Rails.root.join('tmp')) do |infile|
          outfile.binmode
          width = "-w #{Shellwords.escape(params[:width])}" if params[:width] and params[:width].to_i > 0
          infile.write(svg)
          infile.flush; infile.close
          cmd = "java -jar #{Engine.batik_path} #{type} -d #{outfile.path} #{width} #{infile.path} 2>&1"
          rsp = `#{cmd}`
          if rsp.index("success").nil?
            show_error(rsp)
            return
          end

          # For now, rely on existence and size of output file as an idicator of success
          fs = File.size?( outfile.path)
          if fs.nil? || fs < 10
            show_error( "Output file empty;  #{rsp}")
          else
            # Send output back to user; note use of :stream => false so that we can delete the file (otherwise we don't know when stream is complete...)
            send_file File.open(outfile), type: params[:type], filename: "#{filename}.#{ext}", disposition: 'attachment', stream: false
          end
        end
      end
    end

    def show_error(rsp)
      render :text => "Unable to export image; #{rsp}", :status => 500
    end
  end
end
