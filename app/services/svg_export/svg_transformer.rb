module SvgExport
  class SvgTransformer
    def initialize(base_url, options={})
      @tempfiles = []
      @base_url = options[:base_url]
    end

    def transform(svg)
      doc = Nokogiri::XML.parse(svg)
      doc.search('image').each do |image|
        if image['xlink:href'] and image['xlink:href'][/^\//]
          if image['xlink:href'][%r{/assets/([^\?]+)}, 1] and path = find_asset_path($1)
            # local Asset path
            body = File.read(path)
            url = path
          elsif @base_url
            url = URI.join(@base_url, image['xlink:href']).to_s
            body = download(url)
          else
            next
          end

          ext =  url[/\.(\w+)$/, 1] || 'png'
          tf = Tempfile.new(["highchart-tmp-inline", ".#{ext}", Rails.root.join('tmp')])
          tf.binmode
          @tempfiles << tf
          tf.write(body)
          tf.flush
          # relative url
          image['xlink:href'] = "file://" + tf.path
        end
      end
      doc.to_s
    end

    protected

    def download(url)
      require 'open-uri'
      open(url)
    end

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
  end
end
