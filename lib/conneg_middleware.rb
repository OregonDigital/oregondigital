class ConnegMiddleware
  def initialize(app)
    @app = app
  end
 
  def call(env)
    env["HTTP_ACCEPT"] = env["HTTP_ACCEPT"].to_s.gsub(/, ?\*\/\*(;q=.*)?$/,'')
    @app.call(env)
  end
end
