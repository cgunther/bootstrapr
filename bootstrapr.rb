require 'net/https'

class Bootstrapr < Sinatra::Base
  set :haml, :format => :html5, :layout => :application

  # Actions
  get '/' do
    haml :index
  end

  get '/pack' do
    ref = params[:ref] || "master"
    minify = params[:minify] == "1"
    comments = params[:comments] == "1"
    headers "Content-Disposition" => "attachment; filename=bootstrap.#{"min." if minify}js"
    content_type "text/javascript"
    params[:files] = params[:files].split(",") if params[:files].class.name == "String"
    files = params[:files] || []

    content = []
    ugl = Uglifier.new(copyright: comments, mangle: minify, squeeze: minify, dead_code: minify, seqs: minify, beautify: !minify)
    for file in files
      uri = URI.parse("https://raw.github.com/twitter/bootstrap/#{ref}/js/bootstrap-#{file}.js")
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
