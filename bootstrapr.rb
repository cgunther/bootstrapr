require 'net/https'

class Bootstrapr < Sinatra::Base
  set :haml, :format => :html5, :layout => :application
  available = %w{alert button carousel collapse dropdown modal popover scrollspy tab transition twipsy}

  # Actions
  get '/' do
    haml :index, :locals => {available: available}
  end

  get '/pack' do
    minify = params[:minify] == "1"
    comments = params[:comments] == "1"
    headers "Content-Disposition" => "attachment; filename=bootstrap.#{"min." if minify}js"
    content_type "text/javascript"
    params[:files] = params[:files].split(",") if params[:files].class.name == "String"
    files = params[:files] ? params[:files].collect{|f| f if available.include?(f)}.compact : []

    content = []
    ugl = Uglifier.new(copyright: comments, mangle: minify, squeeze: minify, dead_code: minify, seqs: minify, beautify: !minify)
    for file in files
      uri = URI.parse("https://raw.github.com/twitter/bootstrap/2.0-wip/js/bootstrap-#{file}.js")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      content << ugl.compile(response.body)
    end
    content.join("\n")
  end

  # Helpers
  helpers do
    def stylesheet_path(stylesheet)
      "/stylesheets/#{stylesheet}.css"
    end
  end
end
