class Bootstrapr < Sinatra::Base
  set :haml, :format => :html5, :layout => :application
  available = %w{alert button carousel collapse dropdown modal popover scrollspy tab transition twipsy}

  # Actions
  get '/' do
    haml :index, :locals => {available: available}
  end

  get '/pack' do
    compress = params[:compress] == "1"
    comments = params[:comments] == "1"
    headers "Content-Disposition" => "attachment; filename=bootstrap.#{"min." if compress}js"
    content_type "text/javascript"
    params[:files] = params[:files].split(",") if params[:files].class.name == "String"
    files = params[:files] ? params[:files].collect{|f| f if available.include?(f)}.compact : []

    content = []
    ugl = Uglifier.new(copyright: comments)
    for file in files
      content << ugl.compile(File.open(File.join(settings.root,"src","bootstrap-#{file}.js")))
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