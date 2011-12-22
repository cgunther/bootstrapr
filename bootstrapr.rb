class Bootstrapr < Sinatra::Base
  set :haml, :format => :html5, :layout => :application
  available = %w{alert button carousel collapse dropdown modal popover scrollspy tab transition twipsy}

  # Actions
  get '/' do
    haml :index
  end

  get '/pack/?:compress?' do
    compress = params[:compress] == "compressed"
    headers "Content-Disposition" => "attachment; filename=bootstrap.#{"min." if compress}js"
    content_type "text/javascript"
    files = params[:files] ? params[:files].split(',').collect{|f| f if available.include?(f)}.compact : []

    content = []
    ugl = Uglifier.new(copyright: !compress)
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