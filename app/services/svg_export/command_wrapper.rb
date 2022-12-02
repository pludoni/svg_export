module SvgExport
  class CommandWrapper
    attr_reader :params
    def initialize(params, options)
      @params = params
      @allowed_types = Engine.default_options[:allowed_types]
      @tmp_path = Engine.default_options[:tmp_path]
      @svg_transformer = Engine.default_options[:svg_transformer]
      @options = options
    end

    def call
      transformer = @svg_transformer.new(@options)
      svg = transformer.transform(params[:svg])
      File.open('/tmp/jobwert-export-last.svg', 'w+') do |f|
        f.write svg
      end
      infile.write(svg)
      infile.flush
      result = run!
      fs = File.size?( outfile.path)
      if fs.nil? || fs < 10
        raise SvgExport::Error.new( "Output file empty;  #{result}")
      end
      transformer.clear!
      File.open(outfile)
    end

    def filename
      base = params[:filename].blank? ? "chart" : params[:filename]
      "#{base}.#{ext}"
    end

    def type
      @type ||= begin
                  @allowed_types.find{|t| t == params[:type] } or raise SvgExport::Error.new("Unknown type #{params[:type]}")
                end
    end

    protected

    def run!
      cmd = "java -Djava.awt.headless=true -jar #{Engine.batik_path} -m #{type} -d #{outfile.path} #{width} #{infile.path} 2>&1"
      result = `#{cmd}`
      if result.index("success").nil?
        raise SvgExport::Error.new(result)
      end
      result
    end

    def width
      if params[:width].to_i > 0
        "-w #{Shellwords.escape(params[:width])}"
      end
    end

    def outfile
      @outfile ||= Tempfile.new(['highcharts-out',".#{ext}"], @tmp_path)
    end

    def infile
      @infile ||= Tempfile.open(['highcharts-in',".svg"], @tmp_path)
    end

    def ext
      { 'image/png' => 'png',
        'image/jpeg' => 'jpg',
        'application/pdf' => 'pdf'
      }[type]
    end


  end
end
